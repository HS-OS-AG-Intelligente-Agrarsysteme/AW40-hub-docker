import "package:aw40_hub_frontend/utils/utils.dart";

class TimeseriesDataModel {
  TimeseriesDataModel({
    required this.timestamp,
    required this.component,
    required this.label,
    required this.samplingRate,
    required this.duration,
    required this.type,
    required this.dataId,
    required this.signalId,
  });

  DateTime timestamp;
  String component;
  TimeseriesDataLabel label;
  int samplingRate;
  int duration;
  String type;
  int dataId;
  String signalId;
}
