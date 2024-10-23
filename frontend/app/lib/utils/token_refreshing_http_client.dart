import "dart:async";
import "dart:convert";

import "package:aw40_hub_frontend/models/jwt_model.dart";
import "package:aw40_hub_frontend/services/auth_service.dart";
import "package:aw40_hub_frontend/services/config_service.dart";
import "package:aw40_hub_frontend/services/storage_service.dart";
import "package:aw40_hub_frontend/services/token_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:http/http.dart" as http;
import "package:logging/logging.dart";

class TokenRefreshingHttpClient extends http.BaseClient {
  TokenRefreshingHttpClient(
    this._innerClient,
    this._storageService,
    this._configService,
    this._tokenService,
  );
  final http.Client _innerClient;
  final StorageService _storageService;
  final Logger _logger = Logger("token_refreshing_http_client");
  final ConfigService _configService;
  final TokenService
      _tokenService; // TODO maybe remove as param (see AuthService)

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final Uri url = request.url;

    if (!url.path.contains("/health/ping")) {
      // check whether token is still valid otherwise renew token
      String? token = await _getAccessToken();
      if (token == null) {
        await _refreshAccessToken();
        token = await _getAccessToken();
      }

      // set valid access token in header
      if (token != null) {
        request.headers["Authorization"] = "Bearer $token";
      }
    }

    return _innerClient.send(request);
  }

  // TODO adjust
  Future<void> resetAuthTokensAndStorage() async {
    await _storageService.resetLocalStorage();
    //_jwt = null;
    //_refreshToken = null;
    //notifyListeners();
  }

  Future<String?> _getAccessToken() async {
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

  Future<void> _refreshAccessToken() async {
    _logger.config("refreshJWT");

    var accessToken;
    var idToken;
    var refreshToken = await _storageService.loadStringFromLocalStorage(
      key: LocalStorageKey.refreshToken,
    );
    if (refreshToken == null) {
      // TODO prompt user login!?
      throw Exception("Refresh token not found");
    }

    final Map<String, dynamic> jsonMap = <String, dynamic>{
      "refresh_token": refreshToken,
      "grant_type": "refresh_token",
      "client_id": _configService.getConfigValue(ConfigKey.keyCloakClient),
    };

    try {
      final Uri uri = Uri.parse(
        "${AuthService().getKeyCloakUrlWithRealm()}token",
      );
      final http.Response res = await _innerClient
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

        final String? newJwt = tokenMap[TokenType.jwt];
        final String? newRefreshToken = tokenMap[TokenType.refresh];
        final String? newIdToken = tokenMap[TokenType.id];
        if (newJwt == null || newRefreshToken == null) return;
        refreshToken = newRefreshToken;
        idToken =
            newIdToken; // TODO either persist this in LocalStorage also or send it to AuthProvider...
        accessToken = JwtModel.fromJwtString(newJwt);

        unawaited(
          _storageService.storeStringToLocalStorage(
            key: LocalStorageKey.accessToken,
            value: newJwt,
          ),
        );
        unawaited(
          _storageService.storeStringToLocalStorage(
            key: LocalStorageKey.accessTokenExpirationDateTime,
            value: accessToken?.exp.toIso8601String() ?? "",
          ),
        );
        unawaited(
          _storageService.storeStringToLocalStorage(
            key: LocalStorageKey.refreshToken,
            value: newRefreshToken,
          ),
        );
      } else {
        _logger.config(
          res.statusCode == 503
              ? "Server not available, clearing tokens and Storage."
              : "Refresh token not accepted, clearing tokens and Storage.",
        );
        _logger.config(res.reasonPhrase);
        _logger.config(res.body);
        await resetAuthTokensAndStorage();
      }
    } on Exception catch (e) {
      _logger.warning(
        "$e: token could not be refreshed, clearing tokens and storage",
      );
      await resetAuthTokensAndStorage();
    }
  }
}
