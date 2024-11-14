import "package:aw40_hub_frontend/dtos/asset_definition_dto.dart";
import "package:aw40_hub_frontend/dtos/publication_dto.dart";
import "package:aw40_hub_frontend/models/asset_model.dart";
import "package:json_annotation/json_annotation.dart";

part "asset_dto.g.dart";

@JsonSerializable()
class AssetDto {
  AssetDto(
    this.id,
    this.name,
    this.definition,
    this.description,
    this.timestamp,
    this.type,
    this.author,
    this.dataStatus,
    this.publication,
  );

  factory AssetDto.fromJson(Map<String, dynamic> json) {
    return _$AssetDtoFromJson(json);
  }
  Map<String, dynamic> toJson() => _$AssetDtoToJson(this);

  AssetModel toModel() {
    return AssetModel(
      id: id,
      name: name,
      definition: definition.toModel(),
      description: description,
      timestamp: timestamp,
      type: type,
      author: author,
      dataStatus: dataStatus,
      publication: publication?.toModel(),
    );
  }

  @JsonKey(name: "_id")
  String? id;
  String name;
  AssetDefinitionDto definition;

  String description;
  DateTime? timestamp;
  String? type;
  String author;
  String? dataStatus;
  PublicationDto? publication;
}
