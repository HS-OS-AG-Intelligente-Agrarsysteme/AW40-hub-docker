import "dart:async";
import "dart:convert";

import "package:aw40_hub_frontend/configs/localization_config.dart";
import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/models/jwt_model.dart";
import "package:aw40_hub_frontend/models/logged_in_user_model.dart";
import "package:aw40_hub_frontend/services/auth_service.dart";
import "package:aw40_hub_frontend/services/config_service.dart";
import "package:aw40_hub_frontend/services/helper_service.dart";
import "package:aw40_hub_frontend/services/storage_service.dart";
import "package:aw40_hub_frontend/services/token_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:easy_localization/easy_localization.dart";
import "package:enum_to_string/enum_to_string.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:logging/logging.dart";
import "package:routemaster/routemaster.dart";
import "package:universal_html/html.dart" hide Navigator;

class AuthProvider with ChangeNotifier {
  AuthProvider(
    this._client,
    this._storageService,
    this._tokenService,
    this._authService,
    this._configService, [
    this._refreshToken,
  ]);
  JwtModel? _accessTokenJwt;
  String? _refreshToken;
  String? _idToken;
  Completer<void>? _pendingAuthCheck;
  bool _mobileRedirectNextLoginToHome = false;

  final http.Client _client;
  final StorageService _storageService;
  final TokenService _tokenService;
  final AuthService _authService;
  final ConfigService _configService;
  final Logger _logger = Logger("auth_provider");

  // TODO is this necessary or is getAccessTokenSufficient?
  Future<String?> getAuthToken() async {
    await _checkAuth();
    return _accessTokenJwt?.jwt;
  }

  /// For Cases where JWT is not accepted from Backend, e.g. timing problems
  /// to indirectly force a JWT refresh
  void removeJwtToken() => _accessTokenJwt = null;

  /// Returns true if the user is logged in, false otherwise.
  bool isLoggedIn() => _accessTokenJwt != null;

  /// Returns `true` if logged in user has >=1 of the `AuthorizedGroup`s.
  bool get isAuthorized {
    final jwt = _accessTokenJwt;
    if (jwt == null) return false;
    List<String> groups = jwt.groups;
    if (groups.isEmpty) return false;
    groups = groups.map((e) => e.toLowerCase()).toList();
    return AuthorizedGroup.values.any(
      (authGroup) => groups.contains(
        authGroup.name.toLowerCase(),
      ),
    );
  }

  List<AuthorizedGroup> get getUserGroups {
    final jwt = _accessTokenJwt;
    if (jwt == null) return [];
    return EnumToString.fromList(AuthorizedGroup.values, jwt.groups)
        .whereType<AuthorizedGroup>()
        .toList();
  }

  LoggedInUserModel get loggedInUser {
    return LoggedInUserModel(
      getUserGroups,
      _accessTokenJwt?.name ?? tr("general.unnamed"),
      _accessTokenJwt?.preferredUsername ?? tr("general.unnamed"),
      _accessTokenJwt?.email ?? "",
      // TODO: Workshop ID == username for now.
      _accessTokenJwt?.preferredUsername ?? "",
    );
  }

  Future<void> setAuthTokensFromKeycloakCode({
    required String keycloakCode,
    required String redirectUri,
  }) async {
    final String? verifier = await _storageService.loadStringFromLocalStorage(
      key: LocalStorageKey.verifier,
    );

    await _storageService.resetLocalStorage();

    if (verifier == null) {
      _logger.config(
        "auth_provider updateUserLoginStateFromKeycloakCode: "
        "_verifier == null, restarting LogInProcess...",
      );
      notifyListeners();
      return;
    }

    final Map<TokenType, String> tokenMap =
        await _getTokensFromCode(keycloakCode, redirectUri, verifier);

    final String? returnedJwt = tokenMap[TokenType.jwt];
    _refreshToken = tokenMap[TokenType.refresh];
    _idToken = tokenMap[TokenType.id];
    final String? refreshTokenSnapshot = _refreshToken;

    if (returnedJwt == null) {
      throw AppException(
        exceptionType: ExceptionType.notFound,
        exceptionMessage: "returnedJwt == null",
      );
    }
    if (refreshTokenSnapshot == null) {
      throw AppException(
        exceptionType: ExceptionType.notFound,
        exceptionMessage: "_refreshTokenSnapshot == null",
      );
    }

    await _storageService.storeStringToLocalStorage(
      key: LocalStorageKey.refreshToken,
      value: refreshTokenSnapshot,
    );

    _accessTokenJwt = JwtModel.fromJwtString(returnedJwt);

    _logger.config("Lang from jwt: ${_accessTokenJwt?.locale}");

    final Locale? locale = _accessTokenJwt?.locale != null
        ? kSupportedLocales[_accessTokenJwt?.locale]
        : kFallbackLocale;

    if (locale != null) {
      // ignore: use_build_context_synchronously
      await HelperService.globalContext.setLocale(locale);
    }

    _logger.finer(
      "_mobileRedirectNextLoginToHome: $_mobileRedirectNextLoginToHome",
    );
    if (_mobileRedirectNextLoginToHome) {
      _mobileRedirectNextLoginToHome = false;

      final BuildContext context = HelperService.globalContext;
      // ignore: use_build_context_synchronously
      Routemaster.of(context).replace("/");
    }

    notifyListeners();
  }

  Future<void> _checkAuth() async {
    _logger.finest("_checkAuth()");
    if (_pendingAuthCheck != null) {
      await _pendingAuthCheck?.future;
      return;
    }

    try {
      _pendingAuthCheck = Completer<void>();

      final JwtModel? jwtSnapshot = _accessTokenJwt;
      final String? refreshTokenSnapshot = _refreshToken;

      final bool hasRefreshTokenButNoValidJwt = refreshTokenSnapshot != null &&
          (jwtSnapshot == null || isExpired(jwtSnapshot));
      if (hasRefreshTokenButNoValidJwt) {
        await refreshAccessToken();
      }
    } finally {
      _pendingAuthCheck?.complete();
      _pendingAuthCheck = null;
    }
  }

  bool isExpired(JwtModel jwt) {
    final DateTime now = DateTime.now();
    final bool isExpired = now.isAfter(jwt.exp);
    return isExpired;
  }

  Future<void> tryLoginWithStoredRefreshToken() async {
    _logger.config("tryLoginWithStoredRefreshTokens");
    _refreshToken = await _storageService.loadStringFromLocalStorage(
      key: LocalStorageKey.refreshToken,
    );

    if (_refreshToken != null) {
      _logger.fine("found stored refresh token");
      await _checkAuth();
      notifyListeners();
    } else {
      _logger.fine("no stored refresh token");
    }
  }

  Future<String> generateCodeChallengeAndStoreVerifier() async {
    _logger.finest("generateCodeChallengeAndStoreVerifier()");
    String? verifier = await _storageService.loadStringFromLocalStorage(
      key: LocalStorageKey.verifier,
    );

    if (verifier == null) {
      verifier = _authService.createVerifier();
      await _storageService.storeStringToLocalStorage(
        key: LocalStorageKey.verifier,
        value: verifier,
      );
    }

    final String codeChallenge = _authService.createCodeChallenge(verifier);
    return codeChallenge;
  }

  Future<Map<TokenType, String>> _getTokensFromCode(
    String code,
    String redirectUri,
    String verifier,
  ) async {
    final Map<String, dynamic> jsonMap = <String, dynamic>{
      "code": code,
      "grant_type": "authorization_code",
      "redirect_uri": redirectUri,
      "client_id": _configService.getConfigValue(ConfigKey.keyCloakClient),
      "code_verifier": verifier,
    };

    final Uri uri = Uri.parse(
      "${AuthService().getKeyCloakUrlWithRealm()}token",
    );
    final http.Response res = await _client.post(
      uri,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: jsonMap,
    );

    Map<String, dynamic>? keycloakMap;

    if (res.statusCode == 200) {
      keycloakMap = json.decode(res.body) as Map<String, dynamic>;
    } else {
      _logger.config(
        "_getTokensFromCode: statusCode: ${res.statusCode}, ${res.body}",
      );
    }

    if (keycloakMap == null) {
      if (kIsWeb) {
        _logger.config(
          "auth_provider updateUserLoginStateFromKeycloakCode: "
          "keycloakMap null, reload page...",
        );
        window.location.reload();
      }

      // Phoenix.rebirth(HelperService.globalContext);
      throw Error();
    }

    final Map<TokenType, String> tokenMap =
        _tokenService.readRefreshAndJWTFromKeyCloakMap(keycloakMap);

    return tokenMap;
  }

  Future<void> resetAuthTokensAndStorage() async {
    await _storageService.resetLocalStorage();
    _accessTokenJwt = null;
    _refreshToken = null;
    notifyListeners();
  }

  Future<String?> getAccessToken() async {
    final expiryDateString = await _storageService.loadStringFromLocalStorage(
      key: LocalStorageKey.accessTokenExpirationDateTime,
    );
    if (expiryDateString != null) {
      final expiryDate = DateTime.parse(expiryDateString);

      if (DateTime.now().isAfter(expiryDate)) {
        // token is expired
        return null;
      }
    }

    return _storageService.loadStringFromLocalStorage(
      key: LocalStorageKey.accessToken,
    );
  }

  Future<void> refreshAccessToken() async {
    _logger.config("refreshAccessToken");

    _refreshToken = await _storageService.loadStringFromLocalStorage(
      key: LocalStorageKey.refreshToken,
    );
    if (_refreshToken == null) {
      _informUserAboutInvalidToken();
    }

    final Map<String, dynamic> jsonMap = <String, dynamic>{
      "refresh_token": _refreshToken,
      "grant_type": "refresh_token",
      "client_id": _configService.getConfigValue(ConfigKey.keyCloakClient),
    };

    try {
      final Uri uri = Uri.parse(
        "${AuthService().getKeyCloakUrlWithRealm()}token",
      );
      final http.Response res = await _client
          .post(
            uri,
            headers: {"Content-Type": "application/x-www-form-urlencoded"},
            body: jsonMap,
          )
          .timeout(
            const Duration(
              seconds: 10,
            ),
          );

      if (res.statusCode == 200) {
        final Map<String, dynamic> keyCloakMap =
            json.decode(res.body) as Map<String, dynamic>;

        final Map<TokenType, String> tokenMap =
            _tokenService.readRefreshAndJWTFromKeyCloakMap(keyCloakMap);

        final String? newAccessToken = tokenMap[TokenType.jwt];
        final String? newRefreshToken = tokenMap[TokenType.refresh];
        final String? newIdToken = tokenMap[TokenType.id];
        if (newAccessToken == null || newRefreshToken == null) return;
        _refreshToken = newRefreshToken;
        _idToken = newIdToken;
        _accessTokenJwt = JwtModel.fromJwtString(newAccessToken);

        unawaited(
          _storageService.storeStringToLocalStorage(
            key: LocalStorageKey.accessToken,
            value: newAccessToken,
          ),
        );
        unawaited(
          _storageService.storeStringToLocalStorage(
            key: LocalStorageKey.accessTokenExpirationDateTime,
            value: _accessTokenJwt!.exp.toIso8601String(),
          ),
        );
        unawaited(
          _storageService.storeStringToLocalStorage(
            key: LocalStorageKey.refreshToken,
            value: newRefreshToken,
          ),
        );

        notifyListeners();
      } else {
        _logger.config(
          res.statusCode == 503
              ? "Server not available, clearing tokens and Storage."
              : "Refresh token not accepted, clearing tokens and Storage.",
        );
        _logger.config(res.reasonPhrase);
        _logger.config(res.body);
        await resetAuthTokensAndStorage();
        _informUserAboutInvalidToken();
      }
    } on Exception catch (e) {
      _logger.warning(
        "$e: token could not be refreshed, clearing tokens and storage",
      );
      await resetAuthTokensAndStorage();
      _informUserAboutInvalidToken();
    }
  }

  void _informUserAboutInvalidToken() {
    final messengerState = ScaffoldMessenger.of(HelperService.globalContext);
    messengerState.showSnackBar(
      SnackBar(
        content: Text(tr("general.invalidSession")),
      ),
    );
  }

  Future<void> logout() async {
    _logger.finest("logout()");
    if (kIsWeb) {
      _logger.config("Web logout.");
      final String? idToken = _idToken;
      if (idToken == null) {
        _logger.warning(
          "idToken == null, cannot perform keycloak post logout redirect",
        );
      }
      window.location.href = _authService.webGetKeycloakLogoutUrl(idToken);
    } else {
      _logger.config("Mobile logout.");
      _mobileRedirectNextLoginToHome = true;

      final Map<String, dynamic> jsonMap = <String, dynamic>{
        // can throw errors without <?? ''>
        "refresh_token": _refreshToken ?? "",
        "client_id": _configService.getConfigValue(ConfigKey.keyCloakClient),
      };

      final String? token = await getAuthToken();
      final String keycloakUrl = _authService.getKeyCloakUrlWithRealm();
      final Uri uri = Uri.parse("${keycloakUrl}logout");
      final http.Response res = await _client.post(
        uri,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Bearer $token",
        },
        body: jsonMap,
      );

      if (res.statusCode == 204) {
        _logger.config("Logout successful");
      } else {
        _logger.warning("Logout unsuccessful");
      }

      await resetAuthTokensAndStorage();
    }
  }
}
