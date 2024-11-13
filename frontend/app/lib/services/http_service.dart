import "dart:convert";

import "package:aw40_hub_frontend/dtos/new_symptom_dto.dart";
import "package:aw40_hub_frontend/services/config_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:collection/collection.dart";
import "package:enum_to_string/enum_to_string.dart";
import "package:http/http.dart" as http;

class HttpService {
  HttpService(this._client);

  final http.Client _client;

  static final String backendUrl =
      "${ConfigService().getConfigValue(ConfigKey.proxyDefaultScheme)}"
      "://"
      "${ConfigService().getConfigValue(ConfigKey.apiAddress)}"
      "/v1";

  Map<String, String> getAuthHeaderWith(
    String token, [
    Map<String, String>? otherHeaders,
  ]) {
    final authHeader = {"Authorization": "Bearer $token=="};
    return otherHeaders == null
        ? authHeader
        : mergeMaps(authHeader, otherHeaders);
  }

  Future<http.Response> checkBackendHealth() {
    return _client.get(Uri.parse("$backendUrl/health/ping"));
  }

  Future<http.Response> getSharedCases(String token) {
    return _client.get(
      Uri.parse("$backendUrl/shared/cases"),
      headers: getAuthHeaderWith(token),
    );
  }

  Future<http.Response> getCases(String token, String workshopId) {
    return _client.get(
      Uri.parse("$backendUrl/$workshopId/cases"),
      headers: getAuthHeaderWith(token),
    );
  }

  Future<http.Response> getCasesByVehicleVin(
    String token,
    String workshopId,
    String vehicleVin,
  ) {
    final uri = Uri.parse("$backendUrl/$workshopId/cases").replace(
      queryParameters: {
        "vin": vehicleVin,
      },
    );

    return _client.get(
      uri,
      headers: getAuthHeaderWith(token),
    );
  }

  Future<http.Response> addCase(
    String token,
    String workshopId,
    Map<String, dynamic> requestBody,
  ) {
    return _client.post(
      Uri.parse("$backendUrl/$workshopId/cases"),
      headers: getAuthHeaderWith(token, {
        "Content-Type": "application/json; charset=UTF-8",
      }),
      body: jsonEncode(requestBody),
    );
  }

  Future<http.Response> updateCase(
    String token,
    String workshopId,
    String caseId,
    Map<String, dynamic> requestBody,
  ) {
    return _client.put(
      Uri.parse("$backendUrl/$workshopId/cases/$caseId"),
      headers: getAuthHeaderWith(token, {
        "Content-Type": "application/json; charset=UTF-8",
      }),
      body: jsonEncode(requestBody),
    );
  }

  Future<http.Response> deleteCase(
    String token,
    String workshopId,
    String caseId,
  ) {
    return _client.delete(
      Uri.parse("$backendUrl/$workshopId/cases/$caseId"),
      headers: getAuthHeaderWith(token),
    );
  }

  Future<http.Response> deleteObdData(
    String token,
    int? dataId,
    String workshopId,
    String caseId,
  ) {
    return _client.delete(
      Uri.parse("$backendUrl/$workshopId/cases/$caseId/obd_data/$dataId"),
      headers: getAuthHeaderWith(token),
    );
  }

  Future<http.Response> deleteTimeseriesData(
    String token,
    int? dataId,
    String workshopId,
    String caseId,
  ) {
    return _client.delete(
      Uri.parse("$backendUrl/$workshopId/cases/$caseId/timeseries/$dataId"),
      headers: getAuthHeaderWith(token),
    );
  }

  Future<http.Response> deleteSymptomData(
    String token,
    int? dataId,
    String workshopId,
    String caseId,
  ) {
    return _client.delete(
      Uri.parse("$backendUrl/$workshopId/cases/$caseId/symptoms/$dataId"),
      headers: getAuthHeaderWith(token),
    );
  }

  Future<http.Response> getDiagnoses(
    String token,
    String workshopId,
  ) {
    return _client.get(
      Uri.parse("$backendUrl/$workshopId/diagnoses"),
      headers: getAuthHeaderWith(token),
    );
  }

  Future<http.Response> getDiagnosis(
    String token,
    String workshopId,
    String caseId,
  ) {
    return _client.get(
      Uri.parse("$backendUrl/$workshopId/cases/$caseId/diag"),
      headers: getAuthHeaderWith(token),
    );
  }

  Future<http.Response> startDiagnosis(
    String token,
    String workshopId,
    String caseId,
  ) {
    return _client.post(
      Uri.parse("$backendUrl/$workshopId/cases/$caseId/diag"),
      headers: getAuthHeaderWith(token),
    );
  }

  Future<http.Response> deleteDiagnosis(
    String token,
    String workshopId,
    String caseId,
  ) {
    return _client.delete(
      Uri.parse("$backendUrl/$workshopId/cases/$caseId/diag"),
      headers: getAuthHeaderWith(token),
    );
  }

  Future<http.Response> uploadObdData(
    String token,
    String workshopId,
    String caseId,
    Map<String, dynamic> requestBody,
  ) {
    return _client.post(
      Uri.parse("$backendUrl/$workshopId/cases/$caseId/obd_data"),
      headers: getAuthHeaderWith(token, {
        "Content-Type": "application/json; charset=UTF-8",
      }),
      body: jsonEncode(requestBody),
    );
  }

  Future<http.Response> uploadVcdsData(
    String token,
    String workshopId,
    String caseId,
    List<int> vcdsData,
    String filename,
  ) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse(
        "$backendUrl/$workshopId/cases/$caseId/obd_data/upload/vcds",
      ),
    );
    request.files.add(
      http.MultipartFile.fromBytes("upload", vcdsData, filename: filename),
    );
    request.fields["file_format"] = "VCDS TXT";

    final Map<String, String> authHeader = getAuthHeaderWith(token);
    assert(authHeader.length == 1);
    request.headers[authHeader.keys.first] = authHeader.values.first;

    final response = await _client.send(request);
    return http.Response.fromStream(response);
  }

  Future<http.Response> addTimeseriesData(
    String token,
    String workshopId,
    String caseId,
    String component,
    TimeseriesDataLabel label,
    int samplingRate,
    int duration,
    List<int> signal,
  ) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse(
        "$backendUrl/$workshopId/cases/$caseId/timeseries_data",
      ),
    );

    request.fields["label"] = EnumToString.convertToString(label);
    request.fields["component"] = component;
    request.fields["sampling_rate"] = samplingRate.toString();
    request.fields["duration"] = duration.toString();
    request.fields["signal"] = signal.toString();

    final Map<String, String> authHeader = getAuthHeaderWith(token);
    assert(authHeader.length == 1);
    request.headers[authHeader.keys.first] = authHeader.values.first;

    final response = await _client.send(request);
    return http.Response.fromStream(response);
  }

  Future<http.Response> uploadPicoscopeData(
    String token,
    String workshopId,
    String caseId,
    List<int> picoscopeData,
    String filename, {
    String? componentA,
    String? componentB,
    String? componentC,
    String? componentD,
    PicoscopeLabel? labelA,
    PicoscopeLabel? labelB,
    PicoscopeLabel? labelC,
    PicoscopeLabel? labelD,
  }) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse(
        "$backendUrl/$workshopId/cases/$caseId/timeseries_data/upload/picoscope",
      ),
    );

    request.files.add(
      http.MultipartFile.fromBytes("upload", picoscopeData, filename: filename),
    );

    request.fields["file_format"] = "Picoscope CSV";
    final components = {
      "A": componentA,
      "B": componentB,
      "C": componentC,
      "D": componentD,
    };
    final labels = {"A": labelA, "B": labelB, "C": labelC, "D": labelD};

    components.forEach((k, v) {
      if (v != null) request.fields["component_$k"] = v;
    });
    labels.forEach((k, v) {
      if (v != null) {
        request.fields["label_$k"] = EnumToString.convertToString(v);
      }
    });

    final Map<String, String> authHeader = getAuthHeaderWith(token);
    assert(authHeader.length == 1);
    request.headers[authHeader.keys.first] = authHeader.values.first;

    final response = await _client.send(request);
    return http.Response.fromStream(response);
  }

  Future<http.Response> uploadSymptomData(
    String token,
    String workshopId,
    String caseId,
    String component,
    SymptomLabel label,
  ) {
    final symptomDto = NewSymptomDto(component, label);
    final Map<String, dynamic> requestBody = symptomDto.toJson();

    return _client.post(
      Uri.parse("$backendUrl/$workshopId/cases/$caseId/symptoms"),
      headers: getAuthHeaderWith(token, {
        "Content-Type": "application/json; charset=UTF-8",
      }),
      body: jsonEncode(requestBody),
    );
  }

  Future<http.Response> uploadOmniviewData(
    String token,
    String workshopId,
    String caseId,
    String component,
    int samplingRate,
    int duration,
    List<int> omniviewData,
    String filename,
  ) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse(
        "$backendUrl/$workshopId/cases/$caseId/timeseries_data/upload/omniview",
      ),
    );

    request.files.add(
      http.MultipartFile.fromBytes("upload", omniviewData, filename: filename),
    );

    request.fields["component"] = component;
    request.fields["sampling_rate"] = samplingRate.toString();
    request.fields["duration"] = duration.toString();

    final Map<String, String> authHeader = getAuthHeaderWith(token);
    assert(authHeader.length == 1);
    request.headers[authHeader.keys.first] = authHeader.values.first;

    final response = await _client.send(request);
    return http.Response.fromStream(response);
  }

  Future<http.Response> getSharedCustomers(String token) {
    return _client.get(
      Uri.parse("$backendUrl/shared/customers"),
      headers: getAuthHeaderWith(token),
    );
  }

  Future<http.Response> getCustomer(
    String token,
    String workshopId,
    String caseId,
  ) {
    return _client.get(
      Uri.parse("$backendUrl/$workshopId/cases/$caseId/customer"),
      headers: getAuthHeaderWith(token),
    );
  }

  Future<http.Response> getCustomers(
    String token,
    int? page,
    int? pageSize,
  ) {
    final int pageNumber = page ?? 0;
    final int pageSizeNumber = pageSize ?? 30;

    final uri = Uri.parse("$backendUrl/customers").replace(
      queryParameters: {
        "page": pageNumber.toString(),
        "pageSize": pageSizeNumber.toString(),
      },
    );

    return _client.get(
      uri,
      headers: getAuthHeaderWith(token),
    );
  }

  Future<http.Response> addCustomer(
    String token,
    Map<String, dynamic> requestBody,
  ) {
    return _client.post(
      Uri.parse("$backendUrl/customers"),
      headers: getAuthHeaderWith(token, {
        "Content-Type": "application/json; charset=UTF-8",
      }),
      body: jsonEncode(requestBody),
    );
  }

  Future<http.Response> updateCustomer(
    String token,
    String customerId,
    Map<String, dynamic> requestBody,
  ) {
    return _client.patch(
      Uri.parse("$backendUrl/customers/$customerId"),
      headers: getAuthHeaderWith(token, {
        "Content-Type": "application/json; charset=UTF-8",
      }),
      body: jsonEncode(requestBody),
    );
  }

  Future<http.Response> getSharedVehicles(String token) {
    return _client.get(
      Uri.parse("$backendUrl/shared/vehicles"),
      headers: getAuthHeaderWith(token),
    );
  }

  Future<http.Response> getVehicles(
    String token,
    String workshopId,
    String caseId,
  ) {
    return _client.get(
      Uri.parse("$backendUrl/$workshopId/cases/$caseId/vehicles"),
      headers: getAuthHeaderWith(token),
    );
  }

  Future<http.Response> updateVehicle(
    String token,
    String workshopId,
    String caseId,
    Map<String, dynamic> requestBody,
  ) {
    return _client.put(
      Uri.parse("$backendUrl/$workshopId/cases/$caseId/vehicle"),
      headers: getAuthHeaderWith(token, {
        "Content-Type": "application/json; charset=UTF-8",
      }),
      body: jsonEncode(requestBody),
    );
  }

  Future<http.Response> getSharedAssets(String token) {
    return _client.get(
      Uri.parse("$backendUrl/shared/assets"),
      headers: getAuthHeaderWith(token),
    );
  }

  Future<http.Response> getAssets(
    String token,
    String workshopId,
    String caseId,
  ) {
    return _client.get(
      Uri.parse("$backendUrl/$workshopId/assets"),
      headers: getAuthHeaderWith(token),
    );
  }

  Future<http.Response> updateAssets(
    String token,
    String workshopId,
    String caseId,
    Map<String, dynamic> requestBody,
  ) {
    return _client.put(
      Uri.parse("$backendUrl/$workshopId/assets"),
      headers: getAuthHeaderWith(token, {
        "Content-Type": "application/json; charset=UTF-8",
      }),
      body: jsonEncode(requestBody),
    );
  }
}
