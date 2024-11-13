import "package:aw40_hub_frontend/models/data_model.dart";

class ObdDataModel extends DataModel {
  ObdDataModel({
    required super.timestamp,
    required this.obdSpecs,
    required this.dtcs,
    required super.dataId,
  });

  final dynamic obdSpecs;
  final List<String> dtcs;
}
