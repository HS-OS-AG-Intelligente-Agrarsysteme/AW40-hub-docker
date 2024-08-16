import "package:aw40_hub_frontend/models/vehicle_model.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("VehicleModel", () {
    const id = "test_id";
    const vin = "some_vin";
    const tsn = "some_tsn";
    const yearBuild = 2000;

    final vehicleModel = VehicleModel(
      id: id,
      vin: vin,
      tsn: tsn,
      yearBuild: yearBuild,
    );
    test("correctly assigns id", () {
      expect(vehicleModel.id, id);
    });
    test("correctly assigns vin", () {
      expect(vehicleModel.vin, vin);
    });
    test("correctly assigns tsn", () {
      expect(vehicleModel.tsn, tsn);
    });
    test("correctly assigns yearBuild", () {
      expect(vehicleModel.yearBuild, yearBuild);
    });
  });
}
