import "package:aw40_hub_frontend/utils/enums.dart";
import "package:json_annotation/json_annotation.dart";

part "case_update_dto.g.dart";

/// DTO for the PUT /{workshop_id}/cases/{case_id} endpoint.
@JsonSerializable()
class CaseUpdateDto {
  CaseUpdateDto(
    this.timestamp,
    this.occasion,
    this.milage,
    this.status,
  );

  factory CaseUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$CaseUpdateDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CaseUpdateDtoToJson(this);

  DateTime timestamp;
  CaseOccasion occasion;
  int milage;
  CaseStatus status;
}
