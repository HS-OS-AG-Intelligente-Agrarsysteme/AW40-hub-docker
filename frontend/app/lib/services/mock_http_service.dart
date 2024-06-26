// ignore_for_file: avoid_catching_errors
import "dart:convert";

import "package:aw40_hub_frontend/dtos/action_dto.dart";
import "package:aw40_hub_frontend/dtos/case_dto.dart";
import "package:aw40_hub_frontend/dtos/case_update_dto.dart";
import "package:aw40_hub_frontend/dtos/diagnosis_dto.dart";
import "package:aw40_hub_frontend/dtos/new_case_dto.dart";
import "package:aw40_hub_frontend/dtos/new_obd_data_dto.dart";
import "package:aw40_hub_frontend/dtos/obd_data_dto.dart";
import "package:aw40_hub_frontend/dtos/symptom_dto.dart";
import "package:aw40_hub_frontend/dtos/timeseries_data_dto.dart";
import "package:aw40_hub_frontend/services/http_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:http/http.dart" show Response;
import "package:logging/logging.dart";

class MockHttpService implements HttpService {
  final Logger _logger = Logger("MockHttpService");

  /// The interval for diagnosis transition in milliseconds.
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

  Future<void> _demoDiagnosisStage0() async {
    if (_demoDiagnosisStage != 0) return;
    _demoDiagnosisStage++;
    _logger.info("Starting demo diagnosis with transition interval "
        "$diagnosisTransitionInterval ms. and delay $delay ms.");
    _demoCaseDto.diagnosisId = _demoDiagnosisDto.id;
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
  }

  Future<void> _demoDiagnosisStage1() async {
    if (_demoDiagnosisStage != 1) return;
    _demoDiagnosisStage++;
    _demoDiagnosisDto.status = DiagnosisStatus.processing;
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
    final List<CaseDto> caseDtos = [
      // Diagnosis demo case.
      _demoCaseDto,
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
        workshopId,
        null,
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
        workshopId,
        null,
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
      // Case for diagnosis status action_required.
      // Timeseries data.
      CaseDto(
        "4",
        DateTime.utc(2021, 1, 21, 12, 0, 8),
        CaseOccasion.problem_defect,
        100,
        CaseStatus.open,
        "unknown",
        "12345678901234567",
        workshopId,
        null,
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
        workshopId,
        null,
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
        workshopId,
        null,
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
        workshopId,
        null,
        [],
        [],
        [],
        0,
        0,
        0,
      )
    ];
    return Future.delayed(
      Duration(milliseconds: delay),
      () => Response(jsonEncode(caseDtos.map((e) => e.toJson()).toList()), 200),
    );
  }

  @override
  Future<Response> getDiagnoses(String token, String workshopId) {
    // TODO: implement getDiagnosis
    throw UnimplementedError();
  }

  @override
  Future<Response> getDiagnosis(
    String token,
    String workshopId,
    String caseId,
  ) {
    if (caseId == demoCaseId) {
      return Future.delayed(
        Duration(milliseconds: delay),
        () => Response(jsonEncode(_demoDiagnosisDto.toJson()), 200),
      );
    }
    final DiagnosisDto diagnosisDto = DiagnosisDto(
      "1",
      DateTime.now(),
      DiagnosisStatus.processing,
      caseId,
      [],
      [],
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
    // TODO: implement getSharedCases
    throw UnimplementedError();
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
          return Response(jsonEncode(_demoDiagnosisDto.toJson()), 200);
        },
      );
    }
    return Future.delayed(
      Duration(milliseconds: delay),
      () => Response(jsonEncode(diagnosisDto.toJson()), 200),
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
          return Response(jsonEncode(_demoCaseDto.toJson()), 200);
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
      [
        obdDataDto,
      ],
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
    // TODO: implement uploadOmniviewData
    throw UnimplementedError();
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
  Future<Response> uploadSymptomData(
    String token,
    String workshopId,
    String caseId,
    Map<String, dynamic> requestBody,
  ) {
    // TODO: implement uploadSymptomData
    throw UnimplementedError();
  }
}
