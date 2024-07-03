import "package:aw40_hub_frontend/dtos/timeseries_data_dto.dart";
import "package:aw40_hub_frontend/models/timeseries_data_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("TimeseriesDataDto fromJson constructor", () {
    final timestamp = DateTime.utc(2021);
    const String component = "some_component";
    const TimeseriesDataLabel label = TimeseriesDataLabel.norm;
    const int samplingRate = 1;
    const int duration = 3;
    const TimeseriesType type = TimeseriesType.oscillogram;
    const dynamic deviceSpecs = 0;
    const int dataId = 5;
    const signalId = "some_string";
    final Map<String, dynamic> json = <String, dynamic>{
      "timestamp": timestamp.toIso8601String(),
      "component": component,
      "label": label.name,
      "sampling_rate": samplingRate,
      "duration": duration,
      "type": type.name,
      "device_specs": deviceSpecs,
      "data_id": dataId,
      "signal_id": signalId,
    };
    final TimeseriesDataDto timeseriesDataDto =
        TimeseriesDataDto.fromJson(json);
    test("correctly assigns timestamp", () {
      expect(timeseriesDataDto.timestamp, timestamp);
    });
    test("correctly assigns component", () {
      expect(timeseriesDataDto.component, component);
    });
    test("correctly assigns label", () {
      expect(timeseriesDataDto.label, label);
    });
    test("correctly assigns samplingRate", () {
      expect(timeseriesDataDto.samplingRate, samplingRate);
    });
    test("correctly assigns duration", () {
      expect(timeseriesDataDto.duration, duration);
    });
    test("correctly assigns type", () {
      expect(timeseriesDataDto.type, type);
    });
    test("correctly assigns deviceSpecs", () {
      expect(timeseriesDataDto.deviceSpecs, deviceSpecs);
    });
    test("correctly assigns dataId", () {
      expect(timeseriesDataDto.dataId, dataId);
    });
    test("correctly assigns signalId", () {
      expect(timeseriesDataDto.signalId, signalId);
    });
  });
  group("TimeseriesDataDto toJson method", () {
    final timestamp = DateTime.utc(2021);
    const String component = "some_component";
    const TimeseriesDataLabel label = TimeseriesDataLabel.norm;
    const int samplingRate = 1;
    const int duration = 3;
    const TimeseriesType type = TimeseriesType.oscillogram;
    const dynamic deviceSpecs = 0;
    const int dataId = 5;
    const signalId = "some_String";
    final TimeseriesDataDto timeseriesDataDto = TimeseriesDataDto(
      timestamp,
      component,
      label,
      samplingRate,
      duration,
      type,
      deviceSpecs,
      dataId,
      signalId,
    );
    final Map<String, dynamic> json = timeseriesDataDto.toJson();
    test("correctly assigns timestamp", () {
      expect(json["timestamp"], timestamp.toIso8601String());
    });
    test("correctly assigns component", () {
      expect(json["component"], component);
    });
    test("correctly assigns label", () {
      expect(json["label"], label.name);
    });
    test("correctly assigns samplingRate", () {
      expect(json["sampling_rate"], samplingRate);
    });
    test("correctly assigns duration", () {
      expect(json["duration"], duration);
    });
    test("correctly assigns type", () {
      expect(json["type"], type.name);
    });
    test("correctly assigns deviceSpecs", () {
      expect(json["device_specs"], deviceSpecs);
    });
    test("correctly assigns dataId", () {
      expect(json["data_id"], dataId);
    });
    test("correctly assigns signalId", () {
      expect(json["signal_id"], signalId);
    });
  });
  group("TimeseriesDataDto toModel method", () {
    final timestamp = DateTime.utc(2021);
    const String component = "some_component";
    const TimeseriesDataLabel label = TimeseriesDataLabel.norm;
    const int samplingRate = 1;
    const int duration = 3;
    const TimeseriesType type = TimeseriesType.oscillogram;
    const dynamic deviceSpecs = 0;
    const int dataId = 5;
    const signalId = "some_String";
    final TimeseriesDataDto timeseriesDataDto = TimeseriesDataDto(
      timestamp,
      component,
      label,
      samplingRate,
      duration,
      type,
      deviceSpecs,
      dataId,
      signalId,
    );
    final TimeseriesDataModel timeseriesDataModel = timeseriesDataDto.toModel();
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
    test("correctly assigns deviceSpecs", () {
      expect(timeseriesDataModel.deviceSpecs, deviceSpecs);
    });
    test("correctly assigns dataId", () {
      expect(timeseriesDataModel.dataId, dataId);
    });
    test("correctly assigns signalId", () {
      expect(timeseriesDataModel.signalId, signalId);
    });
  });
}
