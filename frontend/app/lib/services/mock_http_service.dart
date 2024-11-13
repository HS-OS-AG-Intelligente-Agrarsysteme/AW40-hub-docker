// ignore_for_file: avoid_catching_errors
import "dart:convert";

import "package:aw40_hub_frontend/dtos/action_dto.dart";
import "package:aw40_hub_frontend/dtos/case_dto.dart";
import "package:aw40_hub_frontend/dtos/case_update_dto.dart";
import "package:aw40_hub_frontend/dtos/customer_dto.dart";
import "package:aw40_hub_frontend/dtos/diagnosis_dto.dart";
import "package:aw40_hub_frontend/dtos/new_case_dto.dart";
import "package:aw40_hub_frontend/dtos/new_obd_data_dto.dart";
import "package:aw40_hub_frontend/dtos/new_symptom_dto.dart";
import "package:aw40_hub_frontend/dtos/obd_data_dto.dart";
import "package:aw40_hub_frontend/dtos/state_machine_log_entry_dto.dart";
import "package:aw40_hub_frontend/dtos/symptom_dto.dart";
import "package:aw40_hub_frontend/dtos/timeseries_data_dto.dart";
import "package:aw40_hub_frontend/dtos/vehicle_dto.dart";
import "package:aw40_hub_frontend/services/helper_service.dart";
import "package:aw40_hub_frontend/services/http_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:http/http.dart" show Response;
import "package:logging/logging.dart";

class MockHttpService implements HttpService {
  MockHttpService() {
    _caseDtos.insert(0, _demoCaseDto);
    final List<CaseDto> allCaseDtos = _caseDtos + _sharedCaseDtos;
    final Iterable<String> caseIds = allCaseDtos.map((c) => c.id);
    final Iterable<String> duplicateCaseIds =
        HelperService.getDuplicates(caseIds);
    if (duplicateCaseIds.isNotEmpty) {
      // Throw an error and log the duplicate case IDs.
      throw StateError(
        "Case IDs must be unique. Found duplicate IDs: $duplicateCaseIds",
      );
    }
  }

  final Logger _logger = Logger("MockHttpService");

  /// The interval for demo diagnosis transition in milliseconds.
  /// Non-final for testing purposes.
  int diagnosisTransitionInterval = 5000;

  /// Delay in milliseconds before returned Futures complete.
  /// Non-final for testing purposes.
  int delay = 100;

  // ID of the demo case, this is public to make testing easier.
  static const String demoCaseId = "00000000-0000-0000-0000-000000000000";
  int _demoDiagnosisStage = 0;
  final DiagnosisDto _demoDiagnosisDto = DiagnosisDto(
    "11111111-1111-1111-1111-111111111111",
    DateTime.utc(1921, 1, 21),
    DiagnosisStatus.scheduled,
    demoCaseId,
    [],
    [],
  );
  final CaseDto _demoCaseDto = CaseDto(
    demoCaseId,
    DateTime.utc(2021, 1, 21, 12, 0, 8),
    CaseOccasion.problem_defect,
    100,
    CaseStatus.open,
    "Linda de Mo",
    "12345678901234567",
    "workshop_id",
    null,
    [],
    [],
    [],
    0,
    0,
    0,
  );

  final List<DiagnosisDto> _diagnosisDtos = [
    // scheduled
    DiagnosisDto(
      "1",
      DateTime.utc(2018, 3, 28),
      DiagnosisStatus.scheduled,
      "2",
      [],
      [],
    ),
    // processing
    DiagnosisDto(
      "2",
      DateTime.utc(2018, 3, 28),
      DiagnosisStatus.processing,
      "3",
      [],
      [],
    ),
    // finished
    DiagnosisDto(
      "3",
      DateTime.utc(2018, 3, 28),
      DiagnosisStatus.finished,
      "5",
      [
        StateMachineLogEntryDto(
          "STATE_TRANSITION: REC_VEHICLE_AND_PROC_METADATA --- "
          "(processed_metadata) ---> PROC_CUSTOMER_COMPLAINTS",
          null,
        ),
        StateMachineLogEntryDto(
          "STATE_TRANSITION: PROC_CUSTOMER_COMPLAINTS --- "
          "(no_complaints) ---> "
          "READ_OBD_DATA_AND_GEN_ONTOLOGY_INSTANCES",
          null,
        ),
        StateMachineLogEntryDto(
          "RETRIEVED_DATASET: obd_data/0",
          null,
        ),
        StateMachineLogEntryDto(
          "STATE_TRANSITION: READ_OBD_DATA_AND_GEN_ONTOLOGY_INSTANCES "
          "--- (processed_OBD_data) ---> RETRIEVE_HISTORICAL_DATA",
          null,
        ),
        StateMachineLogEntryDto(
          "STATE_TRANSITION: RETRIEVE_HISTORICAL_DATA --- "
          "(processed_all_data) ---> ESTABLISH_INITIAL_HYPOTHESIS",
          null,
        ),
        StateMachineLogEntryDto(
          "STATE_TRANSITION: ESTABLISH_INITIAL_HYPOTHESIS --- "
          "(established_init_hypothesis) ---> DIAGNOSIS",
          null,
        ),
        StateMachineLogEntryDto(
          "STATE_TRANSITION: "
          "SELECT_BEST_UNUSED_ERROR_CODE_INSTANCE "
          "--- (no_matching_selected_best_instance) ---> "
          "SUGGEST_SUSPECT_COMPONENTS",
          null,
        ),
        StateMachineLogEntryDto(
          "STATE_TRANSITION: SUGGEST_SUSPECT_COMPONENTS --- "
          "(provided_suggestions) ---> CLASSIFY_COMPONENTS",
          null,
        ),
        StateMachineLogEntryDto(
          "RETRIEVED_DATASET: timeseries_data/0",
          null,
        ),
        StateMachineLogEntryDto(
          "HEATMAPS: boost_pressure_control_valve "
              "[ANOMALY - SCORE: 0.0029614063]",
          "666abcf93d9fdf79fb6c11b5",
        ),
        StateMachineLogEntryDto(
          "STATE_TRANSITION: CLASSIFY_COMPONENTS --- "
          "(detected_anomalies) ---> "
          "ISOLATE_PROBLEM_CHECK_EFFECTIVE_RADIUS",
          null,
        ),
        StateMachineLogEntryDto(
          "CAUSAL_GRAPH_VISUALIZATIONS: 0",
          "666abcfa3d9fdf79fb6c11b7",
        ),
        StateMachineLogEntryDto(
          "RETRIEVED_DATASET: symptoms/0",
          null,
        ),
        StateMachineLogEntryDto(
          "CAUSAL_GRAPH_VISUALIZATIONS: 0",
          "666abcfa3d9fdf79fb6c11b9",
        ),
        StateMachineLogEntryDto(
          "STATE_TRANSITION: "
          "ISOLATE_PROBLEM_CHECK_EFFECTIVE_RADIUS --- "
          "(isolated_problem) ---> PROVIDE_DIAG_AND_SHOW_TRACE",
          null,
        ),
        StateMachineLogEntryDto(
          "FAULT_PATHS: ['boost_pressure_solenoid_valve -> "
          "boost_pressure_control_valve']",
          null,
        ),
        StateMachineLogEntryDto(
          "STATE_TRANSITION: PROVIDE_DIAG_AND_SHOW_TRACE --- "
          "(uploaded_diag) ---> diag",
          null,
        )
      ],
      [],
    ),
    // failed
    DiagnosisDto(
      "4",
      DateTime.utc(2018, 3, 28),
      DiagnosisStatus.failed,
      "6",
      [],
      [],
    ),
    // action_required, obd
    DiagnosisDto(
      "5",
      DateTime.utc(2018, 3, 28),
      DiagnosisStatus.action_required,
      "4",
      [],
      [
        ActionDto(
          "1",
          "Upload OBD data.",
          "add_data",
          DatasetType.obd,
          "some component",
        ),
      ],
    ),
    // action_required, timeseries
    DiagnosisDto(
      "6",
      DateTime.utc(2018, 3, 28),
      DiagnosisStatus.action_required,
      "8",
      [],
      [
        ActionDto(
          "1",
          "Upload Timeseries data.",
          "add_data",
          DatasetType.timeseries,
          "some component",
        ),
      ],
    ),
    // action_required, symptom
    DiagnosisDto(
      "7",
      DateTime.utc(2018, 3, 28),
      DiagnosisStatus.action_required,
      "9",
      [],
      [
        ActionDto(
          "1",
          "Upload Symptom data.",
          "add_data",
          DatasetType.symptom,
          "some component",
        ),
      ],
    ),
    // action_required, unknown
    DiagnosisDto(
      "8",
      DateTime.utc(2018, 3, 28),
      DiagnosisStatus.action_required,
      "480",
      [],
      [
        ActionDto(
          "1",
          "Upload unknown data. This is a purposefully faulty mock diagnosis",
          "add_data",
          DatasetType.unknown,
          "some component",
        ),
      ],
    ),
    // action_required, null
    DiagnosisDto(
      "8",
      DateTime.utc(2018, 3, 28),
      DiagnosisStatus.action_required,
      "240",
      [],
      [],
    ),
  ];
  final List<CaseDto> _caseDtos = [
    // Case for diagnosis status scheduled.
    // No data sets.
    CaseDto(
      "2",
      DateTime.utc(2021, 1, 21, 12, 0, 8),
      CaseOccasion.problem_defect,
      100,
      CaseStatus.open,
      "unknown",
      "12345678901234567",
      "workshop_id",
      "1",
      [],
      [],
      [],
      0,
      0,
      0,
    ),
    // Case for diagnosis status processing.
    // Obd data.
    CaseDto(
      "3",
      DateTime.utc(2021, 1, 21, 12, 0, 8),
      CaseOccasion.problem_defect,
      100,
      CaseStatus.open,
      "unknown",
      "12345678901234567",
      "workshop_id",
      "2",
      [],
      [
        ObdDataDto(
          DateTime.utc(2021, 1, 21, 12, 41, 24),
          [0],
          ["P0001", "P0002", "P0003"],
          42,
        ),
        ObdDataDto(
          DateTime.utc(2021, 1, 21, 12, 44, 24),
          ["could literally be anything"],
          ["P0004", "P0005", "P0006"],
          2479,
        ),
      ],
      [],
      0,
      0,
      0,
    ),
    // Case for diagnosis status action_required, obd.
    // Timeseries data.
    CaseDto(
      "4",
      DateTime.utc(2021, 1, 21, 12, 0, 8),
      CaseOccasion.problem_defect,
      100,
      CaseStatus.open,
      "unknown",
      "12345678901234567",
      "workshop_id",
      "5",
      [
        TimeseriesDataDto(
          DateTime.utc(2021, 1, 21, 13, 21, 35),
          "component",
          TimeseriesDataLabel.anomaly,
          29,
          2957,
          TimeseriesType.oscillogram,
          "device_specs",
          42,
          "signal_id",
        ),
        TimeseriesDataDto(
          DateTime.utc(2021, 1, 21, 13, 24, 35),
          "component",
          TimeseriesDataLabel.norm,
          8,
          29,
          TimeseriesType.oscillogram,
          "other_device_specs",
          7248394,
          "another_signal_id",
        ),
      ],
      [],
      [],
      0,
      0,
      0,
    ),
    // Case for diagnosis status action_required, timeseries.
    CaseDto(
      "8",
      DateTime.utc(2021, 1, 21, 12, 0, 8),
      CaseOccasion.problem_defect,
      100,
      CaseStatus.open,
      "unknown",
      "12345678901234567",
      "workshop_id",
      "6",
      [],
      [],
      [],
      0,
      0,
      0,
    ),
    // Case for diagnosis status action_required, symptom.
    CaseDto(
      "9",
      DateTime.utc(2021, 1, 21, 12, 0, 8),
      CaseOccasion.problem_defect,
      100,
      CaseStatus.open,
      "unknown",
      "12345678901234567",
      "workshop_id",
      "7",
      [],
      [],
      [],
      0,
      0,
      0,
    ),
    // Case for diagnosis status finished.
    // Symptom data.
    CaseDto(
      "5",
      DateTime.utc(2021, 1, 21, 12, 0, 8),
      CaseOccasion.problem_defect,
      100,
      CaseStatus.open,
      "unknown",
      "12345678901234567",
      "workshop_id",
      "3",
      [],
      [],
      [
        SymptomDto(
          DateTime.utc(2021, 1, 21, 13, 21, 35),
          "component",
          SymptomLabel.defect,
          29,
        ),
        SymptomDto(
          DateTime.utc(2021, 1, 21, 13, 24, 19),
          "component",
          SymptomLabel.ok,
          25823473,
        ),
      ],
      0,
      0,
      0,
    ),
    // Case for diagnosis status failed.
    // All data set types.
    CaseDto(
      "6",
      DateTime.utc(2021, 1, 21, 12, 0, 8),
      CaseOccasion.problem_defect,
      100,
      CaseStatus.open,
      "unknown",
      "12345678901234567",
      "workshop_id",
      "4",
      [
        TimeseriesDataDto(
          DateTime.utc(2021, 1, 21, 13, 21, 35),
          "component",
          TimeseriesDataLabel.anomaly,
          29,
          2957,
          TimeseriesType.oscillogram,
          "device_specs",
          42,
          "signal_id",
        ),
        TimeseriesDataDto(
          DateTime.utc(2021, 1, 21, 13, 24, 35),
          "component",
          TimeseriesDataLabel.norm,
          8,
          29,
          TimeseriesType.oscillogram,
          "other_device_specs",
          7248394,
          "another_signal_id",
        ),
      ],
      [
        ObdDataDto(
          DateTime.utc(2021, 1, 21, 12, 41, 24),
          [0],
          ["P0001", "P0002", "P0003"],
          42,
        ),
        ObdDataDto(
          DateTime.utc(2021, 1, 21, 12, 44, 24),
          ["could literally be anything"],
          ["P0004", "P0005", "P0006"],
          2479,
        ),
      ],
      [
        SymptomDto(
          DateTime.utc(2021, 1, 21, 13, 21, 35),
          "component",
          SymptomLabel.defect,
          29,
        ),
        SymptomDto(
          DateTime.utc(2021, 1, 21, 13, 24, 19),
          "component",
          SymptomLabel.ok,
          25823473,
        ),
      ],
      0,
      0,
      0,
    ),
    // Case without diagnosis
    // No data sets
    CaseDto(
      "7",
      DateTime.utc(2021, 1, 21, 12, 0, 8),
      CaseOccasion.problem_defect,
      100,
      CaseStatus.closed,
      "unknown",
      "12345678901234567",
      "workshop_id",
      null,
      [],
      [],
      [],
      0,
      0,
      0,
    )
  ];
  final List<CaseDto> _sharedCaseDtos = [
    CaseDto(
      "11",
      DateTime.utc(2021, 1, 21, 12, 0, 8),
      CaseOccasion.problem_defect,
      100,
      CaseStatus.open,
      "unknown",
      "12345678901234567",
      "other_workshop_id",
      "6",
      [],
      [],
      [],
      0,
      0,
      0,
    ),
    // Case for diagnosis status action_required, symptom.
    CaseDto(
      "12",
      DateTime.utc(2021, 1, 21, 12, 0, 8),
      CaseOccasion.problem_defect,
      100,
      CaseStatus.open,
      "unknown",
      "12345678901234567",
      "other_workshop_id",
      "7",
      [],
      [],
      [],
      0,
      0,
      0,
    ),
    // Case for diagnosis status finished.
    // Symptom data.
    CaseDto(
      "13",
      DateTime.utc(2021, 1, 21, 12, 0, 8),
      CaseOccasion.problem_defect,
      100,
      CaseStatus.open,
      "unknown",
      "12345678901234567",
      "other_workshop_id",
      "3",
      [],
      [],
      [
        SymptomDto(
          DateTime.utc(2021, 1, 21, 13, 21, 35),
          "component",
          SymptomLabel.defect,
          29,
        ),
        SymptomDto(
          DateTime.utc(2021, 1, 21, 13, 24, 19),
          "component",
          SymptomLabel.ok,
          25823473,
        ),
      ],
      0,
      0,
      0,
    ),
    // Case for diagnosis status failed.
    // All data set types.
    CaseDto(
      "14",
      DateTime.utc(2021, 1, 21, 12, 0, 8),
      CaseOccasion.problem_defect,
      100,
      CaseStatus.open,
      "unknown",
      "12345678901234567",
      "other_workshop_id",
      "4",
      [
        TimeseriesDataDto(
          DateTime.utc(2021, 1, 21, 13, 21, 35),
          "component",
          TimeseriesDataLabel.anomaly,
          29,
          2957,
          TimeseriesType.oscillogram,
          "device_specs",
          42,
          "signal_id",
        ),
        TimeseriesDataDto(
          DateTime.utc(2021, 1, 21, 13, 24, 35),
          "component",
          TimeseriesDataLabel.norm,
          8,
          29,
          TimeseriesType.oscillogram,
          "other_device_specs",
          7248394,
          "another_signal_id",
        ),
      ],
      [
        ObdDataDto(
          DateTime.utc(2021, 1, 21, 12, 41, 24),
          [0],
          ["P0001", "P0002", "P0003"],
          42,
        ),
        ObdDataDto(
          DateTime.utc(2021, 1, 21, 12, 44, 24),
          ["could literally be anything"],
          ["P0004", "P0005", "P0006"],
          2479,
        ),
      ],
      [
        SymptomDto(
          DateTime.utc(2021, 1, 21, 13, 21, 35),
          "component",
          SymptomLabel.defect,
          29,
        ),
        SymptomDto(
          DateTime.utc(2021, 1, 21, 13, 24, 19),
          "component",
          SymptomLabel.ok,
          25823473,
        ),
      ],
      0,
      0,
      0,
    ),
    // Case without diagnosis
    // No data sets
    CaseDto(
      "15",
      DateTime.utc(2021, 1, 21, 12, 0, 8),
      CaseOccasion.problem_defect,
      100,
      CaseStatus.closed,
      "unknown",
      "12345678901234567",
      "other_workshop_id",
      null,
      [],
      [],
      [],
      0,
      0,
      0,
    )
  ];
  final List<CustomerDto> _customerDtos = [
    CustomerDto(
      "some_id",
      "some_firstname",
      "some_lastname",
      "some_email",
      "some_phone",
      "some_street",
      "some_housenumber",
      "some_postcode",
      "some_city",
    )
  ];
  final List<CustomerDto> _sharedCustomerDtos = [
    CustomerDto(
      "some_id",
      "some_firstname",
      "some_lastname",
      "some_email",
      "some_phone",
      "some_street",
      "some_housenumber",
      "some_postcode",
      "some_city",
    )
  ];

  Future<void> _demoDiagnosisStage0() async {
    if (_demoDiagnosisStage != 0) return;
    _demoDiagnosisStage++;
    _logger.info("Starting demo diagnosis with transition interval "
        "$diagnosisTransitionInterval ms. and delay $delay ms.");
    _demoCaseDto.diagnosisId = _demoDiagnosisDto.id;

    _logger.info(
      "Starting demo diagnosis stage 0 with transition interval "
      "$diagnosisTransitionInterval ms. and delay $delay ms.",
    );

    await Future.delayed(Duration(milliseconds: diagnosisTransitionInterval));
    _demoDiagnosisDto.status = DiagnosisStatus.action_required;
    _demoDiagnosisDto.todos = [
      ActionDto(
        "1",
        "some instruction",
        "some action type",
        DatasetType.obd,
        "some component",
      ),
    ];

    _logger.info(
      "Finished demo diagnosis stage 0."
      " status: ${_demoDiagnosisDto.status},"
      " todos: ${_demoDiagnosisDto.todos.length}",
    );
  }

  Future<void> _demoDiagnosisStage1() async {
    if (_demoDiagnosisStage != 1) return;
    _demoDiagnosisStage++;
    _demoDiagnosisDto.status = DiagnosisStatus.processing;

    _logger.info(
      "Starting demo diagnosis stage 1."
      " status: ${_demoDiagnosisDto.status.name},"
      " todos: ${_demoDiagnosisDto.todos.length}",
    );

    await Future.delayed(Duration(milliseconds: diagnosisTransitionInterval));
    _demoDiagnosisDto.status = DiagnosisStatus.action_required;
    _demoDiagnosisDto.todos = [
      ActionDto(
        "1",
        "some instruction",
        "some action type",
        DatasetType.timeseries,
        "some component",
      ),
    ];

    _logger.info(
      "Finished demo diagnosis stage 1."
      " status: ${_demoDiagnosisDto.status},"
      " todos: ${_demoDiagnosisDto.todos.length}",
    );
  }

  Future<void> _demoDiagnosisStage2() async {
    if (_demoDiagnosisStage != 2) return;
    _demoDiagnosisStage++;
    _demoDiagnosisDto.status = DiagnosisStatus.processing;
    await Future.delayed(Duration(milliseconds: diagnosisTransitionInterval));
    _demoDiagnosisDto.status = DiagnosisStatus.action_required;
    _demoDiagnosisDto.todos = [
      ActionDto(
        "1",
        "some instruction",
        "some action type",
        DatasetType.symptom,
        "some component",
      ),
    ];
  }

  Future<void> _demoDiagnosisStage3() async {
    if (_demoDiagnosisStage != 3) return;
    _demoDiagnosisStage++;
    _demoDiagnosisDto.status = DiagnosisStatus.processing;
    await Future.delayed(Duration(milliseconds: diagnosisTransitionInterval));
    _demoDiagnosisDto.status = DiagnosisStatus.finished;
  }

  @override
  Future<Response> addCase(
    String token,
    String workshopId,
    Map<String, dynamic> requestBody,
  ) {
    final NewCaseDto newCaseDto;
    try {
      newCaseDto = NewCaseDto.fromJson(requestBody);
    } on Error {
      return Future.delayed(
        Duration(milliseconds: delay),
        () => Response("", 422),
      );
    }
    final CaseDto caseDto = CaseDto(
      "1",
      DateTime.now(),
      newCaseDto.occasion,
      newCaseDto.milage,
      CaseStatus.open,
      newCaseDto.customerId,
      newCaseDto.vehicleVin,
      workshopId,
      null,
      [],
      [],
      [],
      0,
      0,
      0,
    );
    return Future.delayed(
      Duration(milliseconds: delay),
      () => Response(jsonEncode(caseDto.toJson()), 201),
    );
  }

  @override
  Future<Response> checkBackendHealth() {
    return Future.delayed(
      Duration(milliseconds: delay),
      () => Response('{"status": "success"}', 200),
    );
  }

  @override
  Future<Response> deleteCase(String token, String workshopId, String caseId) {
    return Future.delayed(
      Duration(milliseconds: delay),
      () => Response("", 200),
    );
  }

  @override
  Future<Response> deleteDiagnosis(
    String token,
    String workshopId,
    String caseId,
  ) {
    return Future.delayed(
      Duration(milliseconds: delay),
      () => Response("", 200),
    );
  }

  @override
  Map<String, String> getAuthHeaderWith(
    String token, [
    Map<String, String>? otherHeaders,
  ]) {
    // TODO: Make getAuthHeaderWith() private in HttpService, amend tests,
    //  remove this implementation
    throw UnsupportedError(
      "This method should never be called on MockHttpService",
    );
  }

  @override
  Future<Response> getCases(String token, String workshopId) {
    _demoCaseDto.workshopId = workshopId;
    for (final c in _caseDtos) {
      c.workshopId = workshopId;
    }
    return Future.delayed(
      Duration(milliseconds: delay),
      () =>
          Response(jsonEncode(_caseDtos.map((e) => e.toJson()).toList()), 200),
    );
  }

  @override
  Future<Response> getCasesByVehicleVin(
    String token,
    String workshopId,
    String vehicleVin,
  ) {
    // TODO implement getCasesByVehicleVin
    throw UnimplementedError();
  }

  @override
  Future<Response> getDiagnoses(String token, String workshopId) {
    final List<DiagnosisDto> diagnosisDtos = _demoDiagnosisStage > 0
        ? _diagnosisDtos + [_demoDiagnosisDto]
        : _diagnosisDtos;
    return Future.delayed(
      Duration(milliseconds: delay),
      () => Response(
        jsonEncode(diagnosisDtos.map((e) => e.toJson()).toList()),
        200,
      ),
    );
  }

  @override
  Future<Response> getDiagnosis(
    String token,
    String workshopId,
    String caseId,
  ) {
    final DiagnosisDto backupDiagnosisDto = DiagnosisDto(
      "1",
      DateTime.now(),
      DiagnosisStatus.processing,
      caseId,
      [],
      [],
    );
    final DiagnosisDto diagnosisDto = caseId == demoCaseId
        ? _demoDiagnosisDto
        : _diagnosisDtos.singleWhere(
            (element) => element.caseId == caseId,
            orElse: () {
              _logger.warning(
                "No diagnosis found for case $caseId."
                " Is this intended behavior?",
              );
              return backupDiagnosisDto;
            },
          );
    return Future.delayed(
      Duration(milliseconds: delay),
      () {
        return Response(jsonEncode(diagnosisDto.toJson()), 200);
      },
    );
  }

  @override
  Future<Response> getSharedCases(String token) {
    final List<CaseDto> caseDtos = _caseDtos + _sharedCaseDtos;
    return Future.delayed(
      Duration(milliseconds: delay),
      () => Response(jsonEncode(caseDtos.map((e) => e.toJson()).toList()), 200),
    );
  }

  @override
  Future<Response> getCustomer(
    String token,
    String workshopId,
    String caseId,
  ) {
    // ignore: lines_longer_than_80_chars
    // TODO maybe adjust regarding params in the future when getCustomer is used in the customer provider
    return Future.delayed(
      Duration(milliseconds: delay),
      () => Response(
        jsonEncode(_customerDtos.map((e) => e.toJson()).toList()),
        200,
      ),
    );
  }

  @override
  Future<Response> getSharedCustomers(String token) {
    final List<CustomerDto> customerDtos = _customerDtos + _sharedCustomerDtos;
    return Future.delayed(
      Duration(milliseconds: delay),
      () => Response(
        jsonEncode(customerDtos.map((e) => e.toJson()).toList()),
        200,
      ),
    );
  }

  @override
  Future<Response> startDiagnosis(
    String token,
    String workshopId,
    String caseId,
  ) {
    final DiagnosisDto diagnosisDto = DiagnosisDto(
      "1",
      DateTime.now(),
      DiagnosisStatus.processing,
      caseId,
      [],
      [],
    );
    if (caseId == demoCaseId) {
      return Future.delayed(
        Duration(milliseconds: delay),
        () {
          _demoDiagnosisStage0();
          return Response(jsonEncode(_demoDiagnosisDto.toJson()), 201);
        },
      );
    }
    return Future.delayed(
      Duration(milliseconds: delay),
      () => Response(jsonEncode(diagnosisDto.toJson()), 201),
    );
  }

  @override
  Future<Response> updateCase(
    String token,
    String workshopId,
    String caseId,
    Map<String, dynamic> requestBody,
  ) {
    final CaseUpdateDto caseUpdateDto;
    try {
      caseUpdateDto = CaseUpdateDto.fromJson(requestBody);
    } on Error {
      return Future.delayed(
        Duration(milliseconds: delay),
        () => Response("", 422),
      );
    }
    final CaseDto caseDto = CaseDto(
      caseId,
      caseUpdateDto.timestamp,
      caseUpdateDto.occasion,
      caseUpdateDto.milage,
      caseUpdateDto.status,
      "unknown",
      "12345678901234567",
      workshopId,
      null,
      [],
      [],
      [],
      0,
      0,
      0,
    );
    return Future.delayed(
      Duration(milliseconds: delay),
      () => Response(jsonEncode(caseDto.toJson()), 200),
    );
  }

  @override
  Future<Response> uploadObdData(
    String token,
    String workshopId,
    String caseId,
    Map<String, dynamic> requestBody,
  ) {
    final NewOBDDataDto newObdDataDto;
    try {
      newObdDataDto = NewOBDDataDto.fromJson(requestBody);
    } on Error {
      return Future.delayed(
        Duration(milliseconds: delay),
        () => Response("", 422),
      );
    }

    final ObdDataDto obdDataDto = ObdDataDto(
      DateTime.now(),
      newObdDataDto.obdSpecs,
      newObdDataDto.dtcs,
      29,
    );
    if (caseId == demoCaseId) {
      _demoCaseDto.obdData.add(
        obdDataDto,
      );
      return Future.delayed(
        Duration(milliseconds: delay),
        () {
          _demoDiagnosisStage1();
          return Response(jsonEncode(_demoCaseDto.toJson()), 201);
        },
      );
    }
    final CaseDto caseDto = CaseDto(
      caseId,
      DateTime.now(),
      CaseOccasion.problem_defect,
      47233,
      CaseStatus.open,
      "unknown",
      "12345678901234567",
      workshopId,
      null,
      [],
      [obdDataDto],
      [],
      0,
      0,
      0,
    );
    return Future.delayed(
      Duration(milliseconds: delay),
      () => Response(jsonEncode(caseDto.toJson()), 201),
    );
  }

  @override
  Future<Response> uploadOmniviewData(
    String token,
    String workshopId,
    String caseId,
    String component,
    int samplingRate,
    int duration,
    List<int> omniviewData,
    String filename,
  ) {
    _logger.warning(
      "OmniviewDto not implemented, not checking for potential"
      " validation errors.",
    );
    final CaseDto caseDto = CaseDto(
      caseId,
      DateTime.now(),
      CaseOccasion.problem_defect,
      47233,
      CaseStatus.open,
      "unknown",
      "12345678901234567",
      workshopId,
      null,
      [],
      [],
      [],
      0,
      0,
      0,
    );
    if (caseId == demoCaseId) {
      return Future.delayed(
        Duration(milliseconds: delay),
        () {
          _demoDiagnosisStage2();
          return Response(jsonEncode(_demoCaseDto.toJson()), 200);
        },
      );
    }
    return Future.delayed(
      Duration(milliseconds: delay),
      () => Response(jsonEncode(caseDto.toJson()), 201),
    );
  }

  @override
  Future<Response> uploadPicoscopeData(
    String token,
    String workshopId,
    String caseId,
    List<int> picoscopeData,
    String filename, {
    String? componentA,
    String? componentB,
    String? componentC,
    String? componentD,
    PicoscopeLabel? labelA,
    PicoscopeLabel? labelB,
    PicoscopeLabel? labelC,
    PicoscopeLabel? labelD,
  }) {
    _logger.warning(
      "PicoscopeDto not implemented, not checking for potential"
      " validation errors.",
    );
    final CaseDto caseDto = CaseDto(
      caseId,
      DateTime.now(),
      CaseOccasion.problem_defect,
      47233,
      CaseStatus.open,
      "unknown",
      "12345678901234567",
      workshopId,
      null,
      [],
      [],
      [],
      0,
      0,
      0,
    );
    if (caseId == demoCaseId) {
      return Future.delayed(
        Duration(milliseconds: delay),
        () {
          _demoDiagnosisStage2();
          return Response(jsonEncode(_demoCaseDto.toJson()), 201);
        },
      );
    }
    return Future.delayed(
      Duration(milliseconds: delay),
      () => Response(jsonEncode(caseDto.toJson()), 201),
    );
  }

  @override
  Future<Response> uploadSymptomData(
    String token,
    String workshopId,
    String caseId,
    String component,
    SymptomLabel label,
  ) {
    final NewSymptomDto newSymptomDto;
    //final Map<String, dynamic> requestBody = symptomDto.toJson();

    try {
      newSymptomDto = NewSymptomDto(
        component,
        label,
      );
    } on Error {
      return Future.delayed(
        Duration(milliseconds: delay),
        () => Response("", 422),
      );
    }

    final SymptomDto symptomDto = SymptomDto(
      DateTime.utc(2021, 2, 3),
      newSymptomDto.component,
      newSymptomDto.label,
      29,
    );
    final CaseDto caseDto = CaseDto(
      caseId,
      DateTime.now(),
      CaseOccasion.problem_defect,
      47233,
      CaseStatus.open,
      "unknown",
      "12345678901234567",
      workshopId,
      null,
      [],
      [],
      [symptomDto],
      0,
      0,
      0,
    );

    if (caseId == demoCaseId) {
      return Future.delayed(
        Duration(milliseconds: delay),
        () {
          _demoDiagnosisStage3();
          return Response(jsonEncode(_demoCaseDto.toJson()), 201);
        },
      );
    }
    return Future.delayed(
      Duration(milliseconds: delay),
      () => Response(jsonEncode(caseDto.toJson()), 201),
    );
  }

  @override
  Future<Response> uploadVcdsData(
    String token,
    String workshopId,
    String caseId,
    List<int> vcdsData,
    String filename,
  ) {
    _logger.warning(
      "actual method not implemented, not checking for potential"
      " validation errors.",
    );
    final ObdDataDto obdDataDto = ObdDataDto(
      DateTime.now(),
      [0],
      ["P0001", "P0002", "P0003"],
      29,
    );
    if (caseId == demoCaseId) {
      _demoCaseDto.obdData.add(obdDataDto);
      return Future.delayed(
        Duration(milliseconds: delay),
        () {
          _demoDiagnosisStage1();
          return Response(jsonEncode(_demoCaseDto.toJson()), 201);
        },
      );
    }
    final CaseDto caseDto = CaseDto(
      caseId,
      DateTime.now(),
      CaseOccasion.problem_defect,
      47233,
      CaseStatus.open,
      "unknown",
      "12345678901234567",
      workshopId,
      null,
      [],
      [obdDataDto],
      [],
      0,
      0,
      0,
    );
    return Future.delayed(
      Duration(milliseconds: delay),
      () => Response(jsonEncode(caseDto.toJson()), 201),
    );
  }

  @override
  Future<Response> addTimeseriesData(
    String token,
    String workshopId,
    String caseId,
    String component,
    TimeseriesDataLabel label,
    int samplingRate,
    int duration,
    List<int> signal,
  ) {
    _logger.warning(
      "TimeseriesData not implemented,",
      "not checking for potential validation errors.",
    );
    final CaseDto caseDto = CaseDto(
      caseId,
      DateTime.now(),
      CaseOccasion.problem_defect,
      47233,
      CaseStatus.open,
      "unknown",
      "12345678901234567",
      workshopId,
      null,
      [],
      [],
      [],
      0,
      0,
      0,
    );
    if (caseId == demoCaseId) {
      return Future.delayed(
        Duration(milliseconds: delay),
        () {
          _demoDiagnosisStage2();
          return Response(jsonEncode(_demoCaseDto.toJson()), 201);
        },
      );
    }
    return Future.delayed(
      Duration(milliseconds: delay),
      () => Response(jsonEncode(caseDto.toJson()), 201),
    );
  }

  @override
  Future<Response> getSharedVehicles(String token) {
    // TODO: implement getSharedVehicles
    throw UnimplementedError();
  }

  @override
  Future<Response> getVehicles(String token, String workshopId, String caseId) {
    const String id = "some_id";
    const String vin = "some_vin";
    const String tsn = "some_tsn";
    const int yearBuild = 2000;
    final List<VehicleDto> vehicleDtos = [
      VehicleDto(
        id,
        vin,
        tsn,
        yearBuild,
      )
    ];
    return Future.delayed(
      Duration(milliseconds: delay),
      () => Response(
        jsonEncode(vehicleDtos.map((e) => e.toJson()).toList()),
        200,
      ),
    );
  }

  @override
  Future<Response> updateVehicle(
    String token,
    String workshopId,
    String caseId,
    Map<String, dynamic> requestBody,
  ) {
    // TODO: implement updateVehicles
    throw UnimplementedError();
  }

  @override
  Future<Response> getCustomers(
    String token,
    int? page,
    int? pageSize,
  ) {
    // TODO: implement getCustomers
    throw UnimplementedError();
  }

  @override
  Future<Response> updateCustomer(
    String token,
    String customerId,
    Map<String, dynamic> requestBody,
  ) {
    // TODO: implement updateCustomer
    throw UnimplementedError();
  }

  @override
  Future<Response> addCustomer(String token, Map<String, dynamic> requestBody) {
    // TODO: implement addCustomer
    throw UnimplementedError();
  }

  @override
  Future<Response> deleteTimeseriesData(
    String token,
    int? dataId,
    String workshopId,
    String caseId,
  ) {
    // TODO: implement deleteTimeseriesData
    throw UnimplementedError();
  }

  @override
  Future<Response> deleteObdData(
    String token,
    int? dataId,
    String workshopId,
    String caseId,
  ) {
    // TODO: implement deleteObdData
    throw UnimplementedError();
  }

  @override
  Future<Response> deleteSymptomData(
    String token,
    int? dataId,
    String workshopId,
    String caseId,
  ) {
    // TODO: implement deleteSymptomData
    throw UnimplementedError();
  }
}
