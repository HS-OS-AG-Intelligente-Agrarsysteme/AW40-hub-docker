import "package:aw40_hub_frontend/dtos/action_dto.dart";
import "package:aw40_hub_frontend/dtos/state_machine_log_entry_dto.dart";
import "package:aw40_hub_frontend/models/diagnosis_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:json_annotation/json_annotation.dart";

part "diagnosis_dto.g.dart";

@JsonSerializable()
class DiagnosisDto {
  DiagnosisDto(
    this.id,
    this.timestamp,
    this.status,
    this.caseId,
    this.stateMachineLog,
    this.todos,
  );

  factory DiagnosisDto.fromJson(Map<String, dynamic> json) {
    return _$DiagnosisDtoFromJson(json);
  }
  Map<String, dynamic> toJson() => _$DiagnosisDtoToJson(this);

  DiagnosisModel toModel() {
    return DiagnosisModel(
      id: id,
      timestamp: timestamp,
      status: status,
      stateMachineLog: stateMachineLog.map((e) => e.toModel()).toList(),
      todos: todos.map((e) => e.toModel()).toList(),
      caseId: caseId,
    );
  }

  @JsonKey(name: "_id")
  String id;
  DateTime timestamp;
  DiagnosisStatus status;
  @JsonKey(name: "case_id")
  String caseId;
  @JsonKey(name: "state_machine_log")
  List<StateMachineLogEntryDto> stateMachineLog;
  List<ActionDto> todos;
}
