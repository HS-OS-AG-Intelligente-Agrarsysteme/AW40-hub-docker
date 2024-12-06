import "package:json_annotation/json_annotation.dart";

part "assets_update_dto.g.dart";

@JsonSerializable()
class AssetsUpdateDto {
  AssetsUpdateDto(
    this.tsn,
    this.yearBuild,
  );

  factory AssetsUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$AssetsUpdateDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AssetsUpdateDtoToJson(this);

  String? tsn;
  @JsonKey(name: "year_build")
  int? yearBuild;
}
