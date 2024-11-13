import "dart:convert";

import "package:aw40_hub_frontend/dtos/assets_dto.dart";
import "package:aw40_hub_frontend/dtos/assets_update_dto.dart";
import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/models/assets_model.dart";
import "package:aw40_hub_frontend/providers/auth_provider.dart";
import "package:aw40_hub_frontend/services/helper_service.dart";
import "package:aw40_hub_frontend/services/http_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter/foundation.dart";
import "package:http/http.dart";
import "package:logging/logging.dart";

class AssetsProvider with ChangeNotifier {
  AssetsProvider(this._httpService);

  final HttpService _httpService;

  final Logger _logger = Logger("AssetsProvider");
  late final String workshopId;

  late final String caseId;

  String? _authToken;

  Future<List<AssetsModel>> getSharedAssets() async {
    final String authToken = _getAuthToken();
    final Response response = await _httpService.getSharedAssets(
      authToken,
    );
    if (response.statusCode != 200) {
      _logger.warning(
        "Could not get assets. "
        "${response.statusCode}: ${response.reasonPhrase}",
      );
      return [];
    }
    final json = jsonDecode(response.body);
    if (json is! List) {
      _logger.warning("Could not decode json response to List.");
      return [];
    }
    return json.map((e) => AssetsDto.fromJson(e).toModel()).toList();
  }

  Future<List<AssetsModel>> getAssets() async {
    final String authToken = _getAuthToken();
    final Response response = await _httpService.getAssets(
      authToken,
      workshopId,
      caseId,
    );
    if (response.statusCode != 200) {
      _logger.warning(
        "Could not get assets. "
        "${response.statusCode}: ${response.reasonPhrase}",
      );
      return [];
    }
    final json = jsonDecode(response.body);
    if (json is! List) {
      _logger.warning("Could not decode json response to List.");
      return [];
    }
    return json.map((e) => AssetsDto.fromJson(e).toModel()).toList();
  }

  Future<AssetsModel?> updateAssets(
    String caseId_,
    AssetsUpdateDto updateAssetsDto,
  ) async {
    final String authToken = _getAuthToken();
    final Map<String, dynamic> updateAssetsJson = updateAssetsDto.toJson();
    final Response response = await _httpService.updateAssets(
      authToken,
      workshopId,
      caseId_,
      updateAssetsJson,
    );
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      200,
      "Could not update assets. ",
      response,
      _logger,
    );
    if (!verifyStatusCode) return null;
    notifyListeners();
    return _decodeAssetsModelFromResponseBody(response);
  }

  AssetsModel _decodeAssetsModelFromResponseBody(Response response) {
    final Map<String, dynamic> body = jsonDecode(response.body);
    final AssetsDto receivedAssets = AssetsDto.fromJson(body);
    return receivedAssets.toModel();
  }

  Future<void> fetchAndSetAuthToken(AuthProvider authProvider) async {
    _authToken = await authProvider.getAuthToken();
    notifyListeners();
  }

  String _getAuthToken() {
    final String? authToken = _authToken;
    if (authToken == null) {
      throw AppException(
        exceptionMessage: "Called AssetsProvider without auth token.",
        exceptionType: ExceptionType.unexpectedNullValue,
      );
    }
    return authToken;
  }
}
