import "dart:convert";

import "package:aw40_hub_frontend/dtos/vehicle_dto.dart";
import "package:aw40_hub_frontend/dtos/vehicle_update_dto.dart";
import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/models/vehicle_model.dart";
import "package:aw40_hub_frontend/providers/auth_provider.dart";
import "package:aw40_hub_frontend/services/helper_service.dart";
import "package:aw40_hub_frontend/services/http_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter/foundation.dart";
import "package:http/http.dart";
import "package:logging/logging.dart";

class VehicleProvider with ChangeNotifier {
  VehicleProvider(this._httpService);

  final HttpService _httpService;

  final Logger _logger = Logger("vehicle_provider");
  late final String workshopId;

  late final String caseId;

  String? _authToken;

  Future<List<VehicleModel>> getSharedVehicles() async {
    final String authToken = _getAuthToken();
    final Response response = await _httpService.getSharedVehicles(
      authToken,
    );
    if (response.statusCode != 200) {
      _logger.warning(
        "Could not get vehicle. "
        "${response.statusCode}: ${response.reasonPhrase}",
      );
      return [];
    }
    final json = jsonDecode(response.body);
    if (json is! List) {
      _logger.warning("Could not decode json response to List.");
      return [];
    }
    return json.map((e) => VehicleDto.fromJson(e).toModel()).toList();
  }

  Future<List<VehicleModel>> getVehicles() async {
    final String authToken = _getAuthToken();
    final Response response = await _httpService.getVehicles(
      authToken,
      workshopId,
      caseId,
    );
    if (response.statusCode != 200) {
      _logger.warning(
        "Could not get vehicle. "
        "${response.statusCode}: ${response.reasonPhrase}",
      );
      return [];
    }
    final json = jsonDecode(response.body);
    if (json is! List) {
      _logger.warning("Could not decode json response to List.");
      return [];
    }
    return json.map((e) => VehicleDto.fromJson(e).toModel()).toList();
  }

  Future<VehicleModel?> updateVehicle(
    String caseId_,
    VehicleUpdateDto updateVehicleDto,
  ) async {
    final String authToken = _getAuthToken();
    final Map<String, dynamic> updateVehicleJson = updateVehicleDto.toJson();
    final Response response = await _httpService.updateVehicle(
      authToken,
      workshopId,
      caseId_,
      updateVehicleJson,
    );
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      200,
      "Could not update vehicle. ",
      response,
      _logger,
    );
    if (!verifyStatusCode) return null;
    notifyListeners();
    return _decodeVehicleModelFromResponseBody(response);
  }

  VehicleModel _decodeVehicleModelFromResponseBody(Response response) {
    final Map<String, dynamic> body = jsonDecode(response.body);
    final VehicleDto receivedVehicle = VehicleDto.fromJson(body);
    return receivedVehicle.toModel();
  }

  Future<void> fetchAndSetAuthToken(AuthProvider authProvider) async {
    _authToken = await authProvider.getAuthToken();
    notifyListeners();
  }

  String _getAuthToken() {
    final String? authToken = _authToken;
    if (authToken == null) {
      throw AppException(
        exceptionMessage: "Called VehicleProvider without auth token.",
        exceptionType: ExceptionType.unexpectedNullValue,
      );
    }
    return authToken;
  }
}
