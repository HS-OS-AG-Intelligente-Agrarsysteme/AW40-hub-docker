import "package:json_annotation/json_annotation.dart";

part "new_customer_dto.g.dart";

@JsonSerializable()
class NewCustomerDto {
  NewCustomerDto(
    this.firstname,
    this.lastname,
    this.email,
    this.phone,
    this.street,
    this.housenumber,
    this.postcode,
    this.city,
  );

  factory NewCustomerDto.fromJson(Map<String, dynamic> json) {
    return _$NewCustomerDtoFromJson(json);
  }
  Map<String, dynamic> toJson() => _$NewCustomerDtoToJson(this);

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
