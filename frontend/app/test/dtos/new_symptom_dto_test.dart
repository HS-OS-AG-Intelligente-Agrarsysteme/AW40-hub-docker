import "package:aw40_hub_frontend/dtos/new_symptom_dto.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("NewSymptomDto primary constructor", () {
    const String component = "some_component";
    const SymptomLabel label = SymptomLabel.ok;
    final NewSymptomDto newSymptomDto = NewSymptomDto(
      component,
      label,
    );
    test("correctly assigns component", () {
      expect(newSymptomDto.component, component);
    });
    test("correctly assigns label", () {
      expect(newSymptomDto.label, label);
    });
  });
  group("NewSymptomDto fromJson constructor", () {
    final timestamp = DateTime.utc(2021).toIso8601String();
    const String component = "some_component";
    const SymptomLabel label = SymptomLabel.ok;
    final Map<String, dynamic> json = <String, dynamic>{
      "timestamp": timestamp,
      "component": component,
      "label": label.name,
    };
    final NewSymptomDto newSymptomDto = NewSymptomDto.fromJson(json);
    test("correctly assigns component", () {
      expect(newSymptomDto.component, component);
    });
    test("correctly assigns label", () {
      expect(newSymptomDto.label, label);
    });
  });
  group("NewSymptomDto toJson method", () {
    const String component = "some_component";
    const SymptomLabel label = SymptomLabel.ok;
    final NewSymptomDto newSymptomDto = NewSymptomDto(
      component,
      label,
    );
    final Map<String, dynamic> json = newSymptomDto.toJson();
    test("correctly assigns component", () {
      expect(json["component"], component);
    });
    test("correctly assigns label", () {
      expect(json["label"], label.name);
    });
  });
}
