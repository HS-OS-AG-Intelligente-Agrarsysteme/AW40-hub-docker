import "package:aw40_hub_frontend/models/data_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";

class SymptomModel extends DataModel {
  SymptomModel({
    required super.timestamp,
    required this.component,
    required this.label,
    required super.dataId,
  });

  final String component;
  final SymptomLabel label;
}
