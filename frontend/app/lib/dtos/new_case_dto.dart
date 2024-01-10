import "package:aw40_hub_frontend/utils/utils.dart";
import "package:json_annotation/json_annotation.dart";

part "new_case_dto.g.dart";

/// DTO for the POST /{workshop_id}/cases endpoint.
@JsonSerializable()
class NewCaseDto {
  NewCaseDto(
    this.vehicleVin,
    this.customerId,
    this.occasion,
    this.milage,
  );

  factory NewCaseDto.fromJson(Map<String, dynamic> json) =>
      _$NewCaseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$NewCaseDtoToJson(this);

  @JsonKey(name: "vehicle_vin")
  String vehicleVin;
  @JsonKey(name: "customer_id")
  String customerId;
  CaseOccasion occasion;
  int milage;
}
