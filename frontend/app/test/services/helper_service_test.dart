import "package:aw40_hub_frontend/services/helper_service.dart";
import "package:flutter_test/flutter_test.dart";
import "package:logging/logging.dart";

void main() {
  group("HelperService", () {
    group("stringToLogLevel", () {
      test("returns Level.FINEST for 'finest'", () {
        expect(HelperService.stringToLogLevel("finest"), Level.FINEST);
      });
      test("returns Level.FINER for 'finer'", () {
        expect(HelperService.stringToLogLevel("finer"), Level.FINER);
      });
      test("returns Level.FINE for 'fine'", () {
        expect(HelperService.stringToLogLevel("fine"), Level.FINE);
      });
      test("returns Level.CONFIG for 'config'", () {
        expect(HelperService.stringToLogLevel("config"), Level.CONFIG);
      });
      test("returns Level.INFO for 'info'", () {
        expect(HelperService.stringToLogLevel("info"), Level.INFO);
      });
      test("returns Level.WARNING for 'warning'", () {
        expect(HelperService.stringToLogLevel("warning"), Level.WARNING);
      });
      test("returns Level.SEVERE for 'severe'", () {
        expect(HelperService.stringToLogLevel("severe"), Level.SEVERE);
      });
      test("returns Level.SHOUT for 'shout'", () {
        expect(HelperService.stringToLogLevel("shout"), Level.SHOUT);
      });
      test("returns null for other values", () {
        expect(HelperService.stringToLogLevel("some_other_value"), null);
      });
      test("is case insensitive", () {
        expect(HelperService.stringToLogLevel("fInEsT"), Level.FINEST);
        expect(HelperService.stringToLogLevel("FiNer"), Level.FINER);
        expect(HelperService.stringToLogLevel("fInE"), Level.FINE);
        expect(HelperService.stringToLogLevel("CoNfIg"), Level.CONFIG);
        expect(HelperService.stringToLogLevel("iNfO"), Level.INFO);
        expect(HelperService.stringToLogLevel("WaRnInG"), Level.WARNING);
        expect(HelperService.stringToLogLevel("sEvErE"), Level.SEVERE);
        expect(HelperService.stringToLogLevel("ShOuT"), Level.SHOUT);
      });
    });
  });
}
