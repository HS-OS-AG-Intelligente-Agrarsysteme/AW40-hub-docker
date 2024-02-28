import "dart:async";
import "dart:convert";

import "package:aw40_hub_frontend/dtos/dtos.dart";
import "package:aw40_hub_frontend/exceptions/exceptions.dart";
import "package:aw40_hub_frontend/models/models.dart";
import "package:aw40_hub_frontend/providers/providers.dart";
import "package:aw40_hub_frontend/services/services.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:http/http.dart";
import "package:logging/logging.dart";

class DiagnosisProvider with ChangeNotifier {
  DiagnosisProvider(this._httpService);
  final HttpService _httpService;

  final Logger _logger = Logger("diagnosis_provider");
  late final String workShopId;
  String? _authToken;

  Future<List<DiagnosisModel>> getDiagnoses(List<CaseModel> cases) async {
    // * Easy way of testing UI for now.
    // return <DiagnosisModel>[
    //   DiagnosisModel(
    //     id: "1",
    //     timestamp: DateTime.now(),
    //     status: DiagnosisStatus.action_required,
    //     caseId: "1",
    //     stateMachineLog: [],
    //     todos: [
    //       ActionModel(
    //         id: "1",
    //         instruction: "Laden Sie OBD-Daten hoch",
    //         actionType: "",
    //         dataType: "",
    //         component: "",
    //       )
    //     ],
    //   ),
    //   DiagnosisModel(
    //     id: "2",
    //     timestamp: DateTime.now(),
    //     status: DiagnosisStatus.scheduled,
    //     caseId: "2",
    //     stateMachineLog: [],
    //     todos: [],
    //   ),
    //   DiagnosisModel(
    //     id: "3",
    //     timestamp: DateTime.now(),
    //     status: DiagnosisStatus.processing,
    //     caseId: "3",
    //     stateMachineLog: [],
    //     todos: [],
    //   ),
    //   DiagnosisModel(
    //     id: "4",
    //     timestamp: DateTime.now(),
    //     status: DiagnosisStatus.finished,
    //     caseId: "4",
    //     stateMachineLog: [],
    //     todos: [],
    //   ),
    //   DiagnosisModel(
    //     id: "5",
    //     timestamp: DateTime.now(),
    //     status: DiagnosisStatus.failed,
    //     caseId: "5",
    //     stateMachineLog: [],
    //     todos: [],
    //   ),
    // ];

    final List<String> caseIDs = cases
        .where((c) => c.workshopId == workShopId)
        .map((e) => e.id)
        .toList();

    final List<Future<DiagnosisModel?>> individualDiagnosisRequests =
        caseIDs.map(getDiagnosis).toList();

    final List<DiagnosisModel?> diagnoses =
        await Future.wait(individualDiagnosisRequests);

    return diagnoses.whereNotNull().toList();
  }

  Future<DiagnosisModel?> getDiagnosis(String caseId) async {
    final String authToken = _getAuthToken();
    final Response response =
        await _httpService.getDiagnosis(authToken, workShopId, caseId);
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      _logger.warning(
        "Could not get diagnosis. "
        "${response.statusCode}: ${response.reasonPhrase}",
      );
      return null;
    }

    return _decodeDiagnosisModelFromResponseBody(response);
  }

  Future<DiagnosisModel?> startDiagnosis(String caseId) async {
    final String authToken = _getAuthToken();
    final Response response =
        await _httpService.startDiagnosis(authToken, workShopId, caseId);
    if (response.statusCode != 201) {
      _logger.warning(
        "Could not start diagnosis. "
        "${response.statusCode}: ${response.reasonPhrase}",
      );
      return null;
    }

    notifyListeners();
    return _decodeDiagnosisModelFromResponseBody(response);
  }

  Future<bool> deleteDiagnosis(String caseId) async {
    final String authToken = _getAuthToken();
    final Response response =
        await _httpService.deleteDiagnosis(authToken, workShopId, caseId);
    if (response.statusCode != 200) {
      _logger.warning(
        "Could not delete diagnosis. "
        "${response.statusCode}: ${response.reasonPhrase}",
      );
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<bool> uploadObdData(String caseId, NewOBDDataDto obdDataDto) async {
    final String authToken = _getAuthToken();
    final Map<String, dynamic> obdDataJson = obdDataDto.toJson();
    final Response response = await _httpService.uploadObdData(
      authToken,
      workShopId,
      caseId,
      obdDataJson,
    );
    if (response.statusCode != 201) {
      _logger.warning(
        "Could not upload obd data. "
        "${response.statusCode}: ${response.reasonPhrase}",
      );
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<bool> uploadPicoscopeData(
    String caseId,
    List<int> picoscopeData,
    String filename,
  ) async {
    final String authToken = _getAuthToken();
    final Response response = await _httpService.uploadPicoscopeData(
      authToken,
      workShopId,
      caseId,
      picoscopeData,
      filename,
    );
    if (response.statusCode != 201) {
      _logger.warning(
        "Could not upload picoscope data. "
        "${response.statusCode}: ${response.reasonPhrase}",
      );
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<bool> uploadSymtomData(String caseId, NewSymptomDto symptomDto) async {
    final String authToken = _getAuthToken();
    final Map<String, dynamic> symptomDataJson = symptomDto.toJson();
    final Response response = await _httpService.uploadSymtomData(
      authToken,
      workShopId,
      caseId,
      symptomDataJson,
    );
    if (response.statusCode != 201) {
      _logger.warning(
        "Could not upload symptom data. "
        "${response.statusCode}: ${response.reasonPhrase}",
      );
      return false;
    }

    notifyListeners();
    return true;
  }

  DiagnosisModel? _decodeDiagnosisModelFromResponseBody(Response response) {
    final decodedJson = jsonDecode(response.body);
    if (decodedJson is! Map<String, dynamic>) return null;
    final Map<String, dynamic> body = decodedJson;
    final DiagnosisDto diagnosisDto = DiagnosisDto.fromJson(body);
    return diagnosisDto.toModel();
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
