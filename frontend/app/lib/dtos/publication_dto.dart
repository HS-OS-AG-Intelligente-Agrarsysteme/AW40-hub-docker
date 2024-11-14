import "package:aw40_hub_frontend/models/publication_model.dart";
import "package:json_annotation/json_annotation.dart";

part "publication_dto.g.dart";

@JsonSerializable()
class PublicationDto {
  PublicationDto(
    this.network,
    this.license,
    this.price,
    this.did,
    this.assetUrl,
  );

  factory PublicationDto.fromJson(Map<String, dynamic> json) =>
      _$PublicationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PublicationDtoToJson(this);

  PublicationModel toModel() {
    return PublicationModel(
      assetUrl: assetUrl,
      did: did,
      license: license,
      network: network,
      price: price,
    );
  }

  String network;
  String license;
  int? price;
  String did;
  @JsonKey(name: "asset_url")
  String assetUrl;
}
