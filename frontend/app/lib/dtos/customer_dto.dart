import "package:aw40_hub_frontend/models/customer_model.dart";
import "package:json_annotation/json_annotation.dart";

part "customer_dto.g.dart";

@JsonSerializable()
class CustomerDto {
  CustomerDto(
    this.id,
    this.firstname,
    this.lastname,
    this.email,
    this.phone,
    this.street,
    this.housenumber,
    this.postcode,
    this.city,
  );

  factory CustomerDto.fromJson(Map<String, dynamic> json) {
    return _$CustomerDtoFromJson(json);
  }
  Map<String, dynamic> toJson() => _$CustomerDtoToJson(this);

  CustomerModel toModel() {
    return CustomerModel(
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
  }

  @JsonKey(name: "_id")
  String? id;
  @JsonKey(name: "first_name")
  String firstname;
  @JsonKey(name: "last_name")
  String lastname;
  String? email;
  String? phone;
  String? street;
  @JsonKey(name: "house_number")
  String? housenumber;
  String? postcode;
  String? city;
}
