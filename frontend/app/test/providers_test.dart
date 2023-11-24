import "dart:convert";

import "package:aw40_hub_frontend/dtos/dtos.dart";
import "package:aw40_hub_frontend/providers/providers.dart";
import "package:aw40_hub_frontend/services/services.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";

@GenerateNiceMocks([MockSpec<HttpService>()])
import "providers_test.mocks.dart";

void main() {
  group("CaseProvider", () {
    setUpAll(() async => ConfigService().initialize());
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
      final caseProvider = CaseProvider(HttpService());
      expect(caseProvider.showSharedCases, true);
    });
    test("toggleShowSharedCases toggles showSharedCases", () async {
      final mockHttpService = MockHttpService();
      when(mockHttpService.getSharedCases()).thenAnswer(
        (_) async => http.Response("[]", 200),
      );
      when(mockHttpService.getCases(any)).thenAnswer(
        (_) async => http.Response("[]", 200),
      );
      final caseProvider = CaseProvider(mockHttpService);
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
          when(mockHttpService.getSharedCases()).thenAnswer(
            (_) async => http.Response("[]", 200),
          );
          final caseProvider = CaseProvider(mockHttpService);
          if (caseProvider.showSharedCases == false) {
            await caseProvider.toggleShowSharedCases();
          }
          assert(caseProvider.showSharedCases == true);
          await caseProvider.getCurrentCases();
          verify(mockHttpService.getSharedCases()).called(1);
          verifyNever(mockHttpService.getCases(any));
        },
      );
      test(
          "getCurrentCases() calls HttpService.getCases() "
          "when showSharedCases=false", () async {
        final mockHttpService = MockHttpService();
        when(mockHttpService.getCases(any)).thenAnswer(
          (_) async => http.Response("[]", 200),
        );
        final caseProvider = CaseProvider(mockHttpService);
        caseProvider.workShopId = "some_workshop_id";
        if (caseProvider.showSharedCases == true) {
          // First call to `getCases()`.
          await caseProvider.toggleShowSharedCases();
        }
        assert(caseProvider.showSharedCases == false);
        // Second call to `getCases()`.
        await caseProvider.getCurrentCases();
        verify(mockHttpService.getCases(any)).called(2);
        verifyNever(mockHttpService.getSharedCases());
      });
    });
    group("addCase()", () {
      test("calls HttpService.addCase()", () async {
        final mockHttpService = MockHttpService();
        when(mockHttpService.addCase(any, any)).thenAnswer(
          (_) async => http.Response(jsonEncode(dummyCaseDtoJson), 201),
        );
        final caseProvider = CaseProvider(mockHttpService);
        caseProvider.workShopId = "some_workshop_id";
        await caseProvider.addCase(dummyNewCaseDto);
        verify(mockHttpService.addCase(any, any)).called(1);
      });
    });
    group("deleteCase()", () {
      test("calls HttpService.deleteCase()", () async {
        final mockHttpService = MockHttpService();
        when(mockHttpService.deleteCase(any, any)).thenAnswer(
          (_) async => http.Response("{}", 201),
        );
        final caseProvider = CaseProvider(mockHttpService);
        caseProvider.workShopId = "some_workshop_id";
        await caseProvider.deleteCase("some_case_id");
        verify(mockHttpService.deleteCase(any, any)).called(1);
      });
    });
  });
}
