import "package:aw40_hub_frontend/models/customer_model.dart";
import "package:aw40_hub_frontend/services/helper_service.dart";
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
      firstname: HelperService.convertIso88591ToUtf8(firstname),
      lastname: HelperService.convertIso88591ToUtf8(lastname),
      email: email != null ? HelperService.convertIso88591ToUtf8(email!) : null,
      phone: phone != null ? HelperService.convertIso88591ToUtf8(phone!) : null,
      street:
          street != null ? HelperService.convertIso88591ToUtf8(street!) : null,
      housenumber: housenumber != null
          ? HelperService.convertIso88591ToUtf8(housenumber!)
          : null,
      postcode: postcode != null
          ? HelperService.convertIso88591ToUtf8(postcode!)
          : null,
      city: city != null ? HelperService.convertIso88591ToUtf8(city!) : null,
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
