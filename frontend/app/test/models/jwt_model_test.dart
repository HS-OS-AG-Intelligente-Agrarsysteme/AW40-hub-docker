import "package:aw40_hub_frontend/models/jwt_model.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("JwtModel", () {
    group("JwtModel primary constructor", () {
      const jwt = "some_jwt_string";
      final exp = DateTime.now();
      const groups = <String>["some_group"];
      final iat = DateTime.now();
      final authTime = DateTime.now();
      const jti = "some_jti";
      const iss = "some_iss";
      const typ = "some_typ";
      const azp = "some_azp";
      const sessionState = "some_session_state";
      const acr = "some_acr";
      const scope = "some_scope";
      const emailVerified = true;
      const name = "some_name";
      const preferredUsername = "some_preferred_username";
      const givenName = "some_given_name";
      const familyName = "some_family_name";
      const email = "some_email";
      const locale = "some_locale";

      final jwtModel = JwtModel(
        jwt: jwt,
        exp: exp,
        groups: groups,
        iat: iat,
        authTime: authTime,
        jti: jti,
        iss: iss,
        typ: typ,
        azp: azp,
        sessionState: sessionState,
        acr: acr,
        scope: scope,
        emailVerified: emailVerified,
        name: name,
        preferredUsername: preferredUsername,
        givenName: givenName,
        familyName: familyName,
        email: email,
        locale: locale,
      );
      test("correctly assigns jwt", () {
        expect(jwtModel.jwt, jwt);
      });
      test("correctly assigns exp", () {
        expect(jwtModel.exp, exp);
      });
      test("correctly assigns groups", () {
        expect(jwtModel.groups, groups);
      });
      test("correctly assigns iat", () {
        expect(jwtModel.iat, iat);
      });
      test("correctly assigns authTime", () {
        expect(jwtModel.authTime, authTime);
      });
      test("correctly assigns jti", () {
        expect(jwtModel.jti, jti);
      });
      test("correctly assigns iss", () {
        expect(jwtModel.iss, iss);
      });
      test("correctly assigns typ", () {
        expect(jwtModel.typ, typ);
      });
      test("correctly assigns azp", () {
        expect(jwtModel.azp, azp);
      });
      test("correctly assigns sessionState", () {
        expect(jwtModel.sessionState, sessionState);
      });
      test("correctly assigns acr", () {
        expect(jwtModel.acr, acr);
      });
      test("correctly assigns scope", () {
        expect(jwtModel.scope, scope);
      });
      test("correctly assigns emailVerified", () {
        expect(jwtModel.emailVerified, emailVerified);
      });
      test("correctly assigns name", () {
        expect(jwtModel.name, name);
      });
      test("correctly assigns preferredUsername", () {
        expect(jwtModel.preferredUsername, preferredUsername);
      });
      test("correctly assigns givenName", () {
        expect(jwtModel.givenName, givenName);
      });
      test("correctly assigns familyName", () {
        expect(jwtModel.familyName, familyName);
      });
      test("correctly assigns email", () {
        expect(jwtModel.email, email);
      });
      test("correctly assigns locale", () {
        expect(jwtModel.locale, locale);
      });
    });
    group("JwtModel.fromJwtstring", () {
      const jwtString =
          // ignore: lines_longer_than_80_chars
          "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJwSHYydWwxMjRBem9SeEJrTVhJOWc4bV94ZnQ2TVNzNUlGX0N0NjNXckZzIn0.eyJleHAiOjE3MTAyNTE4MzMsImlhdCI6MTcxMDI1MTUzMywiYXV0aF90aW1lIjoxNzEwMjUxNTMzLCJqdGkiOiIyZGRkOTA3Ny03MjFkLTQ2MTctOTM5NC01MTE5NWY1NGIyZDkiLCJpc3MiOiJodHRwOi8va2V5Y2xvYWsud2Vya3N0YXR0aHViLmRvY2tlci5sb2NhbGhvc3QvcmVhbG1zL3dlcmtzdGF0dC1odWIiLCJhdWQiOiJhY2NvdW50Iiwic3ViIjoiY2JkYThhN2ItMzc3Mi00NjNlLWJiNjUtOGQxOTRlYWMwZTkyIiwidHlwIjoiQmVhcmVyIiwiYXpwIjoiYXc0MGh1Yi1mcm9udGVuZCIsInNlc3Npb25fc3RhdGUiOiJhMzEwNjEyOS00NmM0LTRmMDQtODYzYS0wZjlhYTYyZDg2MmUiLCJhY3IiOiIxIiwiYWxsb3dlZC1vcmlnaW5zIjpbIioiXSwicmVhbG1fYWNjZXNzIjp7InJvbGVzIjpbInNoYXJlZCIsIndvcmtzaG9wIiwib2ZmbGluZV9hY2Nlc3MiLCJkZWZhdWx0LXJvbGVzLXdlcmtzdGF0dC1odWIiLCJ1bWFfYXV0aG9yaXphdGlvbiJdfSwicmVzb3VyY2VfYWNjZXNzIjp7ImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoib3BlbmlkIGZyb250ZW5kLXNjb3BlIHByb2ZpbGUgZW1haWwiLCJzaWQiOiJhMzEwNjEyOS00NmM0LTRmMDQtODYzYS0wZjlhYTYyZDg2MmUiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImdyb3VwcyI6WyJBbmFseXN0cyJdLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJ3ZXJrc3RhdHQtYW5hbHlzdCJ9.wWyCgcD_FM2JLamBn6BVBsaMbU37bTGeJgYH9mxsTffLTroHq_juSRwCFLm9Nn0Bj_4ymioocfFu1OSYb6Fu8X0raYbt25Igj0e8vtMHQ5kqQLptAL-_wOxMMsy7QeCfT9dXkXKBZPAmYvpnlWMEWxYct1T8Wv6JT2utESJpT8f-GNF3Opux7DJel4EDE3pnQ41Y1CKEl2DSs87Uppl3mPmm8nF5sG9ky2Nx-Ae23d3ae5iFA2nx6cNlrQmisg159IKu0QPr99O7lD8SP1VeqXaHYtEi1TdgctuZ6MoF86KyCVsM7ZfN9xfqSbRFF9EloTORt1RnSDyPGlIMPmx_9A==";
      const List<String> groups = ["Analysts"];
      const String jti = "2ddd9077-721d-4617-9394-51195f54b2d9";
      const String iss =
          "http://keycloak.werkstatthub.docker.localhost/realms/werkstatt-hub";
      const String typ = "Bearer";
      const String azp = "aw40hub-frontend";
      const String sessionState = "a3106129-46c4-4f04-863a-0f9aa62d862e";
      const String acr = "1";
      const String scope = "openid frontend-scope profile email";
      const bool emailVerified = false;
      const String preferredUsername = "werkstatt-analyst";
      // TODO: Add remaining test cases for fields:
      // name, givenName, familyName, email, locale
      // exp, iat, authTime

      final JwtModel jwtModel = JwtModel.fromJwtString(jwtString);
      test("correctly assigns jwt", () {
        expect(jwtModel.jwt, jwtString);
      });
      test("correctly assigns groups", () {
        expect(jwtModel.groups, groups);
      });
      test("correctly assigns jti", () {
        expect(jwtModel.jti, jti);
      });
      test("correctly assigns iss", () {
        expect(jwtModel.iss, iss);
      });
      test("correctly assigns typ", () {
        expect(jwtModel.typ, typ);
      });
      test("correctly assigns azp", () {
        expect(jwtModel.azp, azp);
      });
      test("correctly assigns sessionState", () {
        expect(jwtModel.sessionState, sessionState);
      });
      test("correctly assigns acr", () {
        expect(jwtModel.acr, acr);
      });
      test("correctly assigns scope", () {
        expect(jwtModel.scope, scope);
      });
      test("correctly assigns emailVerified", () {
        expect(jwtModel.emailVerified, emailVerified);
      });
      test("correctly assigns preferredUserName", () {
        expect(jwtModel.preferredUsername, preferredUsername);
      });
    });
  });
}
