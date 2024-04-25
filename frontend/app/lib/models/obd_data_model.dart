import "package:aw40_hub_frontend/utils/utils.dart";

class ObdDataModel {
  ObdDataModel({
    required this.timestamp,
    required this.obdSpecs,
    required this.dtcs,
    required this.data_id,
  });

  String timestamp;
  List<dynamic>? obdSpecs;
  List<dynamic>? dtcs; //Length 5
  int data_id;
}
