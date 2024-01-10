import "dart:convert";
import "dart:math";
import "package:aw40_hub_frontend/exceptions/exceptions.dart";
import "package:aw40_hub_frontend/services/services.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
import "package:crypto/crypto.dart";
import "package:logging/logging.dart";
import "package:universal_html/html.dart" as html;

class AuthService {
  static const String _charset =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~";
  static const String kRealmPlaceholder = "<REALM>";
  final Logger _logger = Logger("auth_service");

  String generateKeyCloakLoginUrl({
    required String redirectUri,
    required String codeChallenge,
    required String langCode,
  }) {
    final String keyCloakUrlWithRealm = getKeyCloakUrlWithRealm();
    final String clientId = ConfigService().getConfigValue(ConfigKey.kcClient);
    const String kKcAuthEndpoint = "auth?response_type=code&scope=openid";
    final String url =
        "$keyCloakUrlWithRealm$kKcAuthEndpoint&client_id=$clientId"
        "&ui_locales=$langCode&kc_locale=$langCode&redirect_uri=$redirectUri"
        "&code_challenge=$codeChallenge&code_challenge_method=S256";
    return url;
  }

  String createVerifier() {
    final String verifier = List.generate(
      128,
      (int i) => _charset[Random.secure().nextInt(_charset.length)],
    ).join();
    _logger.info("created verifier: $verifier");
    return verifier;
  }

  String createCodeChallenge(String verifier) {
    return base64Url
        .encode(sha256.convert(ascii.encode(verifier)).bytes)
        .replaceAll("=", "");
  }

  String getKeyCloakUrlWithRealm() {
    final String keyCloakBaseUrl =
        ConfigService().getConfigValue(ConfigKey.kcBaseUrl);
    if (!keyCloakBaseUrl.contains(kRealmPlaceholder)) {
      throw AppException(
        exceptionMessage:
            "No Keycloak-Realm-Placeholder found in KC_BASE_URL: Please set "
            'placeholder "$kRealmPlaceholder" correctly and set realm only in '
            "KC_REALM_FALLBACK",
        exceptionType: ExceptionType.notFound,
      );
    }

    final String kcRealm = ConfigService().getConfigValue(ConfigKey.kcRealm);
    return keyCloakBaseUrl.replaceFirst(kRealmPlaceholder, kcRealm);
  }

  String webGetKeycloakLogoutUrl(String? idToken) {
    String rootDomain = ConfigService().getConfigValue(ConfigKey.rootDomain);
    final bool isHttps = !html.window.location.href.contains("localhost");
    if (rootDomain.contains("*")) {
      final String realm = ConfigService().getConfigValue(ConfigKey.kcRealm);
      rootDomain = rootDomain.replaceAll("*", realm);
    }
    if (idToken == null) return "${getKeyCloakUrlWithRealm()}logout";
    return "${getKeyCloakUrlWithRealm()}logout?post_logout_redirect_uri=http${isHttps ? "s" : ""}://$rootDomain&id_token_hint=$idToken";
  }
}
