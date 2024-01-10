import "package:envied/envied.dart";

part "env.g.dart";

@Envied(path: "../frontend.env", obfuscate: true)
abstract class Env {
  @EnviedField(varName: "BACKEND_URL")
  static final String backendUrl = _Env.backendUrl;
  @EnviedField(varName: "BASIC_AUTH_KEY")
  static final String basicAuthKey = _Env.basicAuthKey;
  @EnviedField(varName: "KC_CLIENT")
  static final String kcClient = _Env.kcClient;
  @EnviedField(varName: "KC_BASE_URL")
  static final String kcBaseUrl = _Env.kcBaseUrl;
  @EnviedField(varName: "KC_REALM")
  static final String kcRealm = _Env.kcRealm;
  @EnviedField(varName: "LOG_LEVEL")
  static final String logLevel = _Env.logLevel;
  @EnviedField(varName: "ROOT_DOMAIN")
  static final String rootDomain = _Env.rootDomain;
  @EnviedField(varName: "REDIRECT_URI_MOBILE")
  static final String redirectUriMobile = _Env.redirectUriMobile;
}
