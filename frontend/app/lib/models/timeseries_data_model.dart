import "package:aw40_hub_frontend/models/data_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";

class TimeseriesDataModel extends DataModel {
  TimeseriesDataModel({
    required super.timestamp,
    required this.component,
    required this.label,
    required this.samplingRate,
    required this.duration,
    required this.type,
    required this.deviceSpecs,
    required super.dataId,
    required this.signalId,
  });

  final String component;
  final TimeseriesDataLabel label;
  final int samplingRate;
  final int duration;
  final TimeseriesType? type;
  final dynamic deviceSpecs;
  final String signalId;
}
