import "package:aw40_hub_frontend/dtos/case_update_dto.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("CaseUpdateDto primary constructor", () {
    final DateTime timeStamp = DateTime.utc(2021);
    const CaseOccasion occasion = CaseOccasion.unknown;
    const int milage = 100;
    const CaseStatus status = CaseStatus.closed;
    final CaseUpdateDto caseUpdateDto = CaseUpdateDto(
      timeStamp,
      occasion,
      milage,
      status,
    );
    test("correctly assigns timestamp", () {
      expect(caseUpdateDto.timestamp, timeStamp);
    });
    test("correctly assigns occasion", () {
      expect(caseUpdateDto.occasion, occasion);
    });
    test("correctly assigns milage", () {
      expect(caseUpdateDto.milage, milage);
    });
    test("correctly assigns status", () {
      expect(caseUpdateDto.status, status);
    });
  });
  group("CaseUpdateDto fromJson constructor", () {
    final DateTime timeStamp = DateTime.utc(2021);
    const CaseOccasion occasion = CaseOccasion.unknown;
    const int milage = 200;
    const CaseStatus status = CaseStatus.closed;
    final Map<String, dynamic> json = <String, dynamic>{
      "timestamp": timeStamp.toIso8601String(),
      "occasion": occasion.name,
      "milage": milage,
      "status": status.name,
    };
    final CaseUpdateDto caseUpdateDto = CaseUpdateDto.fromJson(json);
    test("correctly assigns timestamp", () {
      expect(caseUpdateDto.timestamp, timeStamp);
    });
    test("correctly assigns occasion", () {
      expect(caseUpdateDto.occasion, occasion);
    });
    test("correctly assigns milage", () {
      expect(caseUpdateDto.milage, milage);
    });
    test("correctly assigns status", () {
      expect(caseUpdateDto.status, status);
    });
  });
  group("CaseUpdateDto toJson method", () {
    final DateTime timeStamp = DateTime.utc(2021);
    const CaseOccasion occasion = CaseOccasion.unknown;
    const int milage = 300;
    const CaseStatus status = CaseStatus.open;
    final CaseUpdateDto caseUpdateDto = CaseUpdateDto(
      timeStamp,
      occasion,
      milage,
      status,
    );
    final Map<String, dynamic> json = caseUpdateDto.toJson();
    test("correctly assigns timestamp", () {
      expect(json["timestamp"], timeStamp.toIso8601String());
    });
    test("correctly assigns occasion", () {
      expect(json["occasion"], occasion.name);
    });
    test("correctly assigns milage", () {
      expect(json["milage"], milage);
    });
    test("correctly assigns status", () {
      expect(json["status"], status.name);
    });
  });
}
