import "package:aw40_hub_frontend/dtos/customer_dto.dart";
import "package:aw40_hub_frontend/models/customer_model.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("CustomerDto primary constructor", () {
    const id = "some_id";
    const firstname = "some_firstname";
    const lastname = "some_lastname";
    const email = "some_email";
    const phone = "some_phone";
    const street = "some_street";
    const housenumber = "some_housenumber";
    const postcode = "some_postcode";
    const city = "some_city";
    final CustomerDto customerDto = CustomerDto(
      id,
      firstname,
      lastname,
      email,
      phone,
      street,
      housenumber,
      postcode,
      city,
    );
    test("correctly assigns id", () {
      expect(customerDto.id, id);
    });
    test("correctly assigns firstname", () {
      expect(customerDto.firstname, firstname);
    });
    test("correctly assigns lastname", () {
      expect(customerDto.lastname, lastname);
    });
    test("correctly assigns email", () {
      expect(customerDto.email, email);
    });
    test("correctly assigns phone", () {
      expect(customerDto.phone, phone);
    });
    test("correctly assigns street", () {
      expect(customerDto.street, street);
    });
    test("correctly assigns housenumber", () {
      expect(customerDto.housenumber, housenumber);
    });
    test("correctly assigns postcode", () {
      expect(customerDto.postcode, postcode);
    });
    test("correctly assigns city", () {
      expect(customerDto.city, city);
    });
  });
  group("CustomerDto fromJson constructor", () {
    const id = "some_id";
    const firstname = "some_firstname";
    const lastname = "some_lastname";
    const email = "some_email";
    const phone = "some_phone";
    const street = "some_street";
    const housenumber = "some_housenumber";
    const postcode = "some_postcode";
    const city = "some_city";
    final Map<String, dynamic> json = <String, dynamic>{
      "_id": id,
      "first_name": firstname,
      "last_name": lastname,
      "email": email,
      "phone": phone,
      "street": street,
      "house_number": housenumber,
      "postcode": postcode,
      "city": city,
    };
    final CustomerDto customerDto = CustomerDto.fromJson(json);
    test("correctly assigns id", () {
      expect(customerDto.id, id);
    });
    test("correctly assigns firstname", () {
      expect(customerDto.firstname, firstname);
    });
    test("correctly assigns lastname", () {
      expect(customerDto.lastname, lastname);
    });
    test("correctly assigns email", () {
      expect(customerDto.email, email);
    });
    test("correctly assigns phone", () {
      expect(customerDto.phone, phone);
    });
    test("correctly assigns street", () {
      expect(customerDto.street, street);
    });
    test("correctly assigns housenumber", () {
      expect(customerDto.housenumber, housenumber);
    });
    test("correctly assigns postcode", () {
      expect(customerDto.postcode, postcode);
    });
    test("correctly assigns city", () {
      expect(customerDto.city, city);
    });
  });
  group("CustomerDto toJson method", () {
    const id = "some_id";
    const firstname = "some_firstname";
    const lastname = "some_lastname";
    const email = "some_email";
    const phone = "some_phone";
    const street = "some_street";
    const housenumber = "some_housenumber";
    const postcode = "some_postcode";
    const city = "some_city";
    final CustomerDto customerDto = CustomerDto(
      id,
      firstname,
      lastname,
      email,
      phone,
      street,
      housenumber,
      postcode,
      city,
    );
    final Map<String, dynamic> json = customerDto.toJson();
    test("correctly assigns id", () {
      expect(json["_id"], id);
    });
    test("correctly assigns firstname", () {
      expect(json["first_name"], firstname);
    });
    test("correctly assigns lastname", () {
      expect(json["last_name"], lastname);
    });
    test("correctly assigns email", () {
      expect(json["email"], email);
    });
    test("correctly assigns phone", () {
      expect(json["phone"], phone);
    });
    test("correctly assigns street", () {
      expect(json["street"], street);
    });
    test("correctly assigns housenumber", () {
      expect(json["house_number"], housenumber);
    });
    test("correctly assigns postcode", () {
      expect(json["postcode"], postcode);
    });
    test("correctly assigns city", () {
      expect(json["city"], city);
    });
  });

  group("CustomerDto toModel method", () {
    const id = "some_id";
    const firstname = "some_firstname";
    const lastname = "some_lastname";
    const email = "some_email";
    const phone = "some_phone";
    const street = "some_street";
    const housenumber = "some_housenumber";
    const postcode = "some_postcode";
    const city = "some_city";
    final CustomerDto customerDto = CustomerDto(
      id,
      firstname,
      lastname,
      email,
      phone,
      street,
      housenumber,
      postcode,
      city,
    );
    final CustomerModel customerModel = customerDto.toModel();
    test("correctly assigns id", () {
      expect(customerModel.id, id);
    });
    test("correctly assigns firstname", () {
      expect(customerDto.firstname, firstname);
    });
    test("correctly assigns lastname", () {
      expect(customerDto.lastname, lastname);
    });
    test("correctly assigns email", () {
      expect(customerDto.email, email);
    });
    test("correctly assigns phone", () {
      expect(customerDto.phone, phone);
    });
    test("correctly assigns street", () {
      expect(customerDto.street, street);
    });
    test("correctly assigns housenumber", () {
      expect(customerDto.housenumber, housenumber);
    });
    test("correctly assigns postcode", () {
      expect(customerDto.postcode, postcode);
    });
    test("correctly assigns city", () {
      expect(customerDto.city, city);
    });
  });
}
