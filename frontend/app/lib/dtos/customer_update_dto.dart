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

  String firstname;
  String lastname;
  String? email;
  String? phone;
  String? street;
  String? housenumber;
  String? postcode;
  String? city;
}
