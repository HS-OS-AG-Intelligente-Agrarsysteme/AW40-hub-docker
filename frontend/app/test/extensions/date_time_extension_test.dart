import "package:aw40_hub_frontend/utils/extensions.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("DateTimeExtension", () {
    test("toGermanDateString() correctly formats string", () {
      final DateTime dateTime = DateTime(1993, 3, 28);
      final String germanDateString = dateTime.toGermanDateString();
      expect(germanDateString, "28.3.1993");
    });
  });
}
