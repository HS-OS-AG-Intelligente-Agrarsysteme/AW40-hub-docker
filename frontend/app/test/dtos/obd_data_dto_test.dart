import "package:aw40_hub_frontend/dtos/obd_data_dto.dart";
import "package:aw40_hub_frontend/models/obd_data_model.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("ObdDataDto fromJson constructor", () {
    final timestamp = DateTime.utc(2021);
    final obdSpecs = <dynamic>[1, 2, 3];
    final dtcs = <String>["some_component"];
    const int dataId = 0;
    final Map<String, dynamic> json = <String, dynamic>{
      "timestamp": timestamp.toIso8601String(),
      "obd_specs": obdSpecs,
      "dtcs": dtcs,
      "data_id": dataId,
    };
    final ObdDataDto obdDataDto = ObdDataDto.fromJson(json);
    test("correctly assigns timestamp", () {
      expect(obdDataDto.timestamp, timestamp);
    });
    test("correctly assigns obdSpecs", () {
      expect(obdDataDto.obdSpecs, obdSpecs);
    });
    test("correctly assigns dtcs", () {
      expect(obdDataDto.dtcs, dtcs);
    });
    test("correctly assigns dataId", () {
      expect(obdDataDto.dataId, dataId);
    });
  });
  group("ObdDataDto toJson method", () {
    final timestamp = DateTime.utc(2021);
    final obdSpecs = <dynamic>[1, 2, 3];
    final dtcs = <String>["some_component"];
    const int dataId = 0;
    final ObdDataDto obdDataDto = ObdDataDto(
      timestamp,
      obdSpecs,
      dtcs,
      dataId,
    );
    final Map<String, dynamic> json = obdDataDto.toJson();
    test("correctly assigns timestamp", () {
      expect(json["timestamp"], timestamp.toIso8601String());
    });
    test("correctly assigns obdSpecs", () {
      expect(json["obd_specs"], obdSpecs);
    });
    test("correctly assigns dtcs", () {
      expect(json["dtcs"], dtcs);
    });
    test("correctly assigns dataId", () {
      expect(json["data_id"], dataId);
    });
  });
  group("ObdDataDto toModel method", () {
    final timestamp = DateTime.utc(2021);
    final obdSpecs = <dynamic>[1, 2, 3];
    final dtcs = <String>["some_component"];
    const int dataId = 0;
    final ObdDataDto obdDataDto = ObdDataDto(
      timestamp,
      obdSpecs,
      dtcs,
      dataId,
    );
    final ObdDataModel obdDataModel = obdDataDto.toModel();
    test("correctly assigns timestamp", () {
      expect(obdDataModel.timestamp, timestamp);
    });
    test("correctly assigns obdSpecs", () {
      expect(obdDataModel.obdSpecs, obdSpecs);
    });
    test("correctly assigns dtcs", () {
      expect(obdDataModel.dtcs, dtcs);
    });
    test("correctly assigns dataId", () {
      expect(obdDataModel.dataId, dataId);
    });
  });
}
