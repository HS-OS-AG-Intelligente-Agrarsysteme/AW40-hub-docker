import "package:aw40_hub_frontend/models/state_machine_log_entry_model.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("StateMachineLogEntryModel", () {
    const String message = "some_message";
    const String attachment = "some_attachment";
    final StateMachineLogEntryModel stateMachineLogEntryModel =
        StateMachineLogEntryModel(
      message: message,
      attachment: attachment,
    );
    test("correctly assigns message", () {
      expect(stateMachineLogEntryModel.message, message);
    });
    test("correctly assigns attachment", () {
      expect(stateMachineLogEntryModel.attachment, attachment);
    });
  });
}
