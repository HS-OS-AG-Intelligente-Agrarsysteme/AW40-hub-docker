import "package:aw40_hub_frontend/models/action_model.dart";
import "package:aw40_hub_frontend/models/state_machine_log_entry_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";

class DiagnosisModel {
  DiagnosisModel({
    required this.id,
    required this.timestamp,
    required this.status,
    required this.caseId,
    required this.stateMachineLog,
    required this.todos,
  });

  String id;
  DateTime timestamp;
  DiagnosisStatus status;
  String caseId;
  List<StateMachineLogEntryModel> stateMachineLog;
  List<ActionModel> todos;
}
