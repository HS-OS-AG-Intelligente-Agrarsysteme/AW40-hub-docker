import "package:aw40_hub_frontend/models/symptom_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("SymptomModel", () {
    final timestamp = DateTime.now();
    const String component = "some_component";
    const SymptomLabel label = SymptomLabel.unknown;
    const int dataId = 2;
    final SymptomModel symptomModel = SymptomModel(
      timestamp: timestamp,
      component: component,
      label: label,
      dataId: dataId,
    );
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
