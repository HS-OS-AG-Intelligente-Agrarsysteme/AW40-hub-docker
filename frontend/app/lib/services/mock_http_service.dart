// ignore_for_file: avoid_catching_errors
import "dart:convert";

import "package:aw40_hub_frontend/dtos/case_dto.dart";
import "package:aw40_hub_frontend/dtos/case_update_dto.dart";
import "package:aw40_hub_frontend/dtos/diagnosis_dto.dart";
import "package:aw40_hub_frontend/dtos/new_case_dto.dart";
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
    final NewCaseDto newCaseDto;
    try {
      newCaseDto = NewCaseDto.fromJson(requestBody);
    } on Error {
      return Future.delayed(
        const Duration(milliseconds: 100),
        () => Response("", 422),
      );
    }
    final CaseDto caseDto = CaseDto(
      "1",
      DateTime.now(),
      newCaseDto.occasion,
      newCaseDto.milage,
      CaseStatus.open,
      newCaseDto.customerId,
      newCaseDto.vehicleVin,
      workshopId,
      null,
      [],
      [],
      [],
      0,
      0,
      0,
    );
    return Future.delayed(
      const Duration(milliseconds: 100),
      () => Response(jsonEncode(caseDto.toJson()), 201),
    );
  }

  @override
  Future<Response> checkBackendHealth() {
    return Future.delayed(
      const Duration(milliseconds: 100),
      () => Response('{"status": "success"}', 200),
    );
  }

  @override
  Future<Response> deleteCase(String token, String workshopId, String caseId) {
    return Future.delayed(
      const Duration(milliseconds: 100),
      () => Response("", 200),
    );
  }

  @override
  Future<Response> deleteDiagnosis(
    String token,
    String workshopId,
    String caseId,
  ) {
    return Future.delayed(
      const Duration(milliseconds: 100),
      () => Response("", 200),
    );
  }

  @override
  Map<String, String> getAuthHeaderWith(
    String token, [
    Map<String, String>? otherHeaders,
  ]) {
    // TODO: Make getAuthHeaderWith() private in HttpService, amend tests,
    //  remove this implementation
    throw UnsupportedError(
      "This method should never be called on MockHttpService",
    );
  }

  @override
  Future<Response> getCases(String token, String workshopId) {
    // TODO: implement getCases
    throw UnimplementedError();
  }

  @override
  Future<Response> getDiagnoses(String token, String workshopId) {
    // TODO: implement getDiagnosis
    throw UnimplementedError();
  }

  @override
  Future<Response> getDiagnosis(
    String token,
    String workshopId,
    String caseId,
  ) {
    final DiagnosisDto diagnosisDto = DiagnosisDto(
      "1",
      DateTime.now(),
      DiagnosisStatus.processing,
      caseId,
      [],
      [],
    );
    return Future.delayed(
      const Duration(milliseconds: 100),
      () => Response(jsonEncode(diagnosisDto.toJson()), 200),
    );
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
    final DiagnosisDto diagnosisDto = DiagnosisDto(
      "1",
      DateTime.now(),
      DiagnosisStatus.processing,
      caseId,
      [],
      [],
    );
    return Future.delayed(
      const Duration(milliseconds: 100),
          () => Response(jsonEncode(diagnosisDto.toJson()), 200),
    );
  }

  @override
  Future<Response> updateCase(
    String token,
    String workshopId,
    String caseId,
    Map<String, dynamic> requestBody,
  ) {
    final CaseUpdateDto caseUpdateDto;
    try {
      caseUpdateDto = CaseUpdateDto.fromJson(requestBody);
    } on Error {
      return Future.delayed(
        const Duration(milliseconds: 100),
        () => Response("", 422),
      );
    }
    final CaseDto caseDto = CaseDto(
      caseId,
      caseUpdateDto.timestamp,
      caseUpdateDto.occasion,
      caseUpdateDto.milage,
      caseUpdateDto.status,
      "unknown",
      "12345678901234567",
      workshopId,
      null,
      [],
      [],
      [],
      0,
      0,
      0,
    );
    return Future.delayed(
      const Duration(milliseconds: 100),
          () => Response(jsonEncode(caseDto.toJson()), 200),
    );
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
