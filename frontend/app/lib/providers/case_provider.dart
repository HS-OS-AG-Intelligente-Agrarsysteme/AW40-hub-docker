import "dart:convert";

import "package:aw40_hub_frontend/dtos/case_dto.dart";
import "package:aw40_hub_frontend/dtos/case_update_dto.dart";
import "package:aw40_hub_frontend/dtos/new_case_dto.dart";
import "package:aw40_hub_frontend/dtos/new_obd_data_dto.dart";
import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/models/case_model.dart";
import "package:aw40_hub_frontend/providers/auth_provider.dart";
import "package:aw40_hub_frontend/services/helper_service.dart";
import "package:aw40_hub_frontend/services/http_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:aw40_hub_frontend/utils/filter_criteria.dart";
import "package:flutter/material.dart";
import "package:http/http.dart";
import "package:logging/logging.dart";

class CaseProvider with ChangeNotifier {
  CaseProvider(this._httpService);
  final HttpService _httpService;

  final Logger _logger = Logger("case_provider");
  late String workshopId;
  bool _showSharedCases = true;
  bool get showSharedCases => _showSharedCases;
  String? _authToken;

  FilterCriteria? _filterCriteria;

  FilterCriteria? get filterCriteria => _filterCriteria;

  void setFilterCriteria(FilterCriteria criteria) {
    _filterCriteria = criteria;
    notifyListeners();
  }

  void resetFilterCriteria() {
    _filterCriteria = null;
    notifyListeners();
  }

  bool isFilterActive() {
    return filterCriteria != null;
  }

  Future<void> toggleShowSharedCases() async {
    _showSharedCases = !_showSharedCases;
    await getCurrentCases();
    notifyListeners();
  }

  Future<List<CaseModel>> getCurrentCases() async {
    final String authToken = _getAuthToken();
    // * Return value currently not used.
    final Response response;
    if (_showSharedCases) {
      response = await _httpService.getSharedCases(
        authToken,
        filterCriteria: filterCriteria,
      );
    } else {
      response = await _httpService.getCases(
        authToken,
        workshopId,
        filterCriteria: filterCriteria,
      );
    }
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      200,
      "Could not get ${_showSharedCases ? 'shared ' : ''}cases. "
      "${response.statusCode}: ${response.reasonPhrase}",
      response,
      _logger,
    );
    if (!verifyStatusCode) return [];
    return _jsonBodyToCaseModelList(response.body);
  }

  Future<List<CaseModel>> getCasesByVehicleVin(String vehicleVin) async {
    final String authToken = _getAuthToken();
    final Response response = await _httpService.getCasesByVehicleVin(
      authToken,
      workshopId,
      vehicleVin,
    );
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      200,
      "Could not get cases by vehicle vin. "
      "${response.statusCode}: ${response.reasonPhrase}",
      response,
      _logger,
    );
    if (!verifyStatusCode) return [];
    return _jsonBodyToCaseModelList(response.body);
  }

  List<CaseModel> _jsonBodyToCaseModelList(String jsonBody) {
    final List<dynamic> dynamicList = jsonDecode(jsonBody);
    final List<CaseModel> caseModels = [];
    for (final caseJson in dynamicList) {
      final CaseDto caseDto = CaseDto.fromJson(caseJson);
      final CaseModel caseModel = caseDto.toModel();
      caseModels.add(caseModel);
    }
    return caseModels;
  }

  Future<CaseModel?> addCase(NewCaseDto newCaseDto) async {
    final String authToken = _getAuthToken();
    final Map<String, dynamic> newCaseJson = newCaseDto.toJson();
    final Response response =
        await _httpService.addCase(authToken, workshopId, newCaseJson);
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      201,
      "Could not add case. ",
      response,
      _logger,
    );
    if (!verifyStatusCode) return null;
    notifyListeners();
    return _decodeCaseModelFromResponseBody(response);
  }

  CaseModel _decodeCaseModelFromResponseBody(Response response) {
    final Map<String, dynamic> body = jsonDecode(response.body);
    final CaseDto receivedCase = CaseDto.fromJson(body);
    return receivedCase.toModel();
  }

  Future<CaseModel?> updateCase(
    String caseId,
    CaseUpdateDto updateCaseDto,
  ) async {
    final String authToken = _getAuthToken();
    final Map<String, dynamic> updateCaseJson = updateCaseDto.toJson();
    final Response response = await _httpService.updateCase(
      authToken,
      workshopId,
      caseId,
      updateCaseJson,
    );
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      200,
      "Could not update case. ",
      response,
      _logger,
    );
    if (!verifyStatusCode) return null;
    notifyListeners();
    return _decodeCaseModelFromResponseBody(response);
  }

  Future<bool> deleteCase(String caseId) async {
    final String authToken = _getAuthToken();
    final Response response =
        await _httpService.deleteCase(authToken, workshopId, caseId);
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      200,
      "Could not delete case. ",
      response,
      _logger,
    );
    if (!verifyStatusCode) return false;
    notifyListeners();
    return true;
  }

  Future<void> sortCases() async {
    _logger.warning("Unimplemented: sortCases()");
  }

  Future<bool> uploadObdData(String caseId, NewOBDDataDto obdDataDto) async {
    final String authToken = _getAuthToken();
    final Map<String, dynamic> obdDataJson = obdDataDto.toJson();
    final Response response = await _httpService.uploadObdData(
      authToken,
      workshopId,
      caseId,
      obdDataJson,
    );
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      201,
      "Could not upload obd data. ",
      response,
      _logger,
    );
    if (!verifyStatusCode) return false;
    notifyListeners();
    return true;
  }

  Future<bool> uploadVcdsData(
    String caseId,
    List<int> vcdsData,
    String filename,
  ) async {
    final String authToken = _getAuthToken();
    final Response response = await _httpService.uploadVcdsData(
      authToken,
      workshopId,
      caseId,
      vcdsData,
      filename,
    );
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      201,
      "Could not upload vcds data. ",
      response,
      _logger,
    );
    if (!verifyStatusCode) return false;
    notifyListeners();
    return true;
  }

  Future<bool> uploadTimeseriesData(
    String caseId,
    String component,
    TimeseriesDataLabel label,
    int samplingRate,
    int duration,
    List<int> signal,
  ) async {
    final String authToken = _getAuthToken();
    final Response response = await _httpService.addTimeseriesData(
      authToken,
      workshopId,
      caseId,
      component,
      label,
      samplingRate,
      duration,
      signal,
    );
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      201,
      "Could not upload timeseries data. ",
      response,
      _logger,
    );
    if (!verifyStatusCode) return false;
    notifyListeners();
    return true;
  }

  Future<bool> uploadPicoscopeData(
    String caseId,
    List<int> picoscopeData,
    String filename,
    String? componentA,
    String? componentB,
    String? componentC,
    PicoscopeLabel? labelA,
    PicoscopeLabel? labelB,
    PicoscopeLabel? labelC,
  ) async {
    final String authToken = _getAuthToken();
    final Response response = await _httpService.uploadPicoscopeData(
      authToken,
      workshopId,
      caseId,
      picoscopeData,
      filename,
      componentA: componentA,
      componentB: componentB,
      componentC: componentC,
      labelA: labelA,
      labelB: labelB,
      labelC: labelC,
    );
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      201,
      "Could not upload picoscope data. ",
      response,
      _logger,
    );
    if (!verifyStatusCode) return false;
    notifyListeners();
    return true;
  }

  Future<bool> uploadOmniviewData(
    String caseId,
    List<int> omniviewData,
    String filename,
    String component,
    int samplingRate,
    int duration,
  ) async {
    final String authToken = _getAuthToken();
    final Response response = await _httpService.uploadOmniviewData(
      authToken,
      workshopId,
      caseId,
      component,
      samplingRate,
      duration,
      omniviewData,
      filename,
    );
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      201,
      "Could not upload omniview data. ",
      response,
      _logger,
    );
    if (!verifyStatusCode) return false;
    notifyListeners();
    return true;
  }

  Future<bool> uploadSymptomData(
    String caseId,
    String component,
    SymptomLabel label,
  ) async {
    final String authToken = _getAuthToken();
    final Response response = await _httpService.uploadSymptomData(
      authToken,
      workshopId,
      caseId,
      component,
      label,
    );
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      201,
      "Could not upload symptom data. ",
      response,
      _logger,
    );
    if (!verifyStatusCode) return false;
    notifyListeners();
    return true;
  }

  Future<bool> deleteObdData(
    int? dataId,
    String workshopId,
    String caseId,
  ) async {
    final String authToken = _getAuthToken();
    final Response response = await _httpService.deleteObdData(
      authToken,
      dataId,
      workshopId,
      caseId,
    );
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      200,
      "Could not delete OBD data",
      response,
      _logger,
    );
    if (!verifyStatusCode) return false;
    notifyListeners();
    return true;
  }

  Future<bool> deleteTimeseriesData(
    int? dataId,
    String workshopId,
    String caseId,
  ) async {
    final String authToken = _getAuthToken();
    final Response response = await _httpService.deleteTimeseriesData(
      authToken,
      dataId,
      workshopId,
      caseId,
    );
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      200,
      "Could not delete timeseries data",
      response,
      _logger,
    );
    if (!verifyStatusCode) return false;
    notifyListeners();
    return true;
  }

  Future<bool> deleteSymptomData(
    int? dataId,
    String workshopId,
    String caseId,
  ) async {
    final String authToken = _getAuthToken();
    final Response response = await _httpService.deleteSymptomData(
      authToken,
      dataId,
      workshopId,
      caseId,
    );
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      200,
      "Could not delete symptom data",
      response,
      _logger,
    );
    if (!verifyStatusCode) return false;
    notifyListeners();
    return true;
  }

  Future<void> fetchAndSetAuthToken(AuthProvider authProvider) async {
    _authToken = await authProvider.getAuthToken();
    notifyListeners();
  }

  String _getAuthToken() {
    final String? authToken = _authToken;
    if (authToken == null) {
      throw AppException(
        exceptionMessage: "Called CaseProvider without auth token.",
        exceptionType: ExceptionType.unexpectedNullValue,
      );
    }
    return authToken;
  }
}
