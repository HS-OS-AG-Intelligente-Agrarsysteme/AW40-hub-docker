import "dart:convert";

import "package:aw40_hub_frontend/dtos/dtos.dart";
import "package:aw40_hub_frontend/models/models.dart";
import "package:aw40_hub_frontend/services/services.dart";
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
  int? lastModifiedCaseIndex;

  Future<void> toggleShowSharedCases() async {
    _showSharedCases = !_showSharedCases;
    await getCurrentCases();
    notifyListeners();
  }

  Future<List<CaseModel>> getCurrentCases() async {
    // * Return value currently not used.
    final Response response;
    if (_showSharedCases) {
      response = await _httpService.getSharedCases();
    } else {
      response = await _httpService.getCases(workShopId);
    }
    if (response.statusCode != 200) {
      _logger.warning(
        "Could not get ${_showSharedCases ? 'shared ' : ''}cases. "
        "${response.statusCode}: ${response.reasonPhrase}",
      );
      return [];
    }
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
    final Map<String, dynamic> newCaseJson = newCaseDto.toJson();
    final Response response =
        await _httpService.addCase(workShopId, newCaseJson);
    if (response.statusCode != 201) {
      _logger.warning(
        "Could not add case. "
        "${response.statusCode}: ${response.reasonPhrase}",
      );
      return null;
    }

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
    final Map<String, dynamic> updateCaseJson = updateCaseDto.toJson();
    final Response response =
        await _httpService.updateCase(workShopId, caseId, updateCaseJson);
    if (response.statusCode != 200) {
      _logger.warning(
        "Could not update case. "
        "${response.statusCode}: ${response.reasonPhrase}",
      );
      return null;
    }

    notifyListeners();
    return _decodeCaseModelFromResponseBody(response);
  }

  Future<bool> deleteCase(String caseId) async {
    final Response response = await _httpService.deleteCase(workShopId, caseId);
    if (response.statusCode != 200) {
      _logger.warning(
        "Could not delete case. "
        "${response.statusCode}: ${response.reasonPhrase}",
      );
      return false;
    }

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
}
