import "package:aw40_hub_frontend/models/timeseries_data_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("TimeseriesDataModel", () {
    final timestamp = DateTime.now();
    const String component = "some_component";
    const TimeseriesDataLabel label = TimeseriesDataLabel.norm;
    const int samplingRate = 1;
    const int duration = 3;
    const TimeseriesType type = TimeseriesType.oscillogram;
    const dynamic deviceSpecs = 0;
    const int dataId = 5;
    const signalId = "some_String";
    final TimeseriesDataModel timeseriesDataModel = TimeseriesDataModel(
      timestamp: timestamp,
      component: component,
      label: label,
      samplingRate: samplingRate,
      duration: duration,
      type: type,
      deviceSpecs: deviceSpecs,
      dataId: dataId,
      signalId: signalId,
    );
    test("correctly assigns timestamp", () {
      expect(timeseriesDataModel.timestamp, timestamp);
    });
    test("correctly assigns component", () {
      expect(timeseriesDataModel.component, component);
    });
    test("correctly assigns label", () {
      expect(timeseriesDataModel.label, label);
    });
    test("correctly assigns samplingRate", () {
      expect(timeseriesDataModel.samplingRate, samplingRate);
    });
    test("correctly assigns duration", () {
      expect(timeseriesDataModel.duration, duration);
    });
    test("correctly assigns type", () {
      expect(timeseriesDataModel.type, type);
    });
    test("correctly assigns dataId", () {
      expect(timeseriesDataModel.dataId, dataId);
    });
    test("correctly assigns signalId", () {
      expect(timeseriesDataModel.signalId, signalId);
    });
  });
}
