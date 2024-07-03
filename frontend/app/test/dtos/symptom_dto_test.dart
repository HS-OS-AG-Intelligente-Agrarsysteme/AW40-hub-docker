import "package:aw40_hub_frontend/dtos/symptom_dto.dart";
import "package:aw40_hub_frontend/models/symptom_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("SymptomDto fromJson constructor", () {
    final timestamp = DateTime.utc(2021);
    const String component = "some_component";
    const SymptomLabel label = SymptomLabel.unknown;
    const int dataId = 2;
    final Map<String, dynamic> json = <String, dynamic>{
      "timestamp": timestamp.toIso8601String(),
      "component": component,
      "label": label.name,
      "data_id": dataId,
    };
    final SymptomDto symptomDto = SymptomDto.fromJson(json);
    test("correctly assigns timestamp", () {
      expect(symptomDto.timestamp, timestamp);
    });
    test("correctly assigns component", () {
      expect(symptomDto.component, component);
    });
    test("correctly assigns label", () {
      expect(symptomDto.label, label);
    });
    test("correctly assigns dataId", () {
      expect(symptomDto.dataId, dataId);
    });
  });
  group("SymptomDto toJson method", () {
    final timestamp = DateTime.utc(2021);
    const String component = "some_component";
    const SymptomLabel label = SymptomLabel.unknown;
    const int dataId = 2;
    final SymptomDto symptomDto = SymptomDto(
      timestamp,
      component,
      label,
      dataId,
    );
    final Map<String, dynamic> json = symptomDto.toJson();
    test("correctly assigns timestamp", () {
      expect(json["timestamp"], timestamp.toIso8601String());
    });
    test("correctly assigns component", () {
      expect(json["component"], component);
    });
    test("correctly assigns label", () {
      expect(json["label"], label.name);
    });
    test("correctly assigns dataId", () {
      expect(json["data_id"], dataId);
    });
  });
  group("SymptomDto toModel method", () {
    final timestamp = DateTime.utc(2021);
    const String component = "some_component";
    const SymptomLabel label = SymptomLabel.unknown;
    const int dataId = 2;
    final SymptomDto symptomDto = SymptomDto(
      timestamp,
      component,
      label,
      dataId,
    );
    final SymptomModel symptomModel = symptomDto.toModel();
    test("correctly assigns timestamp", () {
      expect(symptomModel.timestamp, timestamp);
    });
    test("correctly assigns component", () {
      expect(symptomModel.component, component);
    });
    test("correctly assigns label", () {
      expect(symptomModel.label, label);
    });
    test("correctly assigns dataId", () {
      expect(symptomModel.dataId, dataId);
    });
  });
}
