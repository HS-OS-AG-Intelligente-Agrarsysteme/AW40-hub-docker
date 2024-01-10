// ignore_for_file: avoid_dynamic_calls

import "package:aw40_hub_frontend/services/services.dart";
import "package:aw40_hub_frontend/utils/utils.dart";

class JwtModel {
  JwtModel({
    required this.jwt,
    required this.exp,
    required this.roles,
    this.iat,
    this.authTime,
    this.jti,
    this.iss,
    this.typ,
    this.azp,
    this.sessionState,
    this.acr,
    this.scope,
    this.emailVerified,
    this.name,
    this.preferredUsername,
    this.givenName,
    this.familyName,
    this.email,
    this.locale,
  });

  factory JwtModel.fromJwtString(String jwt) {
    DateTime exp;
    List<String> roles;
    dynamic jsonData;
    jsonData = TokenService().decodeBodyFromJWT(jwt);
    exp = DateTime.fromMillisecondsSinceEpoch(jsonData["exp"] * 1000 as int);
    final String kcClient = ConfigService().getConfigValue(ConfigKey.kcClient);
    roles = jsonData["resource_access"]?[kcClient]?["roles"].cast<String>()
            as List<String>? ??
        [];
    return JwtModel(
      jwt: jwt,
      exp: exp,
      roles: roles,
      iat: jsonData != null
          ? DateTime.fromMillisecondsSinceEpoch(jsonData["iat"] * 1000 as int)
          : null,
      authTime: jsonData != null
          ? DateTime.fromMillisecondsSinceEpoch(
              jsonData["auth_time"] * 1000 as int,
            )
          : null,
      jti: jsonData?["jti"] as String?,
      iss: jsonData?["iss"] as String?,
      typ: jsonData?["typ"] as String?,
      azp: jsonData?["azp"] as String?,
      sessionState: jsonData?["session_state"] as String?,
      acr: jsonData?["acr"] as String?,
      scope: jsonData?["scope"] as String?,
      emailVerified: jsonData?["email_verified"] as bool?,
      name: jsonData?["name"] as String?,
      preferredUsername: jsonData?["preferred_username"] as String?,
      givenName: jsonData?["given_name"] as String?,
      familyName: jsonData?["family_name"] as String?,
      email: jsonData?["email"] as String?,
      locale: jsonData?["locale"] as String?,
    );
  }
  String jwt;
  DateTime exp;
  List<String> roles;
  DateTime? iat;
  DateTime? authTime;
  String? jti;
  String? iss;
  String? typ;
  String? azp;
  String? sessionState;
  String? acr;
  String? scope;
  bool? emailVerified;
  String? name;
  String? preferredUsername;
  String? givenName;
  String? familyName;
  String? email;
  String? locale;
}
