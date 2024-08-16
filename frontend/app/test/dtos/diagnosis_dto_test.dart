import "package:aw40_hub_frontend/dtos/action_dto.dart";
import "package:aw40_hub_frontend/dtos/diagnosis_dto.dart";
import "package:aw40_hub_frontend/dtos/state_machine_log_entry_dto.dart";
import "package:aw40_hub_frontend/models/action_model.dart";
import "package:aw40_hub_frontend/models/diagnosis_model.dart";
import "package:aw40_hub_frontend/models/state_machine_log_entry_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("DiagnosisDto primary constructor", () {
    const id = "test_id";
    final timeStamp = DateTime.utc(2021);
    const status = DiagnosisStatus.failed;
    const caseId = "some_case_id";
    final stateMachineLog = <StateMachineLogEntryDto>[
      StateMachineLogEntryDto("some_message", "some_attachment"),
      StateMachineLogEntryDto("another_message", "another_attachment"),
    ];
    final todos = <ActionDto>[
      ActionDto("1", "some action", "1", DatasetType.obd, "3")
    ];
    final DiagnosisDto diagnosisDto = DiagnosisDto(
      id,
      timeStamp,
      status,
      caseId,
      stateMachineLog,
      todos,
    );
    test("correctly assigns id", () {
      expect(diagnosisDto.id, id);
    });
    test("correctly assigns timestamp", () {
      expect(diagnosisDto.timestamp, timeStamp);
    });
    test("correctly assigns status", () {
      expect(diagnosisDto.status, status);
    });
    test("correctly assigns caseId", () {
      expect(diagnosisDto.caseId, caseId);
    });
    test("correctly assigns stateMachineLog", () {
      expect(diagnosisDto.stateMachineLog, stateMachineLog);
    });
    test("correctly assigns todos", () {
      expect(diagnosisDto.todos, todos);
    });
  });
  group("DiagnosisDto fromJson constructor", () {
    const id = "test_id";
    final timeStamp = DateTime.utc(2021);
    const status = DiagnosisStatus.failed;
    const caseId = "some_case_id";
    final stateMachineLog = <StateMachineLogEntryDto>[
      StateMachineLogEntryDto("some_message", "some_attachment"),
      StateMachineLogEntryDto("another_message", "another_attachment"),
    ];
    final todos = <ActionDto>[
      ActionDto("1", "some action", "1", DatasetType.obd, "3")
    ];
    final Map<String, dynamic> json = <String, dynamic>{
      "_id": id,
      "timestamp": timeStamp.toIso8601String(),
      "status": status.name,
      "case_id": caseId,
      "state_machine_log": stateMachineLog.map((e) => e.toJson()).toList(),
      "todos": todos.map((e) => e.toJson()).toList(),
    };
    final DiagnosisDto diagnosisDto = DiagnosisDto.fromJson(json);
    test("correctly assigns id", () {
      expect(diagnosisDto.id, id);
    });
    test("correctly assigns timestamp", () {
      expect(diagnosisDto.timestamp, timeStamp);
    });
    test("correctly assigns status", () {
      expect(diagnosisDto.status, status);
    });
    test("correctly assigns caseId", () {
      expect(diagnosisDto.caseId, caseId);
    });
    test("correctly assigns stateMachineLog", () {
      expect(
        diagnosisDto.stateMachineLog,
        isA<List<StateMachineLogEntryDto>>(),
      );
    });
    test("correctly assigns todos", () {
      expect(diagnosisDto.todos, isA<List<ActionDto>>());
    });
  });
  group("DiagnosisDto toJson method", () {
    const id = "test_id";
    final timeStamp = DateTime.utc(2021);
    const status = DiagnosisStatus.failed;
    const caseId = "some_case_id";
    final stateMachineLog = <StateMachineLogEntryDto>[
      StateMachineLogEntryDto("some_message", "some_attachment"),
      StateMachineLogEntryDto("another_message", "another_attachment"),
    ];
    final todos = <ActionDto>[
      ActionDto("1", "some action", "1", DatasetType.obd, "3")
    ];
    final DiagnosisDto diagnosisDto = DiagnosisDto(
      id,
      timeStamp,
      status,
      caseId,
      stateMachineLog,
      todos,
    );
    final Map<String, dynamic> json = diagnosisDto.toJson();
    test("correctly assigns id", () {
      expect(json["_id"], id);
    });
    test("correctly assigns timestamp", () {
      expect(json["timestamp"], timeStamp.toIso8601String());
    });
    test("correctly assigns status", () {
      expect(json["status"], status.name);
    });
    test("correctly assigns caseId", () {
      expect(json["case_id"], caseId);
    });
    test("correctly assigns stateMachineLog", () {
      expect(json["state_machine_log"], stateMachineLog);
    });
    test("correctly assigns todos", () {
      expect(json["todos"], todos);
    });
  });
  group("DiagnosisDto toModel method", () {
    const id = "test_id";
    final timeStamp = DateTime.utc(2021);
    const status = DiagnosisStatus.failed;
    const caseId = "some_case_id";
    final stateMachineLog = <StateMachineLogEntryDto>[
      StateMachineLogEntryDto("some_message", "some_attachment"),
      StateMachineLogEntryDto("another_message", "another_attachment"),
    ];
    final actionDto = ActionDto("1", "some action", "1", DatasetType.obd, "3");
    final todoDtos = <ActionDto>[actionDto];
    final DiagnosisDto diagnosisDto = DiagnosisDto(
      id,
      timeStamp,
      status,
      caseId,
      stateMachineLog,
      todoDtos,
    );
    final DiagnosisModel diagnosisModel = diagnosisDto.toModel();
    test("correctly assigns id", () {
      expect(diagnosisModel.id, id);
    });
    test("correctly assigns timestamp", () {
      expect(diagnosisModel.timestamp, timeStamp);
    });
    test("correctly assigns status", () {
      expect(diagnosisModel.status, status);
    });
    test("correctly assigns caseId", () {
      expect(diagnosisModel.caseId, caseId);
    });
    test("correctly assigns stateMachineLog", () {
      expect(
        diagnosisModel.stateMachineLog,
        isA<List<StateMachineLogEntryModel>>(),
      );
    });
    test("correctly assigns todos", () {
      expect(diagnosisModel.todos, isA<List<ActionModel>>());
    });
  });
}
