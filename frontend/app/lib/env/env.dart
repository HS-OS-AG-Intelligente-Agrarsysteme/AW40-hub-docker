// ignore_for_file: prefer_const_declarations

import "package:envied/envied.dart";
import "package:flutter/foundation.dart";

part "env.g.dart";

@Envied(
  path: kDebugMode ? "../../dev.env" : null,
  obfuscate: !kDebugMode,
)
abstract class Env {
  @EnviedField(varName: "API_ADDRESS")
  static final String apiAddress = _Env.apiAddress;

  @EnviedField(varName: "FRONTEND_ADDRESS")
  static final String frontendAddress = _Env.frontendAddress;

  @EnviedField(varName: "KEYCLOAK_ADDRESS")
  static final String keyCloakAddress = _Env.keyCloakAddress;

  @EnviedField(varName: "KEYCLOAK_FRONTEND_CLIENT")
  static final String keyCloakClient = _Env.keyCloakClient;

  @EnviedField(varName: "KEYCLOAK_REALM")
  static final String keyCloakRealm = _Env.keyCloakRealm;

  @EnviedField(varName: "FRONTEND_LOG_LEVEL")
  static final String logLevel = _Env.logLevel;

  @EnviedField(varName: "FRONTEND_REDIRECT_URI_MOBILE")
  static final String redirectUriMobile = _Env.redirectUriMobile;

  @EnviedField(varName: "PROXY_DEFAULT_SCHEME")
  static final String proxyDefaultScheme = _Env.proxyDefaultScheme;
}
