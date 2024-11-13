import "package:aw40_hub_frontend/services/config_service.dart";
import "package:aw40_hub_frontend/services/http_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:enum_to_string/enum_to_string.dart";
import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:http/testing.dart";

void main() {
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
    test("verify getCasesByVehicleVin", () async {
      const workshopId = "some-workshop-id";
      const vehicleVin = "some-vehicle-vin";
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
          reason: "Request should not have content-type header",
        );
        expect(
          request.url.toString(),
          endsWith("/$workshopId/cases?vin=some-vehicle-vin"),
          reason:
              "Request URL does not end with /{workshopId}/cases?vin=vehicleVin",
        );
        return http.Response('{"status": "success"}', 200);
      });
      await HttpService(client).getCasesByVehicleVin(
        "some-token",
        workshopId,
        vehicleVin,
      );
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

    test("verify addTimeseriesData", () async {
      const workshopId = "some-workshop-id";
      const caseId = "some-case-id";
      const component = "some-random";
      const label = TimeseriesDataLabel.norm;
      const samplingRate = 1000;
      const duration = 20000;
      const signal = [1, 2, 3];
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
        expect(body, contains('name="label"'));
        expect(body, contains(EnumToString.convertToString(label)));
        expect(body, contains('name="sampling_rate"'));
        expect(body, contains(samplingRate.toString()));
        expect(body, contains('name="duration"'));
        expect(body, contains(duration.toString()));
        expect(
          request.url.toString(),
          endsWith(
            "/$workshopId/cases/$caseId/timeseries_data",
          ),
          reason:
              "Request URL does not end with /{workshopId}/cases/{caseId}/timeseries_data",
        );
        return http.Response('{"status": "success"}', 200);
      });
      await HttpService(client).addTimeseriesData(
        "token",
        workshopId,
        caseId,
        component,
        label,
        samplingRate,
        duration,
        signal,
      );
      expect(sentRequest, isTrue, reason: "Request was not sent");
    });

    test("verify uploadSymptomData", () async {
      const workshopId = "some-workshop-id";
      const caseId = "some-case-id";
      const component = "component";
      const label = SymptomLabel.ok;
      //const requestBody = {"key": "value"};
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
        /*expect( // TODO remove?
          request.body,
          equals('{"${requestBody.keys.first}":"${requestBody.values.first}"}'),
          reason: "Request body is not correct",
        );*/
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
        component,
        label,
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
  test("verify getSharedCustomers", () async {
    bool sentRequest = false;

    final client = MockClient((request) async {
      sentRequest = true;
      expect(
        request.method,
        equals("GET"),
        reason: "Request method should be GET",
      );
      expect(
        request.headers["content-type"],
        isNull,
        reason: "Request has content-type header",
      );
      expect(request.body, isEmpty, reason: "Request body should be empty");
      expect(
        request.url.toString(),
        endsWith("/shared/customers"),
        reason: "Request URL should end with /shared/customers",
      );
      return http.Response('{"status": "success"}', 200);
    });
    await HttpService(client).getSharedCustomers(
      "some-token",
    );
    expect(sentRequest, isTrue, reason: "Request should have been sent");
  });
  test("verify getSharedVehicles", () async {
    bool sentRequest = false;
    final client = MockClient((request) async {
      sentRequest = true;
      expect(
        request.method,
        equals("GET"),
        reason: "Request method should be GET",
      );
      expect(
        request.headers["content-type"],
        isNull,
        reason: "Request has content-type header",
      );
      expect(request.body, isEmpty, reason: "Request body should be empty");
      expect(
        request.url.toString(),
        endsWith("/shared/vehicles"),
        reason: "Request URL should end with /shared/vehicles",
      );
      return http.Response('{"status": "success"}', 200);
    });
    await HttpService(client).getSharedVehicles("some-token");
    expect(sentRequest, isTrue, reason: "Request should have been sent");
  });
}
