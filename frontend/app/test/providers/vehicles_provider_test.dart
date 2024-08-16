@GenerateNiceMocks([MockSpec<HttpService>(), MockSpec<AuthProvider>()])
import "dart:convert";

import "package:aw40_hub_frontend/models/vehicle_model.dart";
import "package:aw40_hub_frontend/providers/auth_provider.dart";
import "package:aw40_hub_frontend/providers/vehicle_provider.dart";
import "package:aw40_hub_frontend/services/config_service.dart";
import "package:aw40_hub_frontend/services/http_service.dart";
import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";

import "diagnosis_provider_test.mocks.dart";

void main() {
  group("DiagnosisProvider", () {
    final mockAuthProvider = MockAuthProvider();
    setUpAll(() async {
      when(mockAuthProvider.getAuthToken())
          .thenAnswer((_) async => "some_token");
      await ConfigService().initialize();
    });
    group("getVehicles", () {
      test("calls HttpService.getSharedVehicles()", () async {
        // Arrange.
        final mockHttpService = MockHttpService();
        when(mockHttpService.getSharedVehicles(any)).thenAnswer(
          (_) async => http.Response("[]", 200),
        );
        final vehiclesProvider = VehicleProvider(mockHttpService);
        vehiclesProvider.workshopId = "some_workshop_id";
        await vehiclesProvider.fetchAndSetAuthToken(mockAuthProvider);
        // Act.
        await vehiclesProvider.getSharedVehicles();
        // Assert.
        verify(mockHttpService.getSharedVehicles(any)).called(1);
        verifyNoMoreInteractions(mockHttpService);
      });

      test("converts json response to List<DiagnosisModel>", () async {
        // Arrange.
        final mockHttpService = MockHttpService();
        const id = "some_id";
        const vin = "some_vin";
        const tsn = "some_tsn";
        const yearBuild = 2000;
        final List<Map<String, dynamic>> json = [
          {
            "_id": id,
            "vin": vin,
            "tsn": tsn,
            "year_build": yearBuild,
          },
        ];
        when(
          mockHttpService.getSharedVehicles(
            any,
          ),
        ).thenAnswer(
          (_) async => http.Response(jsonEncode(json), 200),
        );
        final vehiclesProvider = VehicleProvider(mockHttpService);
        vehiclesProvider.workshopId = "some_workshop_id";
        await vehiclesProvider.fetchAndSetAuthToken(mockAuthProvider);
        // Act.
        final List<VehicleModel> diagnoses =
            await vehiclesProvider.getSharedVehicles();
        // Assert.
        expect(
          diagnoses.length,
          equals(1),
          reason: "should return one diagnosis",
        );
        final VehicleModel diagnosis = diagnoses[0];
        expect(
          diagnosis.id,
          equals("some_id"),
          reason: "should have correct id",
        );
        expect(
          diagnosis.vin,
          equals("some_vin"),
          reason: "should have correct vin",
        );
        expect(
          diagnosis.tsn,
          equals("some_tsn"),
          reason: "should have correct tsn",
        );
        expect(
          diagnosis.yearBuild,
          equals(2000),
          reason: "should have correct yearBuild",
        );
      });
    });
  });
}
