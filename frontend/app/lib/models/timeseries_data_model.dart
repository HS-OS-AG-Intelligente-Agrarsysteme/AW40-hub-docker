import "package:aw40_hub_frontend/utils/utils.dart";

class TimeseriesDataModel {
  TimeseriesDataModel({
    required this.timestamp,
    required this.component,
    required this.label,
    required this.sampling_rate,
    required this.duration,
    required this.type,
    required this.data_id,
    required this.signal_id,
  });

  DateTime timestamp;
  String component;
  String label;
  int sampling_rate;
  int duration;
  String type;
  int data_id;
  String signal_id;
}
