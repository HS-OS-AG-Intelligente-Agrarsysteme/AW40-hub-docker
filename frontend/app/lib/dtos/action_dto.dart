import "package:aw40_hub_frontend/models/action_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:json_annotation/json_annotation.dart";

part "action_dto.g.dart";

@JsonSerializable()
class ActionDto {
  ActionDto(
    this.id,
    this.instruction,
    this.actionType,
    this.dataType,
    this.component,
  );

  factory ActionDto.fromJson(Map<String, dynamic> json) {
    return _$ActionDtoFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ActionDtoToJson(this);

  ActionModel toModel() {
    return ActionModel(
      id: id,
      instruction: instruction,
      actionType: actionType,
      dataType: dataType,
      component: component,
    );
  }

  String id;
  String instruction;
  @JsonKey(name: "action_type")
  String actionType;
  @JsonKey(name: "data_type")
  DatasetType dataType;
  String? component;
}
