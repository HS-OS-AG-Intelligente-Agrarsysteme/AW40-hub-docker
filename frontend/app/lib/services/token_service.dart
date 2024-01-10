import "dart:convert";

import "package:aw40_hub_frontend/utils/utils.dart";

class TokenService {
  Map<String, dynamic> decodeBodyFromJWT(String jwt) {
    return json.decode(
      utf8.decode(base64.decode(base64.normalize(jwt.split(".")[1]))),
    ) as Map<String, dynamic>;
  }

  Map<TokenType, String> readRefreshAndJWTFromKeyCloakMap(
    Map<String, dynamic> map,
  ) {
    final Map<TokenType, String> retMap = <TokenType, String>{};
    retMap[TokenType.jwt] = map["access_token"] as String;
    retMap[TokenType.refresh] = map["refresh_token"] as String;
    retMap[TokenType.id] = map["id_token"] as String;
    return retMap;
  }
}
