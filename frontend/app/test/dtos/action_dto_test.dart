import "package:aw40_hub_frontend/dtos/action_dto.dart";
import "package:aw40_hub_frontend/models/action_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("ActionDto primary constructor", () {
    const String id = "some_id";
    const String instruction = "some_customer_id";
    const String actionType = "some_action_type";
    const DatasetType dataType = DatasetType.obd;
    const String component = "some_component";
    final ActionDto actionDto = ActionDto(
      id,
      instruction,
      actionType,
      dataType,
      component,
    );
    test("correctly assigns id", () {
      expect(actionDto.id, id);
    });
    test("correctly assigns instruction", () {
      expect(actionDto.instruction, instruction);
    });
    test("correctly assigns actionType", () {
      expect(actionDto.actionType, actionType);
    });
    test("correctly assigns dataType", () {
      expect(actionDto.dataType, dataType);
    });
    test("correctly assigns component", () {
      expect(actionDto.component, component);
    });
  });
  group("ActionDto fromJson constructor", () {
    const String id = "some_id";
    const String instruction = "some_customer_id";
    const String actionType = "some_action_type";
    const DatasetType dataType = DatasetType.obd;
    const String component = "some_component";
    final Map<String, dynamic> json = <String, dynamic>{
      "id": id,
      "instruction": instruction,
      "action_type": actionType,
      "data_type": dataType.name,
      "component": component,
    };
    final ActionDto actionDto = ActionDto.fromJson(json);
    test("correctly assigns id", () {
      expect(actionDto.id, id);
    });
    test("correctly assigns instruction", () {
      expect(actionDto.instruction, instruction);
    });
    test("correctly assigns actionType", () {
      expect(actionDto.actionType, actionType);
    });
    test("correctly assigns dataType", () {
      expect(actionDto.dataType, dataType);
    });
    test("correctly assigns component", () {
      expect(actionDto.component, component);
    });
  });
  group("ActionDto toJson method", () {
    const String id = "some_id";
    const String instruction = "some_customer_id";
    const String actionType = "some_action_type";
    const DatasetType dataType = DatasetType.obd;
    const String component = "some_component";
    final ActionDto actionDto = ActionDto(
      id,
      instruction,
      actionType,
      dataType,
      component,
    );
    final Map<String, dynamic> json = actionDto.toJson();
    test("correctly assigns id", () {
      expect(json["id"], id);
    });
    test("correctly assigns instruction", () {
      expect(json["instruction"], instruction);
    });
    test("correctly assigns actionType", () {
      expect(json["action_type"], actionType);
    });
    test("correctly assigns dataType", () {
      expect(json["data_type"], dataType.name);
    });
    test("correctly assigns component", () {
      expect(json["component"], component);
    });
  });
  group("ActionDto toModel method", () {
    const String id = "some_id";
    const String instruction = "some_customer_id";
    const String actionType = "some_action_type";
    const dataType = DatasetType.obd;
    const String component = "some_component";
    final ActionDto actionDto = ActionDto(
      id,
      instruction,
      actionType,
      dataType,
      component,
    );
    final ActionModel actionModel = actionDto.toModel();
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
