import "package:aw40_hub_frontend/dtos/new_case_dto.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("NewCaseDto primary constructor", () {
    const String vehicleVin = "12345678901234567";
    const String customerId = "some_customer_id";
    const CaseOccasion occasion = CaseOccasion.unknown;
    const int milage = 400;
    final NewCaseDto newCaseDto = NewCaseDto(
      vehicleVin,
      customerId,
      occasion,
      milage,
    );
    test("correctly assigns vehicleVin", () {
      expect(newCaseDto.vehicleVin, vehicleVin);
    });
    test("correctly assigns customerId", () {
      expect(newCaseDto.customerId, customerId);
    });
    test("correctly assigns occasion", () {
      expect(newCaseDto.occasion, occasion);
    });
    test("correctly assigns milage", () {
      expect(newCaseDto.milage, milage);
    });
  });
  group("NewCaseDto fromJson constructor", () {
    const String vehicleVin = "12345678901234567";
    const String customerId = "some.customer_id";
    const CaseOccasion occasion = CaseOccasion.unknown;
    const int milage = 500;
    final Map<String, dynamic> json = <String, dynamic>{
      "vehicle_vin": vehicleVin,
      "customer_id": customerId,
      "occasion": occasion.name,
      "milage": milage,
    };
    final NewCaseDto newCaseDto = NewCaseDto.fromJson(json);
    test("correctly assigns vehicleVin", () {
      expect(newCaseDto.vehicleVin, vehicleVin);
    });
    test("correctly assigns customerId", () {
      expect(newCaseDto.customerId, customerId);
    });
    test("correctly assigns occasion", () {
      expect(newCaseDto.occasion, occasion);
    });
    test("correctly assigns milage", () {
      expect(newCaseDto.milage, milage);
    });
  });
  group("NewCaseDto toJson method", () {
    const String vehicleVin = "12345678901234567";
    const String customerId = "some.customer_id";
    const CaseOccasion occasion = CaseOccasion.unknown;
    const int milage = 600;
    final NewCaseDto newCaseDto = NewCaseDto(
      vehicleVin,
      customerId,
      occasion,
      milage,
    );
    final Map<String, dynamic> json = newCaseDto.toJson();
    test("correctly assigns vehicleVin", () {
      expect(json["vehicle_vin"], vehicleVin);
    });
    test("correctly assigns customerId", () {
      expect(json["customer_id"], customerId);
    });
    test("correctly assigns occasion", () {
      expect(json["occasion"], occasion.name);
    });
    test("correctly assigns milage", () {
      expect(json["milage"], milage);
    });
  });
}
