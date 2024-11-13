import "package:aw40_hub_frontend/models/vehicle_model.dart";
import "package:json_annotation/json_annotation.dart";

part "vehicle_dto.g.dart";

@JsonSerializable()
class VehicleDto {
  VehicleDto(
    this.id,
    this.vin,
    this.tsn,
    this.yearBuild,
  );

  factory VehicleDto.fromJson(Map<String, dynamic> json) {
    return _$VehicleDtoFromJson(json);
  }
  Map<String, dynamic> toJson() => _$VehicleDtoToJson(this);

  VehicleModel toModel() {
    return VehicleModel(
      id: id,
      vin: vin,
      tsn: tsn,
      yearBuild: yearBuild,
    );
  }

  @JsonKey(name: "_id")
  String? id;
  String? vin;
  String? tsn;
  @JsonKey(name: "year_build")
  int? yearBuild;
}
