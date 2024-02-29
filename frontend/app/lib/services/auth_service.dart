import "dart:convert";
import "dart:math";
import "package:aw40_hub_frontend/exceptions/exceptions.dart";
import "package:aw40_hub_frontend/services/services.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
import "package:crypto/crypto.dart";
import "package:logging/logging.dart";

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
    final String clientId =
        ConfigService().getConfigValue(ConfigKey.keyCloakClient);
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
        "${ConfigService().getConfigValue(ConfigKey.proxyDefaultScheme)}"
        "://"
        "${ConfigService().getConfigValue(ConfigKey.keyCloakAddress)}"
        "/realms/<REALM>/protocol/openid-connect/";

    if (!keyCloakBaseUrl.contains(kRealmPlaceholder)) {
      throw AppException(
        exceptionMessage:
            "No Keycloak-Realm-Placeholder found in KC_BASE_URL: Please set "
            'placeholder "$kRealmPlaceholder" correctly and set realm only in '
            "KC_REALM_FALLBACK",
        exceptionType: ExceptionType.notFound,
      );
    }

    final String kcRealm =
        ConfigService().getConfigValue(ConfigKey.keyCloakRealm);
    return keyCloakBaseUrl.replaceFirst(kRealmPlaceholder, kcRealm);
  }

  String webGetKeycloakLogoutUrl(String? idToken) {
    final String proxyDefaultScheme =
        ConfigService().getConfigValue(ConfigKey.proxyDefaultScheme);
    final String frontendAddress =
        ConfigService().getConfigValue(ConfigKey.frontendAddress);
    String rootDomain = "$proxyDefaultScheme://$frontendAddress";
    if (rootDomain.contains("*")) {
      final String realm =
          ConfigService().getConfigValue(ConfigKey.keyCloakRealm);
      rootDomain = rootDomain.replaceAll("*", realm);
    }
    if (idToken == null) return "${getKeyCloakUrlWithRealm()}logout";
    return "${getKeyCloakUrlWithRealm()}logout?post_logout_redirect_uri="
        "$rootDomain&id_token_hint=$idToken";
  }
}
