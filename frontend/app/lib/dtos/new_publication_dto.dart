import "package:aw40_hub_frontend/models/new_publication_model.dart";
import "package:json_annotation/json_annotation.dart";

part "new_publication_dto.g.dart";

@JsonSerializable()
class NewPublicationDto {
  NewPublicationDto(
    this.network,
    this.license,
    this.price,
    this.privateKey,
  );

  factory NewPublicationDto.fromJson(Map<String, dynamic> json) =>
      _$NewPublicationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NewPublicationDtoToJson(this);

  NewPublicationModel toModel() {
    return NewPublicationModel(
      license: license,
      network: network,
      price: price,
      privateKey: privateKey,
    );
  }

  String network;
  String license;
  double? price;
  @JsonKey(name: "nautilus_private_key")
  String privateKey;
}
