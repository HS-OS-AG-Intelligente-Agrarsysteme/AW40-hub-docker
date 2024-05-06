import "package:json_annotation/json_annotation.dart";

part "new_obd_data_dto.g.dart";

@JsonSerializable()
class NewOBDDataDto {
  NewOBDDataDto(
    this.obdSpecs,
    this.dtcs,
  );

  factory NewOBDDataDto.fromJson(Map<String, dynamic> json) =>
      _$NewOBDDataDtoFromJson(json);
  Map<String, dynamic> toJson() => _$NewOBDDataDtoToJson(this);

  @JsonKey(name: "obd_specs")
  List<dynamic>? obdSpecs;
  List<String> dtcs;
}
