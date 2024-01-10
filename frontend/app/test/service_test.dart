import "package:aw40_hub_frontend/services/services.dart";
import "package:flutter/foundation.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  //do not print to console
  debugPrint = (String? message, {int? wrapWidth}) {};
  TestWidgetsFlutterBinding.ensureInitialized();

  group("AuthService", () {
    late AuthService authService;
    setUp(() async {
      authService = AuthService();
      await ConfigService().initialize();
    });
    group("createVerifier", () {
      test("String is 128 chars long", () async {
        final String verifier = authService.createVerifier();
        expect(verifier.length, 128);
      });
      test("has no url unsave characters", () async {
        final String verifier = authService.createVerifier();
        final RegExp reg = RegExp("[^A-Za-z0-9-._~]");
        expect(reg.hasMatch(verifier), false);
      });
      test("two generated verifiers are not the same", () async {
        final String verifier1 = authService.createVerifier();
        final String verifier2 = authService.createVerifier();
        expect(verifier1 == verifier2, false);
      });
    });
    test("createCodeChallenge returns correct code challenge", () async {
      const String verifier =
          // ignore: lines_longer_than_80_chars
          "DWugXmMJCpVkcN9p_qNI-T5.CrBfwiKh.0ofAmmQ3dp1qgCLzKpy1IXB52vpKEKeNa~RQGigrTTCgFoZOHCybQQULmho~uoZASgpCKha9JdIDaRJP4jG5Ssqdsn0UkPN";
      expect(
        authService.createCodeChallenge(verifier),
        "DtjMyISfWjcfCUdjMocTvlj9d63JidFyVKagdWwEGTk",
      );
    });
    group("webGetKeycloakLogoutUrl", () {
      test("returns logout url without redirect if idToken == null", () {
        final String actual = authService.webGetKeycloakLogoutUrl(null);
        assert(actual.endsWith("logout"));
        assert(
          !(actual.contains("redirect") || actual.contains("id_token_hint")),
        );
      });
      test("returns logout url with redirect if idToken != null", () {
        const String idToken = "some_id_token";
        final String actual = authService.webGetKeycloakLogoutUrl(idToken);
        assert(!actual.endsWith("logout"));
        assert(
          actual.contains("post_logout_redirect") &&
              actual.contains("id_token_hint") &&
              actual.contains(idToken),
        );
      });
    });
  });

  group("HttpService", () {});
}
