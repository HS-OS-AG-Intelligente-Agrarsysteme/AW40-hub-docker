import "package:aw40_hub_frontend/dtos/asset_definition_dto.dart";
import "package:json_annotation/json_annotation.dart";

part "new_asset_dto.g.dart";

/// DTO for the POST /{workshop_id}/cases endpoint.
@JsonSerializable()
class NewAssetDto {
  NewAssetDto(
    this.name,
    this.definition,
    this.description,
    this.author,
  );

  factory NewAssetDto.fromJson(Map<String, dynamic> json) =>
      _$NewAssetDtoFromJson(json);
  Map<String, dynamic> toJson() => _$NewAssetDtoToJson(this);

  String name;
  AssetDefinitionDto? definition;
  String description;
  String author;
}
