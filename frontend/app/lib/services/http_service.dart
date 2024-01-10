import "dart:convert";

import "package:aw40_hub_frontend/services/services.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
import "package:http/http.dart" as http;

class HttpService {
  static final http.Client _client = http.Client();
  static final String backendUrl =
      ConfigService().getConfigValue(ConfigKey.backendUrl);
  static final String basicAuthKey =
      ConfigService().getConfigValue(ConfigKey.basicAuthKey);

  Future<http.Response> checkBackendHealth() {
    return http.get(
      Uri.parse("$backendUrl/health/ping"),
      headers: {"Authorization": "Basic $basicAuthKey=="},
    );
  }

  Future<http.Response> getSharedCases() {
    return http.get(
      Uri.parse("$backendUrl/shared/cases"),
      headers: {"Authorization": "Basic $basicAuthKey=="},
    );
  }

  Future<http.Response> getCases(String workshopId) {
    return http.get(
      Uri.parse("$backendUrl/$workshopId/cases"),
      headers: {"Authorization": "Basic $basicAuthKey=="},
    );
  }

  Future<http.Response> addCase(
    String workshopId,
    Map<String, dynamic> requestBody,
  ) {
    return _client.post(
      Uri.parse("$backendUrl/$workshopId/cases"),
      headers: {
        "Authorization": "Basic $basicAuthKey==",
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: jsonEncode(requestBody),
    );
  }

  Future<http.Response> updateCase(
    String workshopId,
    String caseId,
    Map<String, dynamic> requestBody,
  ) {
    return _client.put(
      Uri.parse("$backendUrl/$workshopId/cases/$caseId"),
      headers: {
        "Authorization": "Basic $basicAuthKey==",
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: jsonEncode(requestBody),
    );
  }

  Future<http.Response> deleteCase(String workshopId, String caseId) {
    return http.delete(
      Uri.parse("$backendUrl/$workshopId/cases/$caseId"),
      headers: {"Authorization": "Basic $basicAuthKey=="},
    );
  }

  Future<http.Response> getDiagnosis(String workshopId, String caseId) {
    return http.get(
      Uri.parse("$backendUrl/$workshopId/cases/$caseId/diag"),
      headers: {"Authorization": "Basic $basicAuthKey=="},
    );
  }

  Future<http.Response> startDiagnosis(String workshopId, String caseId) {
    return http.post(
      Uri.parse("$backendUrl/$workshopId/cases/$caseId/diag"),
      headers: {"Authorization": "Basic $basicAuthKey=="},
    );
  }

  Future<http.Response> deleteDiagnosis(String workshopId, String caseId) {
    return http.delete(
      Uri.parse("$backendUrl/$workshopId/cases/$caseId/diag"),
      headers: {"Authorization": "Basic $basicAuthKey=="},
    );
  }

  Future<http.Response> uploadObdData(
    String workshopId,
    String caseId,
    Map<String, dynamic> requestBody,
  ) {
    return http.post(
      Uri.parse("$backendUrl/$workshopId/cases/$caseId/obd_data"),
      headers: {
        "Authorization": "Basic $basicAuthKey==",
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: jsonEncode(requestBody),
    );
  }

  Future<http.Response> uploadPicoscopeData(
    String workshopId,
    String caseId,
    List<int> picoscopeData,
    String filename,
  ) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse(
        "$backendUrl/$workshopId/cases/$caseId/timeseries_data/upload/picoscope",
      ),
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        "upload",
        picoscopeData,
        filename: filename,
      ),
    );

    request.fields["file_format"] = "Picoscope CSV";
    request.headers["Authorization"] = "Basic $basicAuthKey==";

    return http.Response.fromStream(await request.send());
  }

  Future<http.Response> uploadSymtomData(
    String workshopId,
    String caseId,
    Map<String, dynamic> requestBody,
  ) {
    return http.post(
      Uri.parse("$backendUrl/$workshopId/cases/$caseId/symptoms"),
      headers: {
        "Authorization": "Basic $basicAuthKey==",
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: jsonEncode(requestBody),
    );
  }
}
