import "package:aw40_hub_frontend/utils/utils.dart";

class SymptomModel {
  SymptomModel({
    required this.timestamp,
    required this.component,
    required this.label,
    required this.data_id,
  });

  DateTime timestamp;
  String component;
  String label;
  int data_id;
}
