import "package:aw40_hub_frontend/dtos/new_timeseries_data_dto.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("NewTimeseriesDataDto fromJson constructor", () {
    const String component = "some_component";
    const TimeseriesDataLabel label = TimeseriesDataLabel.norm;
    const int samplingRate = 1;
    const int duration = 3;
    const TimeseriesType type = TimeseriesType.oscillogram;
    const dynamic deviceSpecs = 0;
    const signal = <String>["some_String", "3"];
    final Map<String, dynamic> json = <String, dynamic>{
      "component": component,
      "label": label.name,
      "sampling_rate": samplingRate,
      "duration": duration,
      "type": type.name,
      "device_specs": deviceSpecs,
      "signal": signal,
    };
    final NewTimeseriesDataDto newTimeseriesDataDto =
        NewTimeseriesDataDto.fromJson(json);
    test("correctly assigns component", () {
      expect(newTimeseriesDataDto.component, component);
    });
    test("correctly assigns label", () {
      expect(newTimeseriesDataDto.label, label);
    });
    test("correctly assigns samplingRate", () {
      expect(newTimeseriesDataDto.samplingRate, samplingRate);
    });
    test("correctly assigns duration", () {
      expect(newTimeseriesDataDto.duration, duration);
    });
    test("correctly assigns type", () {
      expect(newTimeseriesDataDto.type, type);
    });
    test("correctly assigns deviceSpecs", () {
      expect(newTimeseriesDataDto.deviceSpecs, deviceSpecs);
    });
    test("correctly assigns signal", () {
      expect(newTimeseriesDataDto.signal, signal);
    });
  });
  group("NewTimeseriesDataDto toJson method", () {
    const String component = "some_component";
    const TimeseriesDataLabel label = TimeseriesDataLabel.norm;
    const int samplingRate = 1;
    const int duration = 3;
    const TimeseriesType type = TimeseriesType.oscillogram;
    const dynamic deviceSpecs = 0;
    const signal = <String>["some_String", "3"];
    final NewTimeseriesDataDto newTimeseriesDataDto = NewTimeseriesDataDto(
      component,
      label,
      samplingRate,
      duration,
      type,
      deviceSpecs,
      signal,
    );
    final Map<String, dynamic> json = newTimeseriesDataDto.toJson();
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
    test("correctly assigns signal", () {
      expect(json["signal"], signal);
    });
  });
}
