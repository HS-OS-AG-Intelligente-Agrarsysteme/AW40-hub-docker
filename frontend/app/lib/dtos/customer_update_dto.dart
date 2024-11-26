import "package:json_annotation/json_annotation.dart";

part "customer_update_dto.g.dart";

/// DTO for the PUT /{workshop_id}/cases/{case_id} endpoint.
@JsonSerializable()
class CustomerUpdateDto {
  CustomerUpdateDto(
    this.firstname,
    this.lastname,
    this.email,
    this.phone,
    this.street,
    this.housenumber,
    this.postcode,
    this.city,
  );

  factory CustomerUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$CustomerUpdateDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerUpdateDtoToJson(this);

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
