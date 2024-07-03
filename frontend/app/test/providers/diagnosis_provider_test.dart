import "dart:convert";

import "package:aw40_hub_frontend/models/diagnosis_model.dart";
import "package:aw40_hub_frontend/providers/auth_provider.dart";
import "package:aw40_hub_frontend/providers/diagnosis_provider.dart";
import "package:aw40_hub_frontend/services/config_service.dart";
import "package:aw40_hub_frontend/services/http_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";

@GenerateNiceMocks([MockSpec<HttpService>(), MockSpec<AuthProvider>()])
import "diagnosis_provider_test.mocks.dart";

void main() {
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
