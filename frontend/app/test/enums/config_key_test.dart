import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("ConfigKey values should be in alphabetical order", () {
    final List<String> values = ConfigKey.values.map((e) => e.name).toList();
    final List<String> sortedValues = List<String>.from(values)..sort();
    expect(values, equals(sortedValues));
  });
  group("DatasetType fromJson", () {
    test("should map strings that correspond to values as normal", () {
      expect(
        DatasetType.fromJson("obd"),
        equals(DatasetType.obd),
      );
      expect(
        DatasetType.fromJson("timeseries"),
        equals(DatasetType.timeseries),
      );
      expect(
        DatasetType.fromJson("symptom"),
        equals(DatasetType.symptom),
      );
      expect(
        DatasetType.fromJson("unknown"),
        equals(DatasetType.unknown),
      );
    });
    test("should map strings that do not correspond to values to unknown", () {
      expect(
        DatasetType.fromJson("not a value"),
        equals(DatasetType.unknown),
      );
    });
  });
}
