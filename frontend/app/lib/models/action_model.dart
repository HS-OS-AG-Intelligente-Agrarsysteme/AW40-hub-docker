import "package:aw40_hub_frontend/utils/enums.dart";

class ActionModel {
  ActionModel({
    required this.id,
    required this.instruction,
    required this.actionType,
    required this.dataType,
    required this.component,
  });

  String id;
  String instruction;
  String actionType;
  DatasetType dataType;
  String? component;
}
