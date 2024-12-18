import "dart:convert";

import "package:aw40_hub_frontend/dtos/case_dto.dart";
import "package:aw40_hub_frontend/dtos/diagnosis_dto.dart";
import "package:aw40_hub_frontend/dtos/new_obd_data_dto.dart";
import "package:aw40_hub_frontend/dtos/obd_data_dto.dart";
import "package:aw40_hub_frontend/dtos/symptom_dto.dart";
import "package:aw40_hub_frontend/services/mock_http_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" show Response;

void main() {
  group("MockHttpService", () {
    late MockHttpService mockHttpService;
    setUp(() => mockHttpService = MockHttpService());
    group("addCase()", () {
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
    test("checkBackendHealth()", () async {
      final response = await mockHttpService.checkBackendHealth();
      expect(response.statusCode, 200, reason: "status code should be 200");
      expect(
        response.body,
        '{"status": "success"}',
        reason: "should return expected body",
      );
    });
    test("deleteCase() returns 200", () async {
      final response =
          await mockHttpService.deleteCase("token", "workshopId", "caseId");
      expect(response.statusCode, 200, reason: "status code should be 200");
    });
    test("deleteDiagnosis() returns 200", () async {
      final response = await mockHttpService.deleteDiagnosis(
        "token",
        "workshopId",
        "caseId",
      );
      expect(response.statusCode, 200, reason: "status code should be 200");
    });
    test("getAuthHeaderWith() throws UnsupportedError", () {
      expect(
        () => mockHttpService.getAuthHeaderWith("token"),
        throwsUnsupportedError,
      );
    });
    group("getCases()", () {
      test("returns 200 List<CaseDto> json", () async {
        final Response response =
            await mockHttpService.getCases("token", "workshop");
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
        setUpAll(() async {
          cases = await _getCaseDtosFromGetCases(mockHttpService);
        });
        test("obd data", () {
          expect(
            cases,
            anyElement((CaseDto c) => c.obdData.isNotEmpty),
            reason: "at least one case should have obd data",
          );
        });
        test("timeseries data", () {
          expect(
            cases,
            anyElement((CaseDto c) => c.timeseriesData.isNotEmpty),
            reason: "at least one case should have timeseries data",
          );
        });
        test("symptomDtoResponse data", () {
          expect(
            cases,
            anyElement((CaseDto c) => c.symptoms.isNotEmpty),
            reason: "at least one case should have symptomDtoResponse data",
          );
        });
        test("all dataset types", () {
          expect(
            cases,
            anyElement(
              (CaseDto c) =>
                  c.obdData.isNotEmpty &&
                  c.timeseriesData.isNotEmpty &&
                  c.symptoms.isNotEmpty,
            ),
            reason: "at least one case should have all dataset types",
          );
        });
      });
    });
    group("getDiagnoses()", () {
      test("returns 200 List<DiagnosisDto> json", () async {
        final Response response =
            await mockHttpService.getDiagnoses("token", "workshopId");
        final json = jsonDecode(response.body);

        expect(response.statusCode, 200, reason: "status code should be 200");
        expect(json, isA<List>(), reason: "should return List json");
        // For type promotion.
        if (json is! List) {
          fail("json is not a List, previous expect() should have failed");
        }
        expect(
          // ignore: unnecessary_lambdas
          () => json.map((e) => DiagnosisDto.fromJson(e)),
          returnsNormally,
          reason: "should return valid List<DiagnosisDto> json",
        );
      });
      group("returns at least one diagnosis with", () {
        late List<DiagnosisDto> diagnoses;
        setUpAll(() async {
          diagnoses = await _getDiagnosisDtosFromGetDiagnoses(mockHttpService);
        });
        group("status action_required", () {
          test("and datatype obd", () {
            expect(
              diagnoses,
              anyElement(
                (DiagnosisDto d) =>
                    d.status == DiagnosisStatus.action_required &&
                    d.todos.isNotEmpty &&
                    d.todos[0].dataType == DatasetType.obd,
              ),
              reason: "at least one diagnosis should have status"
                  " action_required and datatype obd",
            );
          });
          test("and datatype timeseries", () {
            expect(
              diagnoses,
              anyElement(
                (DiagnosisDto d) =>
                    d.status == DiagnosisStatus.action_required &&
                    d.todos.isNotEmpty &&
                    d.todos[0].dataType == DatasetType.timeseries,
              ),
              reason: "at least one diagnosis should have status"
                  " action_required and datatype timeseries",
            );
          });
          test("and datatype symptom", () {
            expect(
              diagnoses,
              anyElement(
                (DiagnosisDto d) =>
                    d.status == DiagnosisStatus.action_required &&
                    d.todos.isNotEmpty &&
                    d.todos[0].dataType == DatasetType.symptom,
              ),
              reason: "at least one diagnosis should have status"
                  " action_required and datatype symptom",
            );
          });
        });
        test("status scheduled", () {
          expect(
            diagnoses,
            anyElement(
              (DiagnosisDto d) => d.status == DiagnosisStatus.scheduled,
            ),
            reason: "at least one diagnosis should have status scheduled",
          );
        });
        test("status processing", () {
          expect(
            diagnoses,
            anyElement(
              (DiagnosisDto d) => d.status == DiagnosisStatus.processing,
            ),
            reason: "at least one diagnosis should have status processing",
          );
        });
        test("status finished", () {
          expect(
            diagnoses,
            anyElement(
              (DiagnosisDto d) => d.status == DiagnosisStatus.finished,
            ),
            reason: "at least one diagnosis should have status finished",
          );
        });
        test("status failed", () {
          expect(
            diagnoses,
            anyElement(
              (DiagnosisDto d) => d.status == DiagnosisStatus.failed,
            ),
            reason: "at least one diagnosis should have status failed",
          );
        });
      });
    });
    test("getDiagnosis() returns 200 DiagnosisDto json", () async {
      const caseId = "1";
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
    group("getSharedCases()", () {
      test("returns 200 List<CaseDto> json", () async {
        final Response response = await mockHttpService.getSharedCases("token");
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
        setUpAll(() async {
          cases = await _getCaseDtosFromSharedCases(mockHttpService);
        });
        test("obd data", () {
          expect(
            cases,
            anyElement((CaseDto c) => c.obdData.isNotEmpty),
            reason: "at least one case should have obd data",
          );
        });
        test("timeseries data", () {
          expect(
            cases,
            anyElement((CaseDto c) => c.timeseriesData.isNotEmpty),
            reason: "at least one case should have timeseries data",
          );
        });
        test("symptomDtoResponse data", () {
          expect(
            cases,
            anyElement((CaseDto c) => c.symptoms.isNotEmpty),
            reason: "at least one case should have symptomDtoResponse data",
          );
        });
        test("all dataset types", () {
          expect(
            cases,
            anyElement(
              (CaseDto c) =>
                  c.obdData.isNotEmpty &&
                  c.timeseriesData.isNotEmpty &&
                  c.symptoms.isNotEmpty,
            ),
            reason: "at least one case should have all dataset types",
          );
        });
        test("different workshop id", () {
          final workshopIds = cases.map((e) => e.workshopId).toSet();
          expect(
            workshopIds,
            hasLength(greaterThan(1)),
            reason: "should return cases with more than one workshop id",
          );
        });
      });
    });
    test("startDiagnosis() returns 201 DiagnosisDto json", () async {
      const caseId = "caseId";
      final response =
          await mockHttpService.startDiagnosis("token", "workshopId", caseId);

      expect(response.statusCode, 201, reason: "status code should be 201");
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
    group("updateCase()", () {
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
    group("uploadObdData()", () {
      test("returns 201 CaseDto json", () async {
        final newObdDataDto = NewOBDDataDto(["some obd specs"], ["some dtcs"]);
        const caseId = "caseId";
        const workshopId = "workshopId";
        final Response response = await mockHttpService.uploadObdData(
          "token",
          workshopId,
          caseId,
          newObdDataDto.toJson(),
        );

        expect(response.statusCode, 201, reason: "status code should be 201");
        expect(
          () => CaseDto.fromJson(jsonDecode(response.body)),
          returnsNormally,
          reason: "should return valid CaseDto json",
        );

        final CaseDto caseDto = CaseDto.fromJson(jsonDecode(response.body));
        expect(
          caseDto.id,
          equals(caseId),
          reason: "caseId should be input parameter",
        );
        expect(
          caseDto.workshopId,
          equals(workshopId),
          reason: "workshopId should be input parameter",
        );

        expect(
          caseDto.obdData.length,
          equals(1),
          reason: "caseDto should have one obdData",
        );
        final ObdDataDto obdDataDto = caseDto.obdData.first;
        expect(
          obdDataDto.obdSpecs,
          equals(newObdDataDto.obdSpecs),
          reason: "symptomDtoResponse.obdSpecs should be input parameter",
        );
        expect(
          obdDataDto.dtcs,
          equals(newObdDataDto.dtcs),
          reason: "symptomDtoResponse.dtcs should be input parameter",
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
    group("uploadOmniviewData()", () {
      test("returns 201 CaseDto json", () async {
        const caseId = "caseId";
        const workshopId = "workshopId";
        final Response response = await mockHttpService.uploadOmniviewData(
          "token",
          workshopId,
          caseId,
          "component",
          4,
          8,
          [15],
          "filename",
        );
        expect(response.statusCode, 201, reason: "status code should be 201");
        expect(
          () => CaseDto.fromJson(jsonDecode(response.body)),
          returnsNormally,
          reason: "should return valid CaseDto json",
        );

        final CaseDto caseDto = CaseDto.fromJson(jsonDecode(response.body));
        expect(
          caseDto.id,
          equals(caseId),
          reason: "id should be input parameter",
        );
        expect(
          caseDto.workshopId,
          equals(workshopId),
          reason: "workshopId should be input parameter",
        );
      });
      // Test validation once DTO is implemented.
    });
    group("uploadPicoscopeData()", () {
      test("returns 201 CaseDto json", () async {
        const caseId = "caseId";
        const workshopId = "workshopId";
        final Response response = await mockHttpService.uploadPicoscopeData(
          "token",
          workshopId,
          caseId,
          [],
          "filename",
        );
        expect(response.statusCode, 201, reason: "status code should be 201");
        expect(
          () => CaseDto.fromJson(jsonDecode(response.body)),
          returnsNormally,
          reason: "should return valid CaseDto json",
        );

        final CaseDto caseDto = CaseDto.fromJson(jsonDecode(response.body));
        expect(
          caseDto.id,
          equals(caseId),
          reason: "id should be input parameter",
        );
        expect(
          caseDto.workshopId,
          equals(workshopId),
          reason: "workshopId should be input parameter",
        );
      });
      // Test validation once DTO is implemented.
    });
    group("uploadSymptomData()", () {
      test("returns 201 CaseDto json", () async {
        final symptomDto = SymptomDto(
          DateTime.utc(2021, 2, 3),
          "component",
          SymptomLabel.defect,
          5,
        );
        const caseId = "caseId";
        const workshopId = "workshopId";
        const component = "component";
        const label = SymptomLabel.defect;
        final Response response = await mockHttpService.uploadSymptomData(
          "token",
          workshopId,
          caseId,
          component,
          label,
        );

        expect(response.statusCode, 201, reason: "status code should be 201");
        expect(
          () => CaseDto.fromJson(jsonDecode(response.body)),
          returnsNormally,
          reason: "should return valid CaseDto json",
        );

        final CaseDto caseDto = CaseDto.fromJson(jsonDecode(response.body));
        expect(
          caseDto.id,
          equals(caseId),
          reason: "caseId should be input parameter",
        );
        expect(
          caseDto.workshopId,
          equals(workshopId),
          reason: "workshopId should be input parameter",
        );

        expect(
          caseDto.symptoms.length,
          equals(1),
          reason: "caseDto should have one symptomDtoResponse",
        );
        final SymptomDto symptomDtoResponse = caseDto.symptoms.first;
        expect(
          symptomDtoResponse.timestamp,
          equals(symptomDto.timestamp),
          reason: "symptomDtoResponse.timestamp should be input parameter",
        );
        expect(
          symptomDtoResponse.component,
          equals(symptomDto.component),
          reason: "symptomDtoResponse.component should be input parameter",
        );
      });
      /*test("returns 422 on incorrect requestBody", () async {
        final Map<String, dynamic> requestBody = {
          "obd_specs": ["some obd specs"],
          "dtcs": 5,
        };

        final response = await mockHttpService.uploadSymptomData(
          "token",
          "workshopId",
          "caseId",
          "component",
          SymptomLabel.defect,
        );

        expect(response.statusCode, 422, reason: "status code should be 422");
      });*/
    });
    group("uploadVcdsData", () {
      test("returns 201 CaseDto json", () async {
        const caseId = "caseId";
        const workshopId = "workshopId";
        final Response response = await mockHttpService.uploadVcdsData(
          "token",
          workshopId,
          caseId,
          [0],
          "some_file.txt",
        );

        expect(response.statusCode, 201, reason: "status code should be 201");
        expect(
          () => CaseDto.fromJson(jsonDecode(response.body)),
          returnsNormally,
          reason: "should return valid CaseDto json",
        );

        final CaseDto caseDto = CaseDto.fromJson(jsonDecode(response.body));
        expect(
          caseDto.id,
          equals(caseId),
          reason: "caseId should be input parameter",
        );
        expect(
          caseDto.workshopId,
          equals(workshopId),
          reason: "workshopId should be input parameter",
        );
        expect(
          caseDto.obdData.length,
          equals(1),
          reason: "caseDto should have one obdData",
        );
      });
      // Test validation once actual method is implemented.
    });
    testDemoDiagnosisWorkflow();
  });
}

/// This method executes two tests for testing the demo diagnosis workflow. The
/// first is self-explanatory.
/// This second test triggers the demo diagnosis by calling
/// [startDiagnosis(..., caseId: demoCaseId)]. It then repeatedly checks the
/// status of the diagnosis. Where appropriate, it will wait before checking
/// that the diagnosis advanced to the next state. In a nutshell, it tests the
/// following sequence (unless mentioned otherwise, the demo diagnosis is
/// obtained through calling [getDiagnosis(..., caseId: demoCaseId)]:
///
/// - calling [startDiagnosis()] with demoCaseId returns a diagnosis with status
///   `scheduled`
/// - demo diagnosis has status `scheduled`
/// - wait
/// - demo diagnosis has status `action_required` with data type `obd`
/// - execute any correct call with `demoCaseId` to [uploadObdData()]
/// - demo diagnosis has status `processing`
/// - wait
/// - demo diagnosis has status `action_required` with data type `timeseries`
/// - execute any correct call with `demoCaseId` to [uploadPicoscopeData()]
/// - demo diagnosis has status `processing`
/// - wait
/// - demo diagnosis has status `action_required` with data type `symptom`
/// - execute any correct call with `demoCaseId` to [uploadSymptomData()]
/// - demo diagnosis has status `processing`
/// - wait
/// - demo diagnosis has status `finished`
///
/// When submitting data, the following aspects are _not_ checked:
/// - file extension (responsibility of widgets)
/// - file content (responsibility of the backend)
/// - parameter content (responsibility of other tests)
/// I.e. uploading a PowerPoint presentation as a picoscope file with
/// `token="jam", workshopId="ketchup", caseId=<DEMO_CASE_ID>` will pass.
void testDemoDiagnosisWorkflow() {
  group("diagnosis workflow()", () {
    late MockHttpService mockHttpService;
    setUp(() => mockHttpService = MockHttpService());
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
    test("diagnosis transitions through states correctly", () async {
      // Milliseconds before demo diagnosis advances to next state.
      const int interval = 50;
      const int intervalWithBuffer = interval + 10;
      // Milliseconds futures from MockHttpService take to complete.
      const int delay = 0;

      mockHttpService.diagnosisTransitionInterval = interval;
      mockHttpService.delay = delay;

      // Trigger diagnosis demo by calling startDiagnosis with demoCaseId.
      final Response startDiagnosisResponse =
          await mockHttpService.startDiagnosis(
        "token",
        "workshopId",
        demoCaseId,
      );
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
      await Future.delayed(const Duration(milliseconds: intervalWithBuffer));
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
      // This should also work with a call to uploadVcdsData.
      // (Which it does, it just isn't tested yet.)
      final NewOBDDataDto newOBDDataDto = NewOBDDataDto([], []);
      Response response = await mockHttpService.uploadObdData(
        "token",
        "workshopId",
        demoCaseId,
        newOBDDataDto.toJson(),
      );
      expect(
        response.statusCode,
        equals(201),
        reason: "status code should be 201",
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
      //  This should also work with a call to uploadOmniviewData.
      // (Which it does, it just isn't tested yet.)
      response = await mockHttpService.uploadPicoscopeData(
        "token",
        "workshopId",
        demoCaseId,
        [],
        "filename",
      );
      expect(
        response.statusCode,
        equals(201),
        reason: "status code should be 201",
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
      response = await mockHttpService.uploadSymptomData(
        "token",
        "workshopId",
        demoCaseId,
        "component",
        SymptomLabel.defect,
      );
      expect(
        response.statusCode,
        equals(201),
        reason: "status code should be 201",
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
      demoDiagnosisDto =
          await _getDemoDiagnosisDtoFromGetDiagnosis(mockHttpService);
      expect(
        demoDiagnosisDto.status,
        equals(DiagnosisStatus.finished),
        reason: "demoDiagnosisDto should have status finished",
      );
    });
  });
}

/// Convenience function to get [DiagnosisDto]s from
/// [MockHttpService.getDiagnoses].
Future<List<DiagnosisDto>> _getDiagnosisDtosFromGetDiagnoses(
  MockHttpService mockHttpService,
) {
  return mockHttpService
      .getDiagnoses("token", "workshopId")
      .then((response) => jsonDecode(response.body))
      .then((json) {
    if (json is! List) {
      throw ArgumentError(
        "Json is not a List."
        " There is a unit test for this which should have failed.",
      );
    }
    // ignore: unnecessary_lambdas
    return json.map((e) => DiagnosisDto.fromJson(e)).toList();
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

/// Convenience function to get [CaseDto]s from
/// [MockHttpService.getSharedCases].
Future<List<CaseDto>> _getCaseDtosFromSharedCases(
  MockHttpService mockHttpService,
) async {
  final response = await mockHttpService.getSharedCases("token");
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
