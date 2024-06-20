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
    // Explicitly ignored lines_longer_than_80_chars lint rule, because this is
    // not actual code.
    // return <DiagnosisModel>[
    //   DiagnosisModel(
    //     id: const Uuid().v4(),
    //     timestamp: DateTime.now(),
    //     status: DiagnosisStatus.action_required,
    //     caseId: const Uuid().v4(),
    //     stateMachineLog: [
    //       StateMachineLogEntryModel(
    //         message: "STATE_TRANSITION: REC_VEHICLE_AND_PROC_METADATA --- "
    //             "(processed_metadata) ---> PROC_CUSTOMER_COMPLAINTS",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message: "STATE_TRANSITION: PROC_CUSTOMER_COMPLAINTS --- "
    //             "(no_complaints) ---> "
    //             "READ_OBD_DATA_AND_GEN_ONTOLOGY_INSTANCES",
    //         attachment: null,
    //       ),
    //
    //     ],
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
    //     id: const Uuid().v4(),
    //     timestamp: DateTime.now(),
    //     status: DiagnosisStatus.scheduled,
    //     caseId: const Uuid().v4(),
    //     stateMachineLog: [],
    //     todos: [],
    //   ),
    //   DiagnosisModel(
    //     id: const Uuid().v4(),
    //     timestamp: DateTime.now(),
    //     status: DiagnosisStatus.processing,
    //     caseId: const Uuid().v4(),
    //     stateMachineLog: [
    //       StateMachineLogEntryModel(
    //         message: "STATE_TRANSITION: REC_VEHICLE_AND_PROC_METADATA --- "
    //             "(processed_metadata) ---> PROC_CUSTOMER_COMPLAINTS",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message: "STATE_TRANSITION: PROC_CUSTOMER_COMPLAINTS --- "
    //             "(no_complaints) ---> "
    //             "READ_OBD_DATA_AND_GEN_ONTOLOGY_INSTANCES",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message: "RETRIEVED_DATASET: obd_data/0",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message:
    //         "STATE_TRANSITION: READ_OBD_DATA_AND_GEN_ONTOLOGY_INSTANCES "
    //             "--- (processed_OBD_data) ---> RETRIEVE_HISTORICAL_DATA",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message: "STATE_TRANSITION: RETRIEVE_HISTORICAL_DATA --- "
    //             "(processed_all_data) ---> ESTABLISH_INITIAL_HYPOTHESIS",
    //         attachment: null,
    //       ),
    //
    //     ],
    //     todos: [],
    //   ),
    //   DiagnosisModel(
    //     id: const Uuid().v4(),
    //     timestamp: DateTime.now(),
    //     status: DiagnosisStatus.finished,
    //     caseId: const Uuid().v4(),
    //     stateMachineLog: [
    //       StateMachineLogEntryModel(
    //         message: "STATE_TRANSITION: REC_VEHICLE_AND_PROC_METADATA --- "
    //             "(processed_metadata) ---> PROC_CUSTOMER_COMPLAINTS",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message: "STATE_TRANSITION: PROC_CUSTOMER_COMPLAINTS --- "
    //             "(no_complaints) ---> "
    //             "READ_OBD_DATA_AND_GEN_ONTOLOGY_INSTANCES",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message: "RETRIEVED_DATASET: obd_data/0",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message:
    //             "STATE_TRANSITION: READ_OBD_DATA_AND_GEN_ONTOLOGY_INSTANCES "
    //             "--- (processed_OBD_data) ---> RETRIEVE_HISTORICAL_DATA",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message: "STATE_TRANSITION: RETRIEVE_HISTORICAL_DATA --- "
    //             "(processed_all_data) ---> ESTABLISH_INITIAL_HYPOTHESIS",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message: "STATE_TRANSITION: ESTABLISH_INITIAL_HYPOTHESIS --- "
    //             "(established_init_hypothesis) ---> DIAGNOSIS",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message: "STATE_TRANSITION: "
    //             "SELECT_BEST_UNUSED_ERROR_CODE_INSTANCE "
    //             "--- (no_matching_selected_best_instance) ---> "
    //             "SUGGEST_SUSPECT_COMPONENTS",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message: "STATE_TRANSITION: SUGGEST_SUSPECT_COMPONENTS --- "
    //             "(provided_suggestions) ---> CLASSIFY_COMPONENTS",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message: "RETRIEVED_DATASET: timeseries_data/0",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message: "HEATMAPS: boost_pressure_control_valve "
    //             "[ANOMALY - SCORE: 0.0029614063]",
    //         attachment: "666abcf93d9fdf79fb6c11b5",
    //       ),
    //       StateMachineLogEntryModel(
    //         message: "STATE_TRANSITION: CLASSIFY_COMPONENTS --- "
    //             "(detected_anomalies) ---> "
    //             "ISOLATE_PROBLEM_CHECK_EFFECTIVE_RADIUS",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message: "CAUSAL_GRAPH_VISUALIZATIONS: 0",
    //         attachment: "666abcfa3d9fdf79fb6c11b7",
    //       ),
    //       StateMachineLogEntryModel(
    //         message: "RETRIEVED_DATASET: symptoms/0",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message: "CAUSAL_GRAPH_VISUALIZATIONS: 0",
    //         attachment: "666abcfa3d9fdf79fb6c11b9",
    //       ),
    //       StateMachineLogEntryModel(
    //         message: "STATE_TRANSITION: "
    //             "ISOLATE_PROBLEM_CHECK_EFFECTIVE_RADIUS --- "
    //             "(isolated_problem) ---> PROVIDE_DIAG_AND_SHOW_TRACE",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message: "FAULT_PATHS: ['boost_pressure_solenoid_valve -> "
    //             "boost_pressure_control_valve']",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message: "STATE_TRANSITION: PROVIDE_DIAG_AND_SHOW_TRACE --- "
    //             "(uploaded_diag) ---> diag",
    //         attachment: null,
    //       )
    //     ],
    //     todos: [],
    //   ),
    //   DiagnosisModel(
    //     id: const Uuid().v4(),
    //     timestamp: DateTime.now(),
    //     status: DiagnosisStatus.failed,
    //     caseId: const Uuid().v4(),
    //     stateMachineLog: [
    //       StateMachineLogEntryModel(
    //         message:
    // ignore: lines_longer_than_80_chars
    //             "STATE_TRANSITION: REC_VEHICLE_AND_PROC_METADATA --- (processed_metadata) ---> PROC_CUSTOMER_COMPLAINTS",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message:
    // ignore: lines_longer_than_80_chars
    //             "STATE_TRANSITION: PROC_CUSTOMER_COMPLAINTS --- (no_complaints) ---> READ_OBD_DATA_AND_GEN_ONTOLOGY_INSTANCES",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message: "RETRIEVED_DATASET: obd_data/0",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message:
    // ignore: lines_longer_than_80_chars
    //             "STATE_TRANSITION: READ_OBD_DATA_AND_GEN_ONTOLOGY_INSTANCES --- (processed_OBD_data) ---> RETRIEVE_HISTORICAL_DATA",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message:
    // ignore: lines_longer_than_80_chars
    //             "STATE_TRANSITION: RETRIEVE_HISTORICAL_DATA --- (processed_all_data) ---> ESTABLISH_INITIAL_HYPOTHESIS",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message:
    // ignore: lines_longer_than_80_chars
    //             "STATE_TRANSITION: ESTABLISH_INITIAL_HYPOTHESIS --- (established_init_hypothesis) ---> DIAGNOSIS",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message:
    // ignore: lines_longer_than_80_chars
    //             "STATE_TRANSITION: SELECT_BEST_UNUSED_ERROR_CODE_INSTANCE --- (no_matching_selected_best_instance) ---> SUGGEST_SUSPECT_COMPONENTS",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message:
    // ignore: lines_longer_than_80_chars
    //             "STATE_TRANSITION: SUGGEST_SUSPECT_COMPONENTS --- (provided_suggestions) ---> CLASSIFY_COMPONENTS",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message: "RETRIEVED_DATASET: timeseries_data/0",
    //         attachment: null,
    //       ),
    //       StateMachineLogEntryModel(
    //         message:
    // ignore: lines_longer_than_80_chars
    //             "DIAGNOSIS_FAILED: Unexpected error during execution of the state machine.",
    //         attachment: null,
    //       )
    //     ],
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
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      200,
      "Could not get diagnosis. ",
      response,
      _logger,
    );
    if (!verifyStatusCode) return null;
    return _decodeDiagnosisModelFromResponseBody(response);
  }

  Future<DiagnosisModel?> startDiagnosis(String caseId) async {
    final String authToken = _getAuthToken();
    final Response response =
        await _httpService.startDiagnosis(authToken, workShopId, caseId);
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      201,
      "Could not start diagnosis. ",
      response,
      _logger,
    );
    if (!verifyStatusCode) return null;
    notifyListeners();
    return _decodeDiagnosisModelFromResponseBody(response);
  }

  Future<bool> deleteDiagnosis(String caseId) async {
    final String authToken = _getAuthToken();
    final Response response =
        await _httpService.deleteDiagnosis(authToken, workShopId, caseId);
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      200,
      "Could not delete diagnosis. ",
      response,
      _logger,
    );
    if (!verifyStatusCode) return false;
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
      // TODO: Add optional parameters.
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

  Future<bool> uploadSymtomData(String caseId, NewSymptomDto symptomDto) async {
    final String authToken = _getAuthToken();
    final Map<String, dynamic> symptomDataJson = symptomDto.toJson();
    final Response response = await _httpService.uploadSymptomData(
      authToken,
      workShopId,
      caseId,
      symptomDataJson,
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
