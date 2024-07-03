import "dart:convert";

import "package:aw40_hub_frontend/dtos/new_case_dto.dart";
import "package:aw40_hub_frontend/models/diagnosis_model.dart";
import "package:aw40_hub_frontend/providers/auth_provider.dart";
import "package:aw40_hub_frontend/providers/case_provider.dart";
import "package:aw40_hub_frontend/providers/diagnosis_provider.dart";
import "package:aw40_hub_frontend/services/config_service.dart";
import "package:aw40_hub_frontend/services/http_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";

@GenerateNiceMocks([MockSpec<HttpService>(), MockSpec<AuthProvider>()])
import "providers_test.mocks.dart";

void main() {
  group("CaseProvider", () {
    final mockAuthProvider = MockAuthProvider();
    setUpAll(() async {
      when(mockAuthProvider.getAuthToken())
          .thenAnswer((_) async => "some_token");
      await ConfigService().initialize();
    });
    final NewCaseDto dummyNewCaseDto = NewCaseDto(
      "some_vehicle_vin",
      "some_customer_id",
      CaseOccasion.problem_defect,
      294,
    );
    final Map<String, dynamic> dummyCaseDtoJson = {
      "_id": "some_id",
      "timestamp": DateTime.now().toIso8601String(),
      "occasion": "problem_defect",
      "milage": 294,
      "status": "open",
      "customer_id": "some_customer_id",
      "vehicle_vin": "some_vehicle_vin",
      "workshop_id": "some_workshop_id",
      "timeseries_data": [],
      "obd_data": [],
      "symptoms": [],
      "timeseries_data_added": 1,
      "obd_data_added": 1,
      "symptoms_added": 1,
    };
    test("showSharedCases inits to true", () {
      final caseProvider = CaseProvider(HttpService(http.Client()));
      expect(caseProvider.showSharedCases, true);
    });
    test("toggleShowSharedCases toggles showSharedCases", () async {
      final mockHttpService = MockHttpService();
      when(mockHttpService.getSharedCases(any)).thenAnswer(
        (_) async => http.Response("[]", 200),
      );
      when(mockHttpService.getCases(any, any)).thenAnswer(
        (_) async => http.Response("[]", 200),
      );

      final caseProvider = CaseProvider(mockHttpService);
      await caseProvider.fetchAndSetAuthToken(mockAuthProvider);
      caseProvider.workShopId = "some_workshop_id";
      await caseProvider.toggleShowSharedCases();
      expect(caseProvider.showSharedCases, false);
    });
    group("getCurrentCases()", () {
      test(
        "getCurrentCases() calls HttpService.getSharedCases() "
        "when showSharedCases=true",
        () async {
          final mockHttpService = MockHttpService();
          when(mockHttpService.getSharedCases(any)).thenAnswer(
            (_) async => http.Response("[]", 200),
          );
          final caseProvider = CaseProvider(mockHttpService);
          await caseProvider.fetchAndSetAuthToken(mockAuthProvider);
          if (caseProvider.showSharedCases == false) {
            await caseProvider.toggleShowSharedCases();
          }
          assert(caseProvider.showSharedCases == true);
          await caseProvider.getCurrentCases();
          verify(mockHttpService.getSharedCases(any)).called(1);
          verifyNever(mockHttpService.getCases(any, any));
        },
      );
      test(
          "getCurrentCases() calls HttpService.getCases() "
          "when showSharedCases=false", () async {
        final mockHttpService = MockHttpService();
        when(mockHttpService.getCases(any, any)).thenAnswer(
          (_) async => http.Response("[]", 200),
        );
        final caseProvider = CaseProvider(mockHttpService);
        await caseProvider.fetchAndSetAuthToken(mockAuthProvider);
        caseProvider.workShopId = "some_workshop_id";
        if (caseProvider.showSharedCases == true) {
          // First call to `getCases()`.
          await caseProvider.toggleShowSharedCases();
        }
        assert(caseProvider.showSharedCases == false);
        // Second call to `getCases()`.
        await caseProvider.getCurrentCases();
        verify(mockHttpService.getCases(any, any)).called(2);
        verifyNever(mockHttpService.getSharedCases(any));
      });
    });
    group("addCase()", () {
      test("calls HttpService.addCase()", () async {
        final mockHttpService = MockHttpService();
        when(mockHttpService.addCase(any, any, any)).thenAnswer(
          (_) async => http.Response(jsonEncode(dummyCaseDtoJson), 201),
        );
        final caseProvider = CaseProvider(mockHttpService);
        await caseProvider.fetchAndSetAuthToken(mockAuthProvider);
        caseProvider.workShopId = "some_workshop_id";
        await caseProvider.addCase(dummyNewCaseDto);
        verify(mockHttpService.addCase(any, any, any)).called(1);
      });
    });
    group("deleteCase()", () {
      test("calls HttpService.deleteCase()", () async {
        final mockHttpService = MockHttpService();
        when(mockHttpService.deleteCase(any, any, any)).thenAnswer(
          (_) async => http.Response("{}", 201),
        );
        final caseProvider = CaseProvider(mockHttpService);
        await caseProvider.fetchAndSetAuthToken(mockAuthProvider);
        caseProvider.workShopId = "some_workshop_id";
        await caseProvider.deleteCase("some_case_id");
        verify(mockHttpService.deleteCase(any, any, any)).called(1);
      });
    });
  });
  group("DiagnosisProvider", () {
    final mockAuthProvider = MockAuthProvider();
    setUpAll(() async {
      when(mockAuthProvider.getAuthToken())
          .thenAnswer((_) async => "some_token");
      await ConfigService().initialize();
    });
    group("getDiagnoses", () {
      test("calls HttpService.getDiagnoses()", () async {
        // Arrange.
        final mockHttpService = MockHttpService();
        when(mockHttpService.getDiagnoses(any, any)).thenAnswer(
          (_) async => http.Response("[]", 200),
        );
        final diagnosisProvider = DiagnosisProvider(mockHttpService);
        diagnosisProvider.workShopId = "some_workshop_id";
        await diagnosisProvider.fetchAndSetAuthToken(mockAuthProvider);
        // Act.
        await diagnosisProvider.getDiagnoses();
        // Assert.
        verify(mockHttpService.getDiagnoses(any, any)).called(1);
        verifyNoMoreInteractions(mockHttpService);
      });
      test("converts json response to List<DiagnosisModel>", () async {
        // Arrange.
        final mockHttpService = MockHttpService();
        final timeStamp = DateTime(2023, 5, 17, 10, 52, 26);
        const diagnosisStatus = DiagnosisStatus.scheduled;
        const caseId = "some_case_id";
        final List<Map<String, dynamic>> json = [
          {
            "_id": "some_id",
            "timestamp": timeStamp.toIso8601String(),
            "status": diagnosisStatus.name,
            "case_id": caseId,
            "state_machine_log": [],
            "todos": [],
          },
        ];
        when(mockHttpService.getDiagnoses(any, any)).thenAnswer(
          (_) async => http.Response(jsonEncode(json), 200),
        );
        final diagnosisProvider = DiagnosisProvider(mockHttpService);
        diagnosisProvider.workShopId = "some_workshop_id";
        await diagnosisProvider.fetchAndSetAuthToken(mockAuthProvider);
        // Act.
        final List<DiagnosisModel> diagnoses =
            await diagnosisProvider.getDiagnoses();
        // Assert.
        expect(
          diagnoses.length,
          equals(1),
          reason: "should return one diagnosis",
        );
        final DiagnosisModel diagnosis = diagnoses[0];
        expect(
          diagnosis.id,
          equals("some_id"),
          reason: "should have correct id",
        );
        expect(
          diagnosis.timestamp,
          equals(timeStamp),
          reason: "should have correct timestamp",
        );
        expect(
          diagnosis.status,
          equals(diagnosisStatus),
          reason: "should have correct status",
        );
        expect(
          diagnosis.caseId,
          equals(caseId),
          reason: "should have correct caseId",
        );
        expect(
          diagnosis.stateMachineLog,
          isEmpty,
          reason: "should have empty stateMachineLog",
        );
        expect(diagnosis.todos, isEmpty, reason: "should have empty todos");
      });
      test("returns empty list when response is not a list", () async {
        // Arrange.
        final mockHttpService = MockHttpService();
        when(mockHttpService.getDiagnoses(any, any)).thenAnswer(
          (_) async => http.Response("{}", 200),
        );
        final diagnosisProvider = DiagnosisProvider(mockHttpService);
        diagnosisProvider.workShopId = "some_workshop_id";
        await diagnosisProvider.fetchAndSetAuthToken(mockAuthProvider);

        // Act.
        final List<DiagnosisModel> diagnoses =
            await diagnosisProvider.getDiagnoses();

        // Assert.
        expect(diagnoses, isEmpty, reason: "should return empty list");
      });
    });
  });
}
