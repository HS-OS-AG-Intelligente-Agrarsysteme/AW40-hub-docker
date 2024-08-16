import "package:aw40_hub_frontend/dtos/customer_dto.dart";
import "package:aw40_hub_frontend/models/customer_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("CustomerDto primary constructor", () {
    const id = AnonymousCustomerId.anonymous;
    final CustomerDto customerDto = CustomerDto(
      id,
    );
    test("correctly assigns id", () {
      expect(customerDto.id, id);
    });
  });
  group("CustomerDto fromJson constructor", () {
    const id = AnonymousCustomerId.anonymous;
    final Map<String, dynamic> json = <String, dynamic>{
      "_id": id.name,
    };
    final CustomerDto customerDto = CustomerDto.fromJson(json);
    test("correctly assigns id", () {
      expect(customerDto.id, id);
    });
  });
  group("VehicleDto toJson method", () {
    const id = AnonymousCustomerId.anonymous;
    final CustomerDto customerDto = CustomerDto(
      id,
    );
    final Map<String, dynamic> json = customerDto.toJson();
    test("correctly assigns id", () {
      expect(json["_id"], id.name);
    });
  });

  group("CustomerDto toModel method", () {
    const id = AnonymousCustomerId.anonymous;
    final CustomerDto customerDto = CustomerDto(
      id,
    );
    final CustomerModel customerModel = customerDto.toModel();
    test("correctly assigns id", () {
      expect(customerModel.id, id);
    });
  });
}
