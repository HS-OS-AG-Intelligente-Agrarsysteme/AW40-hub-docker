import "dart:async";

import "package:aw40_hub_frontend/providers/auth_provider.dart";
import "package:aw40_hub_frontend/services/auth_service.dart";
import "package:aw40_hub_frontend/services/config_service.dart";
import "package:aw40_hub_frontend/services/storage_service.dart";
import "package:aw40_hub_frontend/services/token_service.dart";
import "package:http/http.dart" as http;

class TokenRefreshingHttpClientInterceptor extends http.BaseClient {
  TokenRefreshingHttpClientInterceptor(
    this._innerClient,
  );
  final http.Client _innerClient;
  final AuthProvider _authProvider = AuthProvider(
    http.Client(),
    StorageService(),
    TokenService(),
    AuthService(),
    ConfigService(),
  );

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final Uri url = request.url;

    if (!url.path.contains("/health/ping")) {
      // check whether token is still valid otherwise renew token
      String? token = await _authProvider.getAccessToken();
      if (token == null) {
        await _authProvider.refreshAccessToken();
        token = await _authProvider.getAccessToken();
      }

      // set valid access token in header
      if (token != null) {
        request.headers["Authorization"] = "Bearer $token";
      }
    }

    return _innerClient.send(request);
  }
}
