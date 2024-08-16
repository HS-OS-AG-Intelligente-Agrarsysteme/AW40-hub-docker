import "package:aw40_hub_frontend/dtos/vehicle_dto.dart";
import "package:aw40_hub_frontend/models/vehicle_model.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("VehicleDto primary constructor", () {
    const id = "test_id";
    const vin = "some_vin";
    const tsn = "some_tsn";
    const yearBuild = 2000;
    final VehicleDto vehicleDto = VehicleDto(
      id,
      vin,
      tsn,
      yearBuild,
    );
    test("correctly assigns id", () {
      expect(vehicleDto.id, id);
    });
    test("correctly assigns vin", () {
      expect(vehicleDto.vin, vin);
    });
    test("correctly assigns tsn", () {
      expect(vehicleDto.tsn, tsn);
    });
    test("correctly assigns yearBuild", () {
      expect(vehicleDto.yearBuild, yearBuild);
    });
  });
  group("VehicleDto fromJson constructor", () {
    const id = "test_id";
    const vin = "some_vin";
    const tsn = "some_tsn";
    const yearBuild = 2000;
    final Map<String, dynamic> json = <String, dynamic>{
      "_id": id,
      "vin": vin,
      "tsn": tsn,
      "year_build": yearBuild,
    };
    final VehicleDto vehicleDto = VehicleDto.fromJson(json);
    test("correctly assigns id", () {
      expect(vehicleDto.id, id);
    });
    test("correctly assigns vin", () {
      expect(vehicleDto.vin, vin);
    });
    test("correctly assigns tsn", () {
      expect(vehicleDto.tsn, tsn);
    });
    test("correctly assigns yearBuild", () {
      expect(vehicleDto.yearBuild, yearBuild);
    });
  });
  group("VehicleDto toJson method", () {
    const id = "test_id";
    const vin = "some_vin";
    const tsn = "some_tsn";
    const yearBuild = 2000;
    final VehicleDto vehicleDto = VehicleDto(
      id,
      vin,
      tsn,
      yearBuild,
    );
    final Map<String, dynamic> json = vehicleDto.toJson();
    test("correctly assigns id", () {
      expect(json["_id"], id);
    });
    test("correctly assigns vin", () {
      expect(json["vin"], vin);
    });
    test("correctly assigns tsn", () {
      expect(json["tsn"], tsn);
    });
    test("correctly assigns yearBuild", () {
      expect(json["year_build"], yearBuild);
    });
  });

  group("VehicleDto toModel method", () {
    const id = "test_id";
    const vin = "some_vin";
    const tsn = "some_tsn";
    const yearBuild = 2000;
    final VehicleDto vehicleDto = VehicleDto(
      id,
      vin,
      tsn,
      yearBuild,
    );
    final VehicleModel vehicleModel = vehicleDto.toModel();
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
