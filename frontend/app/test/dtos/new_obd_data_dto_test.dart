import "package:aw40_hub_frontend/dtos/new_obd_data_dto.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("NewOBDDataDto primary constructor", () {
    final obdSpecs = <dynamic>[1, 2, 3];
    final dtcs = <String>["some_component"];
    final NewOBDDataDto newOBDDataDto = NewOBDDataDto(
      obdSpecs,
      dtcs,
    );
    test("correctly assigns obdSpecs", () {
      expect(newOBDDataDto.obdSpecs, obdSpecs);
    });
    test("correctly assigns dtcs", () {
      expect(newOBDDataDto.dtcs, dtcs);
    });
  });
  group("NewOBDDataDto fromJson constructor", () {
    final timestamp = DateTime.utc(2021).toIso8601String();
    final obdSpecs = <dynamic>[1, 2, 3];
    final dtcs = <String>["some_component"];
    final Map<String, dynamic> json = <String, dynamic>{
      "timestamp": timestamp,
      "obd_specs": obdSpecs,
      "dtcs": dtcs,
    };
    final NewOBDDataDto newOBDDataDto = NewOBDDataDto.fromJson(json);
    test("correctly assigns obdSpecs", () {
      expect(newOBDDataDto.obdSpecs, obdSpecs);
    });
    test("correctly assigns dtcs", () {
      expect(newOBDDataDto.dtcs, dtcs);
    });
  });
  group("NewOBDDataDto toJson method", () {
    final obdSpecs = <dynamic>[1, 2, 3];
    final dtcs = <String>["some_component"];
    final NewOBDDataDto newOBDDataDto = NewOBDDataDto(
      obdSpecs,
      dtcs,
    );
    final Map<String, dynamic> json = newOBDDataDto.toJson();
    test("correctly assigns dtcs", () {
      expect(json["obd_specs"], obdSpecs);
    });
    test("correctly assigns dtcs", () {
      expect(json["dtcs"], dtcs);
    });
  });
}
