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

// TODO check whether certain requests are excluded (e.g. health, authenticate etc.)
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
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
    // TODO implement later
    /* final refreshToken = await storage.read(key: "refreshToken");
    if (refreshToken == null) {
      throw Exception("Refresh token not found");
    }

    // TODO adjust
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

      // Speichere die neuen Tokens
      final expiryDate = DateTime.now().add(Duration(seconds: expiresIn));
      await storage.write(key: "accessToken", value: newAccessToken);
      await storage.write(key: "refreshToken", value: newRefreshToken);
      // TODO adjust to 'accessTokenExpiryDate'
      await secStorage.write(
          key: "expiryDate", value: expiryDate.toIso8601String());
    } else {
      throw Exception("Token refresh failed");
    } */
  }
}
