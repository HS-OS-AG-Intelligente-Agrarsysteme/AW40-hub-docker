import "package:aw40_hub_frontend/models/timeseries_data_model.dart";
import "package:json_annotation/json_annotation.dart";

part "timeseries_data_dto.g.dart";

@JsonSerializable()
class TimeseriesDataDto {
  TimeseriesDataDto(
    this.timestamp,
    this.component,
    this.label,
    this.sampling_rate,
    this.duration,
    this.type,
    this.data_id,
    this.signal_id,
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
      sampling_rate: sampling_rate,
      duration: duration,
      type: type,
      data_id: data_id,
      signal_id: signal_id,
    );
  }

  DateTime timestamp;
  String component;
  String label;
  int sampling_rate;
  int duration;
  String type;
  int data_id;
  String signal_id;
}
