import "package:aw40_hub_frontend/models/action_model.dart";
import "package:aw40_hub_frontend/models/diagnosis_model.dart";
import "package:aw40_hub_frontend/models/state_machine_log_entry_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("DiagnosisModel", () {
    const id = "test_id";
    final timestamp = DateTime.now();
    const status = DiagnosisStatus.processing;
    const caseId = "some_case_id";
    final stateMachineLog = <StateMachineLogEntryModel>[
      StateMachineLogEntryModel(
        message: "some_message",
        attachment: "some_attachment",
      ),
      StateMachineLogEntryModel(
        message: "another_message",
        attachment: "another_attachment",
      ),
    ];
    final todos = <ActionModel>[
      ActionModel(
        id: "1",
        instruction: "some action",
        actionType: "1",
        dataType: DatasetType.obd,
        component: "3",
      ),
    ];

    final diagnosisModel = DiagnosisModel(
      id: id,
      timestamp: timestamp,
      status: status,
      caseId: caseId,
      stateMachineLog: stateMachineLog,
      todos: todos,
    );
    test("correctly assigns id", () {
      expect(diagnosisModel.id, id);
    });
    test("correctly assigns timestamp", () {
      expect(diagnosisModel.timestamp, timestamp);
    });
    test("correctly assigns status", () {
      expect(diagnosisModel.status, status);
    });
    test("correctly assigns caseId", () {
      expect(diagnosisModel.caseId, caseId);
    });
    test("correctly assigns stateMachineLog", () {
      expect(diagnosisModel.stateMachineLog, stateMachineLog);
    });
    test("correctly assigns todos", () {
      expect(diagnosisModel.todos, todos);
    });
  });
}
