import "package:aw40_hub_frontend/services/http_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:http/http.dart" show Response;

class MockHttpService implements HttpService {
  @override
  Future<Response> addCase(
    String token,
    String workshopId,
    Map<String, dynamic> requestBody,
  ) {
    // TODO: implement addCase
    throw UnimplementedError();
  }

  @override
  Future<Response> checkBackendHealth() {
    // TODO: implement checkBackendHealth
    throw UnimplementedError();
  }

  @override
  Future<Response> deleteCase(String token, String workshopId, String caseId) {
    // TODO: implement deleteCase
    throw UnimplementedError();
  }

  @override
  Future<Response> deleteDiagnosis(
    String token,
    String workshopId,
    String caseId,
  ) {
    // TODO: implement deleteDiagnosis
    throw UnimplementedError();
  }

  @override
  Map<String, String> getAuthHeaderWith(
    String token, [
    Map<String, String>? otherHeaders,
  ]) {
    // TODO: implement getAuthHeaderWith
    throw UnimplementedError();
  }

  @override
  Future<Response> getCases(String token, String workshopId) {
    // TODO: implement getCases
    throw UnimplementedError();
  }

  @override
  Future<Response> getDiagnoses(String token, String workshopId) {
    // TODO: implement getDiagnoses
    throw UnimplementedError();
  }

  @override
  Future<Response> getDiagnosis(
    String token,
    String workshopId,
    String caseId,
  ) {
    // TODO: implement getDiagnosis
    throw UnimplementedError();
  }

  @override
  Future<Response> getSharedCases(String token) {
    // TODO: implement getSharedCases
    throw UnimplementedError();
  }

  @override
  Future<Response> startDiagnosis(
    String token,
    String workshopId,
    String caseId,
  ) {
    // TODO: implement startDiagnosis
    throw UnimplementedError();
  }

  @override
  Future<Response> updateCase(
    String token,
    String workshopId,
    String caseId,
    Map<String, dynamic> requestBody,
  ) {
    // TODO: implement updateCase
    throw UnimplementedError();
  }

  @override
  Future<Response> uploadObdData(
    String token,
    String workshopId,
    String caseId,
    Map<String, dynamic> requestBody,
  ) {
    // TODO: implement uploadObdData
    throw UnimplementedError();
  }

  @override
  Future<Response> uploadOmniviewData(
    String token,
    String workshopId,
    String caseId,
    String component,
    int samplingRate,
    int duration,
    List<int> omniviewData,
    String filename,
  ) {
    // TODO: implement uploadOmniviewData
    throw UnimplementedError();
  }

  @override
  Future<Response> uploadPicoscopeData(
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
  }) {
    // TODO: implement uploadPicoscopeData
    throw UnimplementedError();
  }

  @override
  Future<Response> uploadSymptomData(
    String token,
    String workshopId,
    String caseId,
    Map<String, dynamic> requestBody,
  ) {
    // TODO: implement uploadSymptomData
    throw UnimplementedError();
  }
}
