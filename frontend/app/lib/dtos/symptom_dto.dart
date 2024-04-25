import "package:aw40_hub_frontend/dtos/action_dto.dart";
import "package:aw40_hub_frontend/models/symptom_model.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
import "package:json_annotation/json_annotation.dart";

part "symptom_dto.g.dart";

@JsonSerializable()
class SymptomDto {
  SymptomDto(
    this.timestamp;
    this.component;
    this.label;
    this.data_id;
  );

  factory SymptomDto.fromJson(Map<String, dynamic> json) {
    return _$SymptomDtoFromJson(json);
  }
  Map<String, dynamic> toJson() => _$SymptomDtotoToJson(this);

  SymptomDto toModel() {
    return SymptomDto(
    timestamp: timestamp,
    component: component,
    label: label,
    data_id: data_id,
  );
  }

  DateTime timestamp;
  String component;
  String label;
  int data_id;
}
