import "package:json_annotation/json_annotation.dart";

part "vehicle_update_dto.g.dart";

/// DTO for the PUT /{workshop_id}/cases/{case_id}/vehicle endpoint.
@JsonSerializable()
class VehicleUpdateDto {
  VehicleUpdateDto(
    this.tsn,
    this.yearBuild,
  );

  factory VehicleUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$VehicleUpdateDtoFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleUpdateDtoToJson(this);

  String? tsn;
  @JsonKey(name: "year_build")
  int? yearBuild;
}
