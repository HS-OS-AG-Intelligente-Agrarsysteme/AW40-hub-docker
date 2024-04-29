import "package:aw40_hub_frontend/models/timeseries_data_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:json_annotation/json_annotation.dart";

part "timeseries_data_dto.g.dart";

@JsonSerializable()
class TimeseriesDataDto {
  TimeseriesDataDto(
    this.timestamp,
    this.component,
    this.label,
    this.samplingRate,
    this.duration,
    this.type,
    this.dataId,
    this.signalId,
  );

  factory TimeseriesDataDto.fromJson(Map<String, dynamic> json) {
    return _$TimeseriesDataDtoFromJson(json);
  }
  Map<String, dynamic> toJson() => _$TimeseriesDataDtoToJson(this);

  TimeseriesDataModel toModel() {
    return TimeseriesDataModel(
      timestamp: timestamp,
      component: component,
      label: label,
      samplingRate: samplingRate,
      duration: duration,
      type: type,
      dataId: dataId,
      signalId: signalId,
    );
  }

  DateTime? timestamp;
  String component;
  TimeseriesDataLabel label;
  int samplingRate;
  int duration;
  String? type;
  int? dataId;
  String signalId;
}
