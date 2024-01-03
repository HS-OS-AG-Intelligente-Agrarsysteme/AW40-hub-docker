import "package:aw40_hub_frontend/utils/utils.dart";
import "package:json_annotation/json_annotation.dart";

part "new_symptom_dto.g.dart";

@JsonSerializable()
class NewSymptomDto {
  NewSymptomDto(
    this.timestamp,
    this.component,
    this.label,
  );

  factory NewSymptomDto.fromJson(Map<String, dynamic> json) =>
      _$NewSymptomDtoFromJson(json);
  Map<String, dynamic> toJson() => _$NewSymptomDtoToJson(this);

  String? timestamp;
  String component;
  SymptomLabel label;
}
