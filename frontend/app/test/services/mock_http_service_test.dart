import "dart:convert";

import "package:aw40_hub_frontend/dtos/case_dto.dart";
import "package:aw40_hub_frontend/dtos/diagnosis_dto.dart";
import "package:aw40_hub_frontend/services/mock_http_service.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("MockHttpService", () {
    late MockHttpService mockHttpService;
    setUp(() => mockHttpService = MockHttpService());
    group("addCase", () {
      test("returns 201 CaseDto json", () async {
        const vehicleVin = "12345678901234567";
        const customerId = "unknown";
        const occasion = "problem_defect";
        const milage = 100;
        final Map<String, dynamic> requestBody = {
          "vehicle_vin": vehicleVin,
          "customer_id": customerId,
          "occasion": occasion,
          "milage": milage,
        };

        final response =
            await mockHttpService.addCase("token", "workshopId", requestBody);

        expect(response.statusCode, 201, reason: "status code should be 201");
        expect(
          () => CaseDto.fromJson(jsonDecode(response.body)),
          returnsNormally,
          reason: "should return valid CaseDto json",
        );

        final CaseDto caseDto = CaseDto.fromJson(jsonDecode(response.body));

        expect(
          caseDto.vehicleVin,
          vehicleVin,
          reason: "vehicleVin should be input parameter",
        );
        expect(
          caseDto.customerId,
          customerId,
          reason: "customerId should be input parameter",
        );
        expect(
          caseDto.occasion.name,
          occasion,
          reason: "occasion should be input parameter",
        );
        expect(
          caseDto.milage,
          milage,
          reason: "milage should be input parameter",
        );
      });
      test("returns 422 on incorrect requestBody", () async {
        final Map<String, dynamic> requestBody = {
          "vehicle_vin": "12345678901234567",
          "customer_id": "unknown",
          "occasion": "problem_defect",
          "milage": "100",
        };

        final response =
            await mockHttpService.addCase("token", "workshopId", requestBody);
        expect(response.statusCode, 422, reason: "status code should be 422");
      });
    });
    test("checkBackendHealth", () async {
      final response = await mockHttpService.checkBackendHealth();
      expect(response.statusCode, 200, reason: "status code should be 200");
      expect(
        response.body,
        '{"status": "success"}',
        reason: "should return expected body",
      );
    });
    test("deleteCase returns 200", () async {
      final response =
          await mockHttpService.deleteCase("token", "workshopId", "caseId");
      expect(response.statusCode, 200, reason: "status code should be 200");
    });
    test("deleteDiagnosis returns 200", () async {
      final response = await mockHttpService.deleteDiagnosis(
        "token",
        "workshopId",
        "caseId",
      );
      expect(response.statusCode, 200, reason: "status code should be 200");
    });
    test("getDiagnosis returns 200 DiagnosisDto json", () async {
      const caseId = "caseId";
      final response =
          await mockHttpService.getDiagnosis("token", "workshopId", caseId);

      expect(response.statusCode, 200, reason: "status code should be 200");
      expect(
        () => DiagnosisDto.fromJson(jsonDecode(response.body)),
        returnsNormally,
        reason: "should return valid DiagnosisDto json",
      );

      final DiagnosisDto diagnosisDto =
          DiagnosisDto.fromJson(jsonDecode(response.body));

      expect(
        diagnosisDto.caseId,
        caseId,
        reason: "customerId should be input parameter",
      );
    });
    test("startDiagnosis returns 200 DiagnosisDto json", () async {
      const caseId = "caseId";
      final response =
          await mockHttpService.startDiagnosis("token", "workshopId", caseId);

      expect(response.statusCode, 200, reason: "status code should be 200");
      expect(
        () => DiagnosisDto.fromJson(jsonDecode(response.body)),
        returnsNormally,
        reason: "should return valid DiagnosisDto json",
      );

      final DiagnosisDto diagnosisDto =
          DiagnosisDto.fromJson(jsonDecode(response.body));

      expect(
        diagnosisDto.caseId,
        caseId,
        reason: "customerId should be input parameter",
      );
    });
    group("updateCase", () {
      test("returns 200 CaseDto json", () async {
        final timestamp = DateTime.now();
        const occasion = "problem_defect";
        const milage = 100;
        const status = "open";
        final Map<String, dynamic> requestBody = {
          "timestamp": timestamp.toIso8601String(),
          "occasion": occasion,
          "milage": milage,
          "status": status,
        };
        const caseId = "caseId";
        const workshopId = "workshopId";

        final response = await mockHttpService.updateCase(
          "token",
          workshopId,
          caseId,
          requestBody,
        );

        expect(response.statusCode, 200, reason: "status code should be 200");
        expect(
          () => CaseDto.fromJson(jsonDecode(response.body)),
          returnsNormally,
          reason: "should return valid CaseDto json",
        );

        final CaseDto caseDto = CaseDto.fromJson(jsonDecode(response.body));

        expect(
          caseDto.id,
          caseId,
          reason: "id should be input parameter",
        );
        expect(
          caseDto.workshopId,
          workshopId,
          reason: "workshopId should be input parameter",
        );
        expect(
          caseDto.timestamp,
          timestamp,
          reason: "timestamp should be input parameter",
        );
        expect(
          caseDto.occasion.name,
          occasion,
          reason: "occasion should be input parameter",
        );
        expect(
          caseDto.milage,
          milage,
          reason: "milage should be input parameter",
        );
        expect(
          caseDto.status.name,
          status,
          reason: "status should be input parameter",
        );
      });
      test("returns 422 on incorrect requestBody", () async {
        final Map<String, dynamic> requestBody = {
          "occasion": "problem_defect",
          "milage": 100,
          "status": "open",
        };

        final response = await mockHttpService.updateCase(
          "token",
          "workshopId",
          "caseId",
          requestBody,
        );
        expect(response.statusCode, 422, reason: "status code should be 422");
      });
    });
    test("getAuthHeaderWith throws UnsupportedError", () {
      expect(
        () => mockHttpService.getAuthHeaderWith("token"),
        throwsUnsupportedError,
      );
    });
  });
}
