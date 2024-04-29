class ObdDataModel {
  ObdDataModel({
    required this.timestamp,
    required this.obdSpecs,
    required this.dtcs,
    required this.dataId,
  });

  DateTime? timestamp;
  List<dynamic>? obdSpecs;
  List<String> dtcs;
  int? dataId;
}
