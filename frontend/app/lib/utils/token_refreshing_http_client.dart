import "dart:async";

import "package:aw40_hub_frontend/services/storage_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:http/http.dart" as http;

class TokenRefreshingHttpClient extends http.BaseClient {
  TokenRefreshingHttpClient(
    this._innerClient,
    this._storageService,
  );
  final http.Client _innerClient;
  final StorageService _storageService;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final Uri url = request.url;

    if (!url.path.contains("/health/ping")) {
      // check whether token is still valid otherwise renew token
      String? token = await _getAccessToken();
      if (token == null) {
        await _refreshToken();
        token = await _getAccessToken();
      }

      // set valid access token in header
      if (token != null) {
        request.headers["Authorization"] = "Bearer $token";
      }
    }

    return _innerClient.send(request);
  }

  Future<String?> _getAccessToken() async {
    final expiryDateString = await _storageService.loadStringFromLocalStorage(
      key: LocalStorageKey.accessTokenExpirationDateTime,
    );
    if (expiryDateString != null) {
      final expiryDate = DateTime.parse(expiryDateString);

      // TODO check whether this works with timezones etc
      // TODO remove '&& false'. It is there for debugging/testing purposes only.
      if (DateTime.now().isAfter(expiryDate) && false) {
        // token is expired
        return null;
      }
    }

    return _storageService.loadStringFromLocalStorage(
      key: LocalStorageKey.accessToken,
    );
  }

  Future<void> _refreshToken() async {
    // TODO implement
    /*
    final refreshToken = await _storageService.loadStringFromLocalStorage(
      key: LocalStorageKey.refreshToken,
    );
    if (refreshToken == null) {
      throw Exception("Refresh token not found");
    }

    // TODO adjust (see other refreshToken method as reference)
    // TODO get keycloak url and client id from config maybe
    final response = await http.post(
      Uri.parse(
          "https://<your-keycloak-server>/realms/<realm>/protocol/openid-connect/token"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "grant_type": "refresh_token",
        "client_id": "<your-client-id>",
        "refresh_token": refreshToken,
      },
    );

    if (response.statusCode == 200) {
      final newTokenData = json.decode(response.body);
      final newAccessToken = newTokenData["access_token"];
      final newRefreshToken = newTokenData["refresh_token"];
      final expiresIn = newTokenData["expires_in"];

      final jwt = JwtModel.fromJwtString(newAccessToken);

      final expiryDate = DateTime.now().add(Duration(seconds: expiresIn));

      unawaited(
        _storageService.storeStringToLocalStorage(
          key: LocalStorageKey.accessToken,
          value: newAccessToken,
        ),
      );
      unawaited(
        _storageService.storeStringToLocalStorage(
          key: LocalStorageKey.accessTokenExpirationDateTime,
          value: jwt.exp.toIso8601String(),
        ),
      );
      unawaited(
        _storageService.storeStringToLocalStorage(
          key: LocalStorageKey.refreshToken,
          value: newRefreshToken,
        ),
      );
    } else {
      // TODO prompt login to user
      throw Exception("Token refresh failed");
    }  */
  }
}
