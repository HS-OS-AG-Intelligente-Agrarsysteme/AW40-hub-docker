import "package:aw40_hub_frontend/models/action_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("ActionModel", () {
    const String id = "some_id";
    const String instruction = "some_customer_id";
    const String actionType = "some_action_type";
    const DatasetType dataType = DatasetType.obd;
    const String component = "some_component";

    final actionModel = ActionModel(
      id: id,
      instruction: instruction,
      actionType: actionType,
      dataType: dataType,
      component: component,
    );

    test("correctly assigns id", () {
      expect(actionModel.id, id);
    });
    test("correctly assigns instruction", () {
      expect(actionModel.instruction, instruction);
    });
    test("correctly assigns actionType", () {
      expect(actionModel.actionType, actionType);
    });
    test("correctly assigns dataType", () {
      expect(actionModel.dataType, dataType);
    });
    test("correctly assigns component", () {
      expect(actionModel.component, component);
    });
  });
}
