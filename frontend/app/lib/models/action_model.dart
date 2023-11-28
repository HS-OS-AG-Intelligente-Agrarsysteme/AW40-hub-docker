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
  dynamic actionType;
  dynamic dataType;
  dynamic component;
}
