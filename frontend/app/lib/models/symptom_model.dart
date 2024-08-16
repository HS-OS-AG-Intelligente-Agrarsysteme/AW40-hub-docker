import "package:aw40_hub_frontend/utils/enums.dart";

class SymptomModel {
  SymptomModel({
    required this.timestamp,
    required this.component,
    required this.label,
    required this.dataId,
  });

  DateTime? timestamp;
  String component;
  SymptomLabel label;
  int? dataId;
}
