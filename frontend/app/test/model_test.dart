import "package:aw40_hub_frontend/models/models.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("CaseModel", () {
    const id = "test_id";
    final timestamp = DateTime.now();
    const occasion = CaseOccasion.unknown;
    const milage = 100;
    const status = CaseStatus.closed;
    const customerId = "some_customer_id";
    const vehicleVin = "12345678901234567";
    const workshopId = "some_workshop_id";
    const diagnosisId = "some_diagnosis_id";
    final List<dynamic> timeseriesData = <dynamic>[1, 2, 3];
    final List<dynamic> obdData = <dynamic>["a", 5, false];
    final List<dynamic> symptoms = <dynamic>[true, false];

    final caseModel = CaseModel(
      id: id,
      timestamp: timestamp,
      occasion: occasion,
      milage: milage,
      status: status,
      customerId: customerId,
      vehicleVin: vehicleVin,
      workshopId: workshopId,
      diagnosisId: diagnosisId,
      timeseriesData: timeseriesData,
      obdData: obdData,
      symptoms: symptoms,
    );
    test("correctly assigns id", () {
      expect(caseModel.id, id);
    });
    test("correctly assigns timestamp", () {
      expect(caseModel.timestamp, timestamp);
    });
    test("correctly assigns occasion", () {
      expect(caseModel.occasion, occasion);
    });
    test("correctly assigns milage", () {
      expect(caseModel.milage, milage);
    });
    test("correctly assigns status", () {
      expect(caseModel.status, status);
    });
    test("correctly assigns customerId", () {
      expect(caseModel.customerId, customerId);
    });
    test("correctly assigns vehicleVin", () {
      expect(caseModel.vehicleVin, vehicleVin);
    });
    test("correctly assigns workshopId", () {
      expect(caseModel.workshopId, workshopId);
    });
    test("correctly assigns diagnosisId", () {
      expect(caseModel.diagnosisId, diagnosisId);
    });
    test("correctly assigns timeseriesData", () {
      expect(caseModel.timeseriesData, timeseriesData);
    });
    test("correctly assigns obdData", () {
      expect(caseModel.obdData, obdData);
    });
    test("correctly assigns symptoms", () {
      expect(caseModel.symptoms, symptoms);
    });
  });
  group("DiagnosisModel", () {
    const id = "test_id";
    final timestamp = DateTime.now();
    const status = DiagnosisStatus.processing;
    const caseId = "some_case_id";
    final stateMachineLog = <dynamic>[1, 2, 3];
    final todos = <ActionModel>[
      ActionModel(
        id: "1",
        instruction: "some action",
        actionType: "1",
        dataType: "2",
        component: "3",
      ),
    ];

    final diagnosisModel = DiagnosisModel(
      id: id,
      timestamp: timestamp,
      status: status,
      caseId: caseId,
      stateMachineLog: stateMachineLog,
      todos: todos,
    );
    test("correctly assigns id", () {
      expect(diagnosisModel.id, id);
    });
    test("correctly assigns timestamp", () {
      expect(diagnosisModel.timestamp, timestamp);
    });
    test("correctly assigns status", () {
      expect(diagnosisModel.status, status);
    });
    test("correctly assigns caseId", () {
      expect(diagnosisModel.caseId, caseId);
    });
    test("correctly assigns stateMachineLog", () {
      expect(diagnosisModel.stateMachineLog, stateMachineLog);
    });
    test("correctly assigns todos", () {
      expect(diagnosisModel.todos, todos);
    });
  });
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
  group("LoggedInUserModel", () {
    const groups = <AuthorizedGroup>[
      AuthorizedGroup.Analysts,
      AuthorizedGroup.Mechanics,
    ];
    const fullName = "John Doe";
    const userName = "jdoe";
    const mailAddress = "a@b.c";
    const workShopId = "some_workshop_id";

    final loggedInUserModel = LoggedInUserModel(
      groups,
      fullName,
      userName,
      mailAddress,
      workShopId,
    );

    test("correctly assigns groups", () {
      expect(loggedInUserModel.groups, groups);
    });
    test("correctly assigns fullName", () {
      expect(loggedInUserModel.fullName, fullName);
    });
    test("correctly assigns userName", () {
      expect(loggedInUserModel.userName, userName);
    });
    test("correctly assigns mailAddress", () {
      expect(loggedInUserModel.mailAddress, mailAddress);
    });
    test("correctly assigns workShopId", () {
      expect(loggedInUserModel.workShopId, workShopId);
    });
  });
  group("NavigationItemModel", () {
    const title = "Test Title";
    const icon = Icon(Icons.add);
    const destination = "some_destination";
    const navigationType = NavigationType.external;
    const actions = <Widget>[Text("le Test Text")];

    const navigationItemModel = NavigationMenuItemModel(
      title: title,
      icon: icon,
      destination: destination,
      navigationType: navigationType,
      actions: actions,
    );

    test("correctly assigns title", () {
      expect(navigationItemModel.title, title);
    });
    test("correctly assigns icon", () {
      expect(navigationItemModel.icon, icon);
    });
    test("correctly assigns destination", () {
      expect(navigationItemModel.destination, destination);
    });
    test("correctly assigns navigationType", () {
      expect(navigationItemModel.navigationType, navigationType);
    });
    test("correctly assigns actions", () {
      expect(navigationItemModel.actions, actions);
    });
    test("correctly assigns isExternal", () {
      expect(navigationItemModel.isExternal, true);
    });
  });
  group("ActionModel", () {
    const String id = "some_id";
    const String instruction = "some_customer_id";
    const String actionType = "some_action_type";
    const String dataType = "some_data_type";
    const String component = "some_component";

    final actionModel = ActionModel(
      id: id,
      instruction: instruction,
      actionType: actionType,
      dataType: dataType,
      component: component,
    );

    test("correctly assigns id", () {
      expect(actionModel.id, id);
    });
    test("correctly assigns instruction", () {
      expect(actionModel.instruction, instruction);
    });
    test("correctly assigns actionType", () {
      expect(actionModel.actionType, actionType);
    });
    test("correctly assigns dataType", () {
      expect(actionModel.dataType, dataType);
    });
    test("correctly assigns component", () {
      expect(actionModel.component, component);
    });
  });
}
