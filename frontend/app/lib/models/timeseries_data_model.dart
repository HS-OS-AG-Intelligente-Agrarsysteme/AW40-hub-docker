import "package:aw40_hub_frontend/utils/utils.dart";

class TimeseriesDataModel {
  TimeseriesDataModel({
    required this.timestamp,
    required this.component,
    required this.label,
    required this.samplingRate,
    required this.duration,
    required this.type,
    required this.deviceSpecs,
    required this.dataId,
    required this.signal,
  });

  DateTime? timestamp;
  String component;
  TimeseriesDataLabel label;
  int samplingRate;
  int duration;
  Type? type;
  dynamic deviceSpecs;
  int? dataId;
  List<String> signal;
}
