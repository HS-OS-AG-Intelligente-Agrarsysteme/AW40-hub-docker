import "package:aw40_hub_frontend/models/customer_model.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("CostumerModel", () {
    const id = "some_id";
    const firstname = "some_firstname";
    const lastname = "some_lastname";
    const email = "some_email";
    const phone = "some_phone";
    const street = "some_street";
    const housenumber = "some_housenumber";
    const postcode = "some_postcode";
    const city = "some_city";

    final costumerModel = CustomerModel(
      id: id,
      firstname: firstname,
      lastname: lastname,
      email: email,
      phone: phone,
      street: street,
      housenumber: housenumber,
      postcode: postcode,
      city: city,
    );
    test("correctly assigns id", () {
      expect(costumerModel.id, id);
    });
    test("correctly assigns firstname", () {
      expect(costumerModel.firstname, firstname);
    });
    test("correctly assigns lastname", () {
      expect(costumerModel.lastname, lastname);
    });
    test("correctly assigns email", () {
      expect(costumerModel.email, email);
    });
    test("correctly assigns phone", () {
      expect(costumerModel.phone, phone);
    });
    test("correctly assigns street", () {
      expect(costumerModel.street, street);
    });
    test("correctly assigns housenumber", () {
      expect(costumerModel.housenumber, housenumber);
    });
    test("correctly assigns postcode", () {
      expect(costumerModel.postcode, postcode);
    });
    test("correctly assigns city", () {
      expect(costumerModel.city, city);
    });
  });
}
