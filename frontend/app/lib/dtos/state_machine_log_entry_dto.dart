import "package:aw40_hub_frontend/models/state_machine_log_entry_model.dart";
import "package:json_annotation/json_annotation.dart";

part "state_machine_log_entry_dto.g.dart";

@JsonSerializable()
class StateMachineLogEntryDto {
  StateMachineLogEntryDto(
    this.message,
    this.attachment,
  );

  factory StateMachineLogEntryDto.fromJson(Map<String, dynamic> json) {
    return _$StateMachineLogEntryDtoFromJson(json);
  }

  Map<String, dynamic> toJson() => _$StateMachineLogEntryDtoToJson(this);

  StateMachineLogEntryModel toModel() {
    return StateMachineLogEntryModel(
      message: message,
      attachment: attachment,
    );
  }

  String message;
  dynamic attachment;
}
