@GenerateNiceMocks([MockSpec<HttpService>(), MockSpec<AuthProvider>()])
import "dart:convert";

import "package:aw40_hub_frontend/models/customer_model.dart";
import "package:aw40_hub_frontend/providers/auth_provider.dart";
import "package:aw40_hub_frontend/providers/customer_provider.dart";
import "package:aw40_hub_frontend/services/config_service.dart";
import "package:aw40_hub_frontend/services/http_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";

import "diagnosis_provider_test.mocks.dart";

void main() {
  group("CustomerProvider", () {
    final mockAuthProvider = MockAuthProvider();
    setUpAll(() async {
      when(mockAuthProvider.getAuthToken())
          .thenAnswer((_) async => "some_token");
      await ConfigService().initialize();
    });
    group("getVehicles", () {
      test("calls HttpService.getSharedCostumers()", () async {
        // Arrange.
        final mockHttpService = MockHttpService();
        when(mockHttpService.getSharedCustomers(any)).thenAnswer(
          (_) async => http.Response("[]", 200),
        );
        final costumerProvider = CustomerProvider(mockHttpService);
        //costumerProvider.workshopId = "some_workshop_id";
        //const String costumerId = "some_id";
        await costumerProvider.fetchAndSetAuthToken(mockAuthProvider);
        // Act.
        await costumerProvider.getSharedCustomers();
        // Assert.
        verify(mockHttpService.getSharedCustomers(any)).called(1);
        verifyNoMoreInteractions(mockHttpService);
      });

      test("converts json response to List<CostumerModel>", () async {
        // Arrange.
        final mockHttpService = MockHttpService();
        const id = AnonymousCustomerId.anonymous;
        final List<Map<String, dynamic>> json = [
          {
            "_id": id.name,
          },
        ];
        when(mockHttpService.getSharedCustomers(any)).thenAnswer(
          (_) async => http.Response(jsonEncode(json), 200),
        );
        final costumerProvider = CustomerProvider(mockHttpService);
        //costumerProvider.workshopId = "some_workshop_id";
        //const String costumerId = "some_id";
        await costumerProvider.fetchAndSetAuthToken(mockAuthProvider);
        // Act.
        final List<CustomerModel> diagnoses =
            await costumerProvider.getSharedCustomers();
        // Assert.
        expect(
          diagnoses.length,
          equals(1),
          reason: "should return one diagnosis",
        );
        final CustomerModel diagnosis = diagnoses[0];
        expect(
          diagnosis.id,
          equals(AnonymousCustomerId.anonymous),
          reason: "should have correct id",
        );
      });
    });
  });
}
