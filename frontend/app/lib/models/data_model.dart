abstract class DataModel {
  DataModel({
    required this.timestamp,
    required this.dataId,
  });

  DateTime? timestamp;
  int? dataId;
}
