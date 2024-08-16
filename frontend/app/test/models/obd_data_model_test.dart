import "package:aw40_hub_frontend/models/obd_data_model.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("ObdDataModel", () {
    final timestamp = DateTime.now();
    final obdSpecs = <dynamic>[1, 2, 3];
    final dtcs = <String>["some_component"];
    const int dataId = 0;
    final obdDataModel = ObdDataModel(
      timestamp: timestamp,
      obdSpecs: obdSpecs,
      dtcs: dtcs,
      dataId: dataId,
    );
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
