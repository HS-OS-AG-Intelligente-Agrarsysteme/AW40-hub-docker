import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("ConfigKey values should be in alphabetical order", () {
    final List<String> values = ConfigKey.values.map((e) => e.name).toList();
    final List<String> sortedValues = List<String>.from(values)..sort();
    expect(values, equals(sortedValues));
  });
}
