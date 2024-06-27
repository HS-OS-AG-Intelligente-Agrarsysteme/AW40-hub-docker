import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/services/services.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:collection/collection.dart";
import "package:enum_to_string/enum_to_string.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";
import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:logging/logging.dart";

void main() {
  //do not print to console
  debugPrint = (String? message, {int? wrapWidth}) {};
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
      test("has no url unsafe characters", () async {
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
  group("HttpService", () {
    setUp(() async {
      await ConfigService().initialize();
    });
    group("_getAuthHeaderWith", () {
      test("returns only auth header if `otherHeaders` is null", () {
        const String token = "some-token";
        final Map<String, String> expected = {
          "Authorization": "Bearer some-token==",
        };
        final Map<String, String> actual =
            HttpService(http.Client()).getAuthHeaderWith(token);
        expect(actual, expected);
      });
      test("returns map of all headers if `otherHeaders` is not null", () {
        const String token = "some-token";
        const Map<String, String> otherHeaders = {"another": "header"};
        final Map<String, String> expected = {
          "Authorization": "Bearer some-token==",
          "another": "header",
        };
        final Map<String, String> actual =
            HttpService(http.Client()).getAuthHeaderWith(token, otherHeaders);
        expect(actual, expected);
      });
    });
    test("verify checkBackendHealth request", () async {
      bool sentRequest = false;
      final client = MockClient((request) async {
        sentRequest = true;
        expect(
          request.method,
          equals("GET"),
          reason: "Request method is not GET",
        );
        expect(
          request.headers["content-type"],
          isNull,
          reason: "Request has content-type header",
        );
        expect(request.body, isEmpty, reason: "Request body is not empty");
        expect(
          request.url.toString(),
          endsWith("/health/ping"),
          reason: "Request URL does not end with /health/ping",
        );
        return http.Response('{"status": "success"}', 200);
      });
      await HttpService(client).checkBackendHealth();
      expect(sentRequest, isTrue, reason: "Request was not sent");
    });
    test("verify getSharedCases", () async {
      bool sentRequest = false;
      final client = MockClient((request) async {
        sentRequest = true;
        expect(
          request.method,
          equals("GET"),
          reason: "Request method is not GET",
        );
        expect(
          request.headers["content-type"],
          isNull,
          reason: "Request has content-type header",
        );
        expect(request.body, isEmpty, reason: "Request body is not empty");
        expect(
          request.url.toString(),
          endsWith("/shared/cases"),
          reason: "Request URL does not end with /shared/cases",
        );
        return http.Response('{"status": "success"}', 200);
      });
      await HttpService(client).getSharedCases("some-token");
      expect(sentRequest, isTrue, reason: "Request was not sent");
    });
    test("verify getCases", () async {
      const workshopId = "some-workshop-id";
      bool sentRequest = false;
      final client = MockClient((request) async {
        sentRequest = true;
        expect(
          request.method,
          equals("GET"),
          reason: "Request method is not GET",
        );
        expect(
          request.headers["content-type"],
          isNull,
          reason: "Request has content-type header",
        );
        expect(request.body, isEmpty, reason: "Request body is not empty");
        expect(
          request.url.toString(),
          endsWith("/$workshopId/cases"),
          reason: "Request URL does not end with /{workshopId}/cases",
        );
        return http.Response('{"status": "success"}', 200);
      });
      await HttpService(client).getCases("some-token", workshopId);
      expect(sentRequest, isTrue, reason: "Request was not sent");
    });
    test("verify addCase", () async {
      const workshopId = "some-workshop-id";
      const requestBody = {"key": "value"};
      bool sentRequest = false;
      final client = MockClient((request) async {
        sentRequest = true;
        expect(
          request.method,
          equals("POST"),
          reason: "Request method is not POST",
        );
        expect(
          request.headers["content-type"],
          equals("application/json; charset=UTF-8"),
          reason: "Request has wrong content-type header",
        );
        expect(
          request.body,
          equals('{"${requestBody.keys.first}":"${requestBody.values.first}"}'),
          reason: "Request body is not correct",
        );
        expect(
          request.url.toString(),
          endsWith("/$workshopId/cases"),
          reason: "Request URL does not end with /{workshopId}/cases",
        );
        return http.Response('{"status": "success"}', 200);
      });
      await HttpService(client).addCase("token", workshopId, requestBody);
      expect(sentRequest, isTrue, reason: "Request was not sent");
    });
    test("verify updateCase", () async {
      const workshopId = "some-workshop-id";
      const caseId = "some-case-id";
      const requestBody = {"key": "value"};
      bool sentRequest = false;
      final client = MockClient((request) async {
        sentRequest = true;
        expect(
          request.method,
          equals("PUT"),
          reason: "Request method is not PUT",
        );
        expect(
          request.headers["content-type"],
          equals("application/json; charset=UTF-8"),
          reason: "Request has wrong content-type header",
        );
        expect(
          request.body,
          equals('{"${requestBody.keys.first}":"${requestBody.values.first}"}'),
          reason: "Request body is not correct",
        );
        expect(
          request.url.toString(),
          endsWith("/$workshopId/cases/$caseId"),
          reason: "Request URL does not end with /{workshopId}/cases/{caseId}",
        );
        return http.Response('{"status": "success"}', 200);
      });
      await HttpService(client).updateCase(
        "token",
        workshopId,
        caseId,
        requestBody,
      );
      expect(sentRequest, isTrue, reason: "Request was not sent");
    });
    test("verify deleteCase", () async {
      const workshopId = "some-workshop-id";
      const caseId = "some-case-id";
      bool sentRequest = false;
      final client = MockClient((request) async {
        sentRequest = true;
        expect(
          request.method,
          equals("DELETE"),
          reason: "Request method is not DELETE",
        );
        expect(
          request.headers["content-type"],
          isNull,
          reason: "Request has content-type header",
        );
        expect(request.body, isEmpty, reason: "Request body is not empty");
        expect(
          request.url.toString(),
          endsWith("/$workshopId/cases/$caseId"),
          reason: "Request URL does not end with /{workshopId}/cases/{caseId}",
        );
        return http.Response('{"status": "success"}', 200);
      });
      await HttpService(client).deleteCase("token", workshopId, caseId);
      expect(sentRequest, isTrue, reason: "Request was not sent");
    });
    test("verify getDiagnoses", () async {
      const workshopId = "some-workshop-id";
      bool sentRequest = false;
      final client = MockClient((http.Request request) async {
        sentRequest = true;
        expect(
          request.method,
          equals("GET"),
          reason: "Request method should be GET",
        );
        expect(
          request.headers["content-type"],
          isNull,
          reason: "Request should not have content-type header",
        );
        expect(request.body, isEmpty, reason: "Request body  empty");
        expect(
          request.url.toString(),
          endsWith("/$workshopId/diagnoses"),
          reason: "Request URL should end with /{workshopId}/diagnoses",
        );
        return http.Response('{"status": "success"}', 200);
      });
      await HttpService(client).getDiagnoses("token", workshopId);
      expect(sentRequest, isTrue, reason: "Request was not sent");
    });
    test("verify getDiagnosis", () async {
      const workshopId = "some-workshop-id";
      const caseId = "some-case-id";
      bool sentRequest = false;
      final client = MockClient((request) async {
        sentRequest = true;
        expect(
          request.method,
          equals("GET"),
          reason: "Request method is not GET",
        );
        expect(
          request.headers["content-type"],
          isNull,
          reason: "Request has content-type header",
        );
        expect(request.body, isEmpty, reason: "Request body is not empty");
        expect(
          request.url.toString(),
          endsWith("/$workshopId/cases/$caseId/diag"),
          reason:
              "Request URL does not end with /{workshopId}/cases/{caseId}/diag",
        );
        return http.Response('{"status": "success"}', 200);
      });
      await HttpService(client).getDiagnosis("token", workshopId, caseId);
      expect(sentRequest, isTrue, reason: "Request was not sent");
    });
    test("verify startDiagnosis", () async {
      const workshopId = "some-workshop-id";
      const caseId = "some-case-id";
      bool sentRequest = false;
      final client = MockClient((request) async {
        sentRequest = true;
        expect(
          request.method,
          equals("POST"),
          reason: "Request method is not POST",
        );
        expect(
          request.headers["content-type"],
          isNull,
          reason: "Request has content-type header",
        );
        expect(request.body, isEmpty, reason: "Request body is not empty");
        expect(
          request.url.toString(),
          endsWith("/$workshopId/cases/$caseId/diag"),
          reason:
              "Request URL does not end with /{workshopId}/cases/{caseId}/diag",
        );
        return http.Response('{"status": "success"}', 200);
      });
      await HttpService(client).startDiagnosis("token", workshopId, caseId);
      expect(sentRequest, isTrue, reason: "Request was not sent");
    });
    test("verify deleteDiagnosis", () async {
      const workshopId = "some-workshop-id";
      const caseId = "some-case-id";
      bool sentRequest = false;
      final client = MockClient((request) async {
        sentRequest = true;
        expect(
          request.method,
          equals("DELETE"),
          reason: "Request method is not DELETE",
        );
        expect(
          request.headers["content-type"],
          isNull,
          reason: "Request has content-type header",
        );
        expect(request.body, isEmpty, reason: "Request body is not empty");
        expect(
          request.url.toString(),
          endsWith("/$workshopId/cases/$caseId/diag"),
          reason:
              "Request URL does not end with /{workshopId}/cases/{caseId}/diag",
        );
        return http.Response('{"status": "success"}', 200);
      });
      await HttpService(client).deleteDiagnosis("token", workshopId, caseId);
      expect(sentRequest, isTrue, reason: "Request was not sent");
    });
    test("verify uploadObdData", () async {
      const workshopId = "some-workshop-id";
      const caseId = "some-case-id";
      const requestBody = {"key": "value"};
      bool sentRequest = false;
      final client = MockClient((request) async {
        sentRequest = true;
        expect(
          request.method,
          equals("POST"),
          reason: "Request method is not POST",
        );
        expect(
          request.headers["content-type"],
          equals("application/json; charset=UTF-8"),
          reason: "Request has wrong content-type header",
        );
        expect(
          request.body,
          equals('{"${requestBody.keys.first}":"${requestBody.values.first}"}'),
          reason: "Request body is not correct",
        );
        expect(
          request.url.toString(),
          endsWith("/$workshopId/cases/$caseId/obd_data"),
          reason:
              "Request URL does not end with /{workshopId}/cases/{caseId}/obd_data",
        );
        return http.Response('{"status": "success"}', 200);
      });
      await HttpService(client).uploadObdData(
        "token",
        workshopId,
        caseId,
        requestBody,
      );
      expect(sentRequest, isTrue, reason: "Request was not sent");
    });
    test("verify uploadPicoscopeData", () async {
      const workshopId = "some-workshop-id";
      const caseId = "some-case-id";
      const picoscopeData = [1, 2, 3];
      const filename = "some-filename";
      const componentA = "inueh";
      const labelA = PicoscopeLabel.anomaly;
      const componentC = "ragonu";
      const labelC = PicoscopeLabel.norm;
      bool sentRequest = false;
      final client = MockClient((http.Request request) async {
        sentRequest = true;
        expect(
          request.method,
          equals("POST"),
          reason: "Request method is not POST",
        );
        expect(
          request.headers["content-type"],
          startsWith("multipart/form-data"),
          reason: "Request has wrong content-type header",
        );
        final body = request.body;
        expect(body, contains('name="component_A"'));
        expect(body, contains(componentA));
        expect(body, contains('name="label_A"'));
        expect(body, contains(EnumToString.convertToString(labelA)));
        expect(body, contains('name="component_C"'));
        expect(body, contains(componentC));
        expect(body, contains('name="label_C"'));
        expect(body, contains(EnumToString.convertToString(labelC)));
        expect(body, contains('name="upload"'));
        expect(body, isNot(contains('name="component_B"')));
        expect(body, isNot(contains('name="label_B"')));
        expect(body, isNot(contains('name="component_D"')));
        expect(body, isNot(contains('name="label_D"')));
        expect(
          request.url.toString(),
          endsWith(
            "/$workshopId/cases/$caseId/timeseries_data/upload/picoscope",
          ),
          reason:
              "Request URL does not end with /{workshopId}/cases/{caseId}/timeseries_data/upload/picoscope",
        );
        return http.Response('{"status": "success"}', 200);
      });
      await HttpService(client).uploadPicoscopeData(
        "token",
        workshopId,
        caseId,
        picoscopeData,
        filename,
        componentA: componentA,
        labelA: labelA,
        componentC: componentC,
        labelC: labelC,
      );
      expect(sentRequest, isTrue, reason: "Request was not sent");
    });
    test("verify uploadSymptomData", () async {
      const workshopId = "some-workshop-id";
      const caseId = "some-case-id";
      const requestBody = {"key": "value"};
      bool sentRequest = false;
      final client = MockClient((request) async {
        sentRequest = true;
        expect(
          request.method,
          equals("POST"),
          reason: "Request method is not POST",
        );
        expect(
          request.headers["content-type"],
          equals("application/json; charset=UTF-8"),
          reason: "Request has wrong content-type header",
        );
        expect(
          request.body,
          equals('{"${requestBody.keys.first}":"${requestBody.values.first}"}'),
          reason: "Request body is not correct",
        );
        expect(
          request.url.toString(),
          endsWith("/$workshopId/cases/$caseId/symptoms"),
          reason:
              "Request URL does not end with /{workshopId}/cases/{caseId}/symptoms",
        );
        return http.Response('{"status": "success"}', 200);
      });
      await HttpService(client).uploadSymptomData(
        "token",
        workshopId,
        caseId,
        requestBody,
      );
      expect(sentRequest, isTrue, reason: "Request was not sent");
    });
    test("verify uploadOmniviewData", () async {
      const workshopId = "some-workshop-id";
      const caseId = "some-case-id";
      const component = "some-random";
      const samplingRate = 1000;
      const duration = 20000;
      const omniviewData = [1, 2, 3];
      const filename = "some-filename";
      bool sentRequest = false;
      final client = MockClient((request) async {
        sentRequest = true;
        expect(
          request.method,
          equals("POST"),
          reason: "Request method is not POST",
        );
        expect(
          request.headers["content-type"],
          startsWith("multipart/form-data"),
          reason: "Request has wrong content-type header",
        );
        final body = request.body;
        expect(body, contains('name="component"'));
        expect(body, contains(component));
        expect(body, contains('name="sampling_rate"'));
        expect(body, contains(samplingRate.toString()));
        expect(body, contains('name="duration"'));
        expect(body, contains(duration.toString()));
        expect(
          request.url.toString(),
          endsWith(
            "/$workshopId/cases/$caseId/timeseries_data/upload/omniview",
          ),
          reason:
              "Request URL does not end with /{workshopId}/cases/{caseId}/timeseries_data/upload/omniview",
        );
        return http.Response('{"status": "success"}', 200);
      });
      await HttpService(client).uploadOmniviewData(
        "token",
        workshopId,
        caseId,
        component,
        samplingRate,
        duration,
        omniviewData,
        filename,
      );
      expect(sentRequest, isTrue, reason: "Request was not sent");
    });
  });
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
  group("ConfigService", () {
    final ConfigService configService = ConfigService();
    setUp(configService.reset);
    test("should be Singleton", () {
      final ConfigService configService1 = ConfigService();
      final ConfigService configService2 = ConfigService();
      expect(identical(configService1, configService2), true);
    });
    test("logValues() logs once for each ConfigKey", () async {
      final Logger testLogger = Logger("test_logger");
      final logRecords = <LogRecord>[];
      testLogger.onRecord.listen(logRecords.add);
      configService.logValues();
      expect(logRecords.length, ConfigKey.values.length);
    });
    test("logValues() logs in order of ConfigKeys", () async {
      final Logger testLogger = Logger("test_logger");
      final logRecords = <LogRecord>[];
      testLogger.onRecord.listen(logRecords.add);
      configService.logValues();
      ConfigKey.values.forEachIndexed((i, k) {
        expect(
          logRecords[i].message,
          contains(k.name),
          reason: "${i}th key should contain ${k.name},"
              " but was '${logRecords[i].message}'",
        );
      });
    });
    test("_configMap is empty before calling initialize()", () {
      final Logger testLogger = Logger("test_logger");
      final logRecords = <LogRecord>[];
      testLogger.onRecord.listen(logRecords.add);

      configService.logValues();

      ConfigKey.values.forEachIndexed((i, k) {
        expect(
          logRecords[i].message,
          contains("not found"),
          reason: "key $k should not be in _configMap, but was found",
        );
      });
    });
    test("_configMap is populated after calling initialize()", () async {
      final Logger testLogger = Logger("test_logger");
      final logRecords = <LogRecord>[];
      testLogger.onRecord.listen(logRecords.add);

      await configService.initialize();
      configService.logValues();

      ConfigKey.values.forEachIndexed((i, k) {
        expect(
          logRecords[i].message,
          isNot(contains("not found")),
          reason: "key $k should be in _configMap, but was not found",
        );
        expect(
          logRecords[i].message,
          isNot(contains("empty value")),
          reason: "key $k was in _configMap, but had empty value",
        );
      });
    });
    test("calling getConfigValue() before initialize() throws exception", () {
      expect(
        () => configService.getConfigValue(ConfigKey.apiAddress),
        throwsA(isA<AppException>()),
      );
    });
    test(
      "calling getConfigValue() after initialize() does not throw exception",
      () async {
        await configService.initialize();
        expect(
          () => configService.getConfigValue(ConfigKey.apiAddress),
          returnsNormally,
        );
      },
    );
    test("getConfigValue() should not return empty strings", () async {
      await configService.initialize();
      for (final configKey in ConfigKey.values) {
        final String value = configService.getConfigValue(configKey);
        expect(
          value,
          isNotEmpty,
          reason: "key $configKey should not have empty value",
        );
      }
    });
  });
}
