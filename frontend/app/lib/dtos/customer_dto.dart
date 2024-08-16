import "package:aw40_hub_frontend/models/customer_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:json_annotation/json_annotation.dart";

part "customer_dto.g.dart";

@JsonSerializable()
class CustomerDto {
  CustomerDto(
    this.id,
  );

  factory CustomerDto.fromJson(Map<String, dynamic> json) {
    return _$CustomerDtoFromJson(json);
  }
  Map<String, dynamic> toJson() => _$CustomerDtoToJson(this);

  CustomerModel toModel() {
    return CustomerModel(
      id: id,
    );
  }

  @JsonKey(name: "_id")
  AnonymousCustomerId id;
}
