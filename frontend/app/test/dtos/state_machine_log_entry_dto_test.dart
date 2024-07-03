import "package:aw40_hub_frontend/dtos/state_machine_log_entry_dto.dart";
import "package:aw40_hub_frontend/models/state_machine_log_entry_model.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("StateMachineLogEntryDto primary constructor", () {
    const String message = "some_message";
    const String attachment = "some_attachment";
    final StateMachineLogEntryDto stateMachineLogEntryDto =
        StateMachineLogEntryDto(
      message,
      attachment,
    );
    test("correctly assigns message", () {
      expect(stateMachineLogEntryDto.message, message);
    });
    test("correctly assigns attachment", () {
      expect(stateMachineLogEntryDto.attachment, attachment);
    });
  });
  group("StateMachineLogEntryDto fromJson constructor", () {
    const String message = "some_message";
    const String attachment = "some_attachment";
    final Map<String, dynamic> json = <String, dynamic>{
      "message": message,
      "attachment": attachment,
    };
    final StateMachineLogEntryDto stateMachineLogEntryDto =
        StateMachineLogEntryDto.fromJson(json);
    test("correctly assigns message", () {
      expect(stateMachineLogEntryDto.message, equals(message));
    });
    test("correctly assigns attachment", () {
      expect(stateMachineLogEntryDto.attachment, equals(attachment));
    });
  });
  group("StateMachineLogEntryDto toJson method", () {
    const String message = "some_message";
    const String attachment = "some_attachment";
    final StateMachineLogEntryDto stateMachineLogEntryDto =
        StateMachineLogEntryDto(
      message,
      attachment,
    );
    final Map<String, dynamic> json = stateMachineLogEntryDto.toJson();
    test("correctly assigns message", () {
      expect(json["message"], equals(message));
    });
    test("correctly assigns attachment", () {
      expect(json["attachment"], equals(attachment));
    });
  });
  group("StateMachineLogEntryDto toModel method", () {
    const String message = "some_message";
    const String attachment = "some_attachment";
    final StateMachineLogEntryDto stateMachineLogEntryDto =
        StateMachineLogEntryDto(
      message,
      attachment,
    );
    final StateMachineLogEntryModel stateMachineLogEntryModel =
        stateMachineLogEntryDto.toModel();
    test("correctly assigns message", () {
      expect(stateMachineLogEntryModel.message, equals(message));
    });
    test("correctly assigns attachment", () {
      expect(stateMachineLogEntryModel.attachment, equals(attachment));
    });
  });
}
