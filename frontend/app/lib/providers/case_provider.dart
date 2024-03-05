import "dart:convert";

import "package:aw40_hub_frontend/dtos/dtos.dart";
import "package:aw40_hub_frontend/exceptions/exceptions.dart";
import "package:aw40_hub_frontend/models/models.dart";
import "package:aw40_hub_frontend/providers/auth_provider.dart";
import "package:aw40_hub_frontend/services/services.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
import "package:flutter/material.dart";
import "package:http/http.dart";
import "package:logging/logging.dart";

class CaseProvider with ChangeNotifier {
  CaseProvider(this._httpService);
  final HttpService _httpService;

  final Logger _logger = Logger("case_provider");
  late String workShopId;
  bool _showSharedCases = true;
  bool get showSharedCases => _showSharedCases;
  String? _authToken;

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
      response = await _httpService.getSharedCases(authToken);
    } else {
      response = await _httpService.getCases(authToken, workShopId);
    }
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      201,
      "Could not get ${_showSharedCases ? 'shared ' : ''}cases. "
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
        await _httpService.addCase(authToken, workShopId, newCaseJson);
    HelperService.verifyStatusCode(
      response.statusCode,
      201,
      "Could not add case. ",
      response,
      _logger,
    );

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
      workShopId,
      caseId,
      updateCaseJson,
    );
    HelperService.verifyStatusCode(
      response.statusCode,
      200,
      "Could not update case. ",
      response,
      _logger,
    );
    notifyListeners();
    return _decodeCaseModelFromResponseBody(response);
  }

  Future<bool> deleteCase(String caseId) async {
    final String authToken = _getAuthToken();
    final Response response =
        await _httpService.deleteCase(authToken, workShopId, caseId);
    HelperService.verifyStatusCode(
      response.statusCode,
      200,
      "Could not delete case. ",
      response,
      _logger,
    );
    notifyListeners();
    return true;
  }

  Future<void> sortCases() async {
    _logger.warning("Unimplemented: sortCases()");
  }

  Future<void> filterCases() async {
    // Klasse FilterCriteria mit Feld fuer jedes Filterkriterium.
    // Aktuelle Filter werden durch Zustand einer FilterCriteria Instanz
    // definiert.
    _logger.warning("Unimplemented: filterCases()");
  }

  Future<void> fetchAndSetAuthToken(AuthProvider authProvider) async {
    _authToken = await authProvider.getAuthToken();
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
