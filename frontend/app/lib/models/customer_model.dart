class CustomerModel {
  CustomerModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    this.email,
    this.phone,
    this.street,
    this.housenumber,
    this.postcode,
    this.city,
  });
  String? id;
  String firstname;
  String lastname;
  String? email;
  String? phone;
  String? street;
  String? housenumber;
  String? postcode;
  String? city;
}
