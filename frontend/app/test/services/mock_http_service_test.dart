import "dart:convert";

import "package:aw40_hub_frontend/dtos/case_dto.dart";
import "package:aw40_hub_frontend/dtos/diagnosis_dto.dart";
import "package:aw40_hub_frontend/dtos/new_obd_data_dto.dart";
import "package:aw40_hub_frontend/services/mock_http_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" show Response;
import "package:logging/logging.dart";

void main() {
  // Logger.root.level = Level.ALL;
  // Logger.root.onRecord.listen((record) {
  //   final String loggerName = record.loggerName.padRight(19);
  //   final time =
  //       "${record.time.hour.toString().padLeft(2, "0")}:"
  //       "${record.time.minute.toString().padLeft(2, "0")}:"
  //       "${record.time.second}.${record.time.millisecond}";
  //   // ignore: avoid_print
  //   print("$loggerName $time: ${record.message}");
  // });
  group("MockHttpService", () {
    final Logger logger = Logger("MockHttpServiceTest");
    late MockHttpService mockHttpService;
    setUp(() => mockHttpService = MockHttpService());
    group("addCase", () {
      test("returns 201 CaseDto json", () async {
        const vehicleVin = "12345678901234567";
        const customerId = "unknown";
        const occasion = "problem_defect";
        const milage = 100;
        final Map<String, dynamic> requestBody = {
          "vehicle_vin": vehicleVin,
          "customer_id": customerId,
          "occasion": occasion,
          "milage": milage,
        };

        final response =
            await mockHttpService.addCase("token", "workshopId", requestBody);

        expect(response.statusCode, 201, reason: "status code should be 201");
        expect(
          () => CaseDto.fromJson(jsonDecode(response.body)),
          returnsNormally,
          reason: "should return valid CaseDto json",
        );

        final CaseDto caseDto = CaseDto.fromJson(jsonDecode(response.body));

        expect(
          caseDto.vehicleVin,
          vehicleVin,
          reason: "vehicleVin should be input parameter",
        );
        expect(
          caseDto.customerId,
          customerId,
          reason: "customerId should be input parameter",
        );
        expect(
          caseDto.occasion.name,
          occasion,
          reason: "occasion should be input parameter",
        );
        expect(
          caseDto.milage,
          milage,
          reason: "milage should be input parameter",
        );
      });
      test("returns 422 on incorrect requestBody", () async {
        final Map<String, dynamic> requestBody = {
          "vehicle_vin": "12345678901234567",
          "customer_id": "unknown",
          "occasion": "problem_defect",
          "milage": "100",
        };

        final response =
            await mockHttpService.addCase("token", "workshopId", requestBody);
        expect(response.statusCode, 422, reason: "status code should be 422");
      });
    });
    test("checkBackendHealth", () async {
      final response = await mockHttpService.checkBackendHealth();
      expect(response.statusCode, 200, reason: "status code should be 200");
      expect(
        response.body,
        '{"status": "success"}',
        reason: "should return expected body",
      );
    });
    test("deleteCase returns 200", () async {
      final response =
          await mockHttpService.deleteCase("token", "workshopId", "caseId");
      expect(response.statusCode, 200, reason: "status code should be 200");
    });
    test("deleteDiagnosis returns 200", () async {
      final response = await mockHttpService.deleteDiagnosis(
        "token",
        "workshopId",
        "caseId",
      );
      expect(response.statusCode, 200, reason: "status code should be 200");
    });
    test("getAuthHeaderWith throws UnsupportedError", () {
      expect(
        () => mockHttpService.getAuthHeaderWith("token"),
        throwsUnsupportedError,
      );
    });
    group("getCases()", () {
      test("returns 200 List<CaseDto> json", () async {
        final response = await mockHttpService.getCases("token", "workshop");
        final json = jsonDecode(response.body);

        expect(response.statusCode, 200, reason: "status code should be 200");
        expect(json, isA<List>(), reason: "should return List json");
        // For type promotion.
        if (json is! List) {
          fail("json is not a List, previous expect() should have failed");
        }
        expect(
          // ignore: unnecessary_lambdas
          () => json.map((e) => CaseDto.fromJson(e)),
          returnsNormally,
          reason: "should return valid List<CaseDto> json",
        );
      });
      group("returns at least one case with", () {
        late List<CaseDto> cases;
        setUp(() async {
          cases = await _getCaseDtosFromGetCases(mockHttpService);
        });
        test("obd data", () {
          expect(
            cases.any((c) => c.obdData.isNotEmpty),
            isTrue,
            reason: "at least one case should have obd data",
          );
        });
        test("timeseries data", () {
          expect(
            cases.any((c) => c.timeseriesData.isNotEmpty),
            isTrue,
            reason: "at least one case should have timeseries data",
          );
        });
        test("symptom data", () {
          expect(
            cases.any((c) => c.symptoms.isNotEmpty),
            isTrue,
            reason: "at least one case should have symptom data",
          );
        });
        test("all dataset types", () {
          expect(
            cases.any(
              (c) =>
                  c.obdData.isNotEmpty &&
                  c.timeseriesData.isNotEmpty &&
                  c.symptoms.isNotEmpty,
            ),
            isTrue,
            reason: "at least one case should have all dataset types",
          );
        });
      });
    });
    test("getDiagnosis returns 200 DiagnosisDto json", () async {
      const caseId = "caseId";
      final Response response =
          await mockHttpService.getDiagnosis("token", "workshopId", caseId);

      expect(response.statusCode, 200, reason: "status code should be 200");
      expect(
        () => DiagnosisDto.fromJson(jsonDecode(response.body)),
        returnsNormally,
        reason: "should return valid DiagnosisDto json",
      );

      final DiagnosisDto diagnosisDto =
          DiagnosisDto.fromJson(jsonDecode(response.body));

      expect(
        diagnosisDto.caseId,
        caseId,
        reason: "customerId should be input parameter",
      );
    });
    test("startDiagnosis returns 200 DiagnosisDto json", () async {
      const caseId = "caseId";
      final response =
          await mockHttpService.startDiagnosis("token", "workshopId", caseId);

      expect(response.statusCode, 200, reason: "status code should be 200");
      expect(
        () => DiagnosisDto.fromJson(jsonDecode(response.body)),
        returnsNormally,
        reason: "should return valid DiagnosisDto json",
      );

      final DiagnosisDto diagnosisDto =
          DiagnosisDto.fromJson(jsonDecode(response.body));

      expect(
        diagnosisDto.caseId,
        caseId,
        reason: "customerId should be input parameter",
      );
    });
    group("updateCase", () {
      test("returns 200 CaseDto json", () async {
        final timestamp = DateTime.now();
        const occasion = "problem_defect";
        const milage = 100;
        const status = "open";
        final Map<String, dynamic> requestBody = {
          "timestamp": timestamp.toIso8601String(),
          "occasion": occasion,
          "milage": milage,
          "status": status,
        };
        const caseId = "caseId";
        const workshopId = "workshopId";

        final response = await mockHttpService.updateCase(
          "token",
          workshopId,
          caseId,
          requestBody,
        );

        expect(response.statusCode, 200, reason: "status code should be 200");
        expect(
          () => CaseDto.fromJson(jsonDecode(response.body)),
          returnsNormally,
          reason: "should return valid CaseDto json",
        );

        final CaseDto caseDto = CaseDto.fromJson(jsonDecode(response.body));

        expect(
          caseDto.id,
          caseId,
          reason: "id should be input parameter",
        );
        expect(
          caseDto.workshopId,
          workshopId,
          reason: "workshopId should be input parameter",
        );
        expect(
          caseDto.timestamp,
          timestamp,
          reason: "timestamp should be input parameter",
        );
        expect(
          caseDto.occasion.name,
          occasion,
          reason: "occasion should be input parameter",
        );
        expect(
          caseDto.milage,
          milage,
          reason: "milage should be input parameter",
        );
        expect(
          caseDto.status.name,
          status,
          reason: "status should be input parameter",
        );
      });
      test("returns 422 on incorrect requestBody", () async {
        final Map<String, dynamic> requestBody = {
          "occasion": "problem_defect",
          "milage": 100,
          "status": "open",
        };

        final response = await mockHttpService.updateCase(
          "token",
          "workshopId",
          "caseId",
          requestBody,
        );
        expect(response.statusCode, 422, reason: "status code should be 422");
      });
    });
    group("uploadObdData", (){
      test("returns 201 CaseDto json", () async {
        final newObdDataDto = NewOBDDataDto(["some obd specs"], ["some dtcs"]);
        final Response response = await mockHttpService.uploadObdData(
          "token",
          "workshopId",
          "caseId",
          newObdDataDto.toJson(),
        );

        expect(response.statusCode, 201, reason: "status code should be 201");
        expect(
          () => CaseDto.fromJson(jsonDecode(response.body)),
          returnsNormally,
          reason: "should return valid CaseDto json",
        );
      });
      test("returns 422 on incorrect requestBody", () async {
        final Map<String, dynamic> requestBody = {
          "obd_specs": ["some obd specs"],
          "dtcs": 5,
        };

        final response = await mockHttpService.uploadObdData(
          "token",
          "workshopId",
          "caseId",
          requestBody,
        );

        expect(response.statusCode, 422, reason: "status code should be 422");

      });
    });
    group("diagnosis workflow", () {
      const String demoCaseId = MockHttpService.demoCaseId;
      test("first case in getCases is diagnosis demo case", () async {
        final Response response =
            await mockHttpService.getCases("token", "workshop");
        final json = jsonDecode(response.body);
        // For type promotion.
        if (json is! List) {
          // Throwing ArgumentError here instead of calling [fail()], because
          // it's not what this test is testing.
          throw ArgumentError(
            "Json is not a List."
            " There is a unit test for this which should have failed.",
          );
        }
        final List<CaseDto> cases =
            // ignore: unnecessary_lambdas
            json.map((e) => CaseDto.fromJson(e)).toList();
        expect(
          cases.first.id,
          equals(demoCaseId),
          reason: "first case should have demo case id",
        );
        expect(
          cases.first.diagnosisId,
          isNull,
          reason: "first case should have no diagnosis",
        );
      });
      test(
          "calling startDiagnosis with demoCaseId returns diagnosis with status scheduled ",
          () async {
        final response = await mockHttpService.startDiagnosis(
          "token",
          "workshopId",
          demoCaseId,
        );
        final DiagnosisDto diagnosisDto =
            DiagnosisDto.fromJson(jsonDecode(response.body));
        expect(
          diagnosisDto.caseId,
          equals(demoCaseId),
          reason: "diagnosisDto should have id demoCaseId",
        );
        expect(
          diagnosisDto.status,
          equals(DiagnosisStatus.scheduled),
          reason: "diagnosisDto should have status scheduled",
        );
      });
      test("diagnosis transitions through states correctly", () async {
        // Milliseconds before demo diagnosis advances to next state.
        const int interval = 1000;
        // Milliseconds futures from MockHttpService take to complete.
        const int delay = 100;
        // (Lowest I got away with is 100, 0.)

        mockHttpService.diagnosisTransitionInterval = interval;
        mockHttpService.delay = delay;

        // Trigger diagnosis demo by calling startDiagnosis with demoCaseId.
        logger.info("Calling startDiagnosis()");
        final Response startDiagnosisResponse =
            await mockHttpService.startDiagnosis(
          "token",
          "workshopId",
          demoCaseId,
        );
        logger.info("startDiagnosis() returned");
        final DiagnosisDto startDiagnosisDto =
            DiagnosisDto.fromJson(jsonDecode(startDiagnosisResponse.body));
        expect(
          startDiagnosisDto.caseId,
          equals(demoCaseId),
          reason: "startDiagnosisDto should have id demoCaseId",
        );
        expect(
          startDiagnosisDto.status,
          equals(DiagnosisStatus.scheduled),
          reason: "startDiagnosisDto should have status scheduled",
        );


        // Check initial state is scheduled.
        // Note: We could use final variables here, but the values we're
        // interested in testing could be changed on a final variable as well,
        // so there's no advantage.
        DiagnosisDto demoDiagnosisDto =
            await _getDemoDiagnosisDtoFromGetDiagnosis(mockHttpService);
        expect(
          demoDiagnosisDto.status,
          equals(DiagnosisStatus.scheduled),
          reason: "demoDiagnosisDto should have initial status scheduled",
        );

        // Wait, then check status is action_required and data_type is obd
        logger.info("Waiting before checking: action_required, obd");
        await Future.delayed(const Duration(milliseconds: interval * 2));
        logger.info("Checking action_required, obd");
        demoDiagnosisDto =
            await _getDemoDiagnosisDtoFromGetDiagnosis(mockHttpService);
        expect(
          demoDiagnosisDto.status,
          equals(DiagnosisStatus.action_required),
          reason: "demoDiagnosisDto should have status action_required",
        );
        expect(
          demoDiagnosisDto.todos[0].dataType,
          equals(DatasetType.obd),
          reason: "demoDiagnosisDto.todos[0].dataType should be obd",
        );

        // Add obd data.
        // TODO: This should also work with a call to uploadVcdsData.
        final NewOBDDataDto newOBDDataDto = NewOBDDataDto([], []);
        await mockHttpService.uploadObdData(
          "token",
          "workshopId",
          demoCaseId,
          newOBDDataDto.toJson(),
        );
        // Check status is processing.
        demoDiagnosisDto =
            await _getDemoDiagnosisDtoFromGetDiagnosis(mockHttpService);
        expect(
          demoDiagnosisDto.status,
          equals(DiagnosisStatus.processing),
          reason: "directly after adding odb data,"
              " demoDiagnosisDto should have status processing",
        );

        // Wait, then check status is action_required and data_type is
        // timeseries.
        await Future.delayed(const Duration(milliseconds: interval));
        demoDiagnosisDto =
            await _getDemoDiagnosisDtoFromGetDiagnosis(mockHttpService);
        expect(
          demoDiagnosisDto.status,
          equals(DiagnosisStatus.action_required),
          reason: "demoDiagnosisDto should have status action_required",
        );
        expect(
          demoDiagnosisDto.todos[0].dataType,
          equals(DatasetType.timeseries),
          reason: "demoDiagnosisDto.todos[0].dataType should be timeseries",
        );

        // Add timeseries data.
        // TODO: This should also work with a call to uploadOmniviewData.
        await mockHttpService.uploadPicoscopeData(
          "token",
          "workshopId",
          demoCaseId,
          [],
          "filename",
        );

        // Check status is processing.
        demoDiagnosisDto =
            await _getDemoDiagnosisDtoFromGetDiagnosis(mockHttpService);
        expect(
          demoDiagnosisDto.status,
          equals(DiagnosisStatus.processing),
          reason: "directly after adding timeseries data,"
              " demoDiagnosisDto should have status processing",
        );

        // Wait, then check status is action_required and data_type is
        // symptom.
        await Future.delayed(const Duration(milliseconds: interval));
        // fakeAsync.elapse(const Duration(seconds: interval));
        demoDiagnosisDto =
            await _getDemoDiagnosisDtoFromGetDiagnosis(mockHttpService);
        expect(
          demoDiagnosisDto.status,
          equals(DiagnosisStatus.action_required),
          reason: "demoDiagnosisDto should have status action_required",
        );
        expect(
          demoDiagnosisDto.todos[0].dataType,
          equals(DatasetType.symptom),
          reason: "demoDiagnosisDto.todos[0].dataType should be symptom",
        );

        // Add symptom data.
        await mockHttpService.uploadSymptomData(
          "token",
          "workshopId",
          demoCaseId,
          // Note: SymptomDto not yet implemented.
          {},
        );

        // Check status is processing.
        demoDiagnosisDto =
            await _getDemoDiagnosisDtoFromGetDiagnosis(mockHttpService);
        expect(
          demoDiagnosisDto.status,
          equals(DiagnosisStatus.processing),
          reason: "directly after adding symptomdata,"
              " demoDiagnosisDto should have status processing",
        );

        // Wait, then check status is finished.
        await Future.delayed(const Duration(milliseconds: interval));
        // fakeAsync.elapse(const Duration(seconds: interval));
        demoDiagnosisDto =
            await _getDemoDiagnosisDtoFromGetDiagnosis(mockHttpService);
        expect(
          demoDiagnosisDto.status,
          equals(DiagnosisStatus.finished),
          reason: "demoDiagnosisDto should have status finished",
        );
      });
    });
  });
}

/// Convenience function to get [CaseDto]s from [MockHttpService.getCases].
Future<List<CaseDto>> _getCaseDtosFromGetCases(
  MockHttpService mockHttpService,
) async {
  final response = await mockHttpService.getCases("token", "workshop");
  final json = jsonDecode(response.body);
  if (json is! List) {
    // Throwing ArgumentError here instead of calling [fail()], because
    // it's not what this test is testing.
    throw ArgumentError(
      "Json is not a List."
      " There is a unit test for this which should have failed.",
    );
  }
  // ignore: unnecessary_lambdas
  return json.map((e) => CaseDto.fromJson(e)).toList();
}

/// Convenience function to get [DiagnosisDto] from
/// [MockHttpService.getDiagnosis].
Future<DiagnosisDto> _getDemoDiagnosisDtoFromGetDiagnosis(
  MockHttpService mockHttpService,
) async {
  final response = await mockHttpService.getDiagnosis(
    "token",
    "workshopId",
    MockHttpService.demoCaseId,
  );
  return DiagnosisDto.fromJson(jsonDecode(response.body));
}
