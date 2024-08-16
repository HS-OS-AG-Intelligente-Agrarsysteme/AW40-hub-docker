import "package:aw40_hub_frontend/models/symptom_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:json_annotation/json_annotation.dart";

part "symptom_dto.g.dart";

@JsonSerializable()
class SymptomDto {
  SymptomDto(
    this.timestamp,
    this.component,
    this.label,
    this.dataId,
  );

  factory SymptomDto.fromJson(Map<String, dynamic> json) =>
      _$SymptomDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SymptomDtoToJson(this);

  SymptomModel toModel() {
    return SymptomModel(
      timestamp: timestamp,
      component: component,
      label: label,
      dataId: dataId,
    );
  }

  DateTime? timestamp;
  String component;
  SymptomLabel label;
  @JsonKey(name: "data_id")
  int? dataId;
}
