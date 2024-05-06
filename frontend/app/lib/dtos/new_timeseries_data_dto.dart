import "package:aw40_hub_frontend/utils/enums.dart";
import "package:json_annotation/json_annotation.dart";

part "new_timeseries_data_dto.g.dart";

@JsonSerializable()
class NewTimeseriesDataDto {
  NewTimeseriesDataDto(
    this.component,
    this.label,
    this.samplingRate,
    this.duration,
    this.type,
    this.deviceSpecs,
    this.signal,
  );

  factory NewTimeseriesDataDto.fromJson(Map<String, dynamic> json) =>
      _$NewTimeseriesDataDtoFromJson(json);
  Map<String, dynamic> toJson() => _$NewTimeseriesDataDtoToJson(this);

  String component;
  TimeseriesDataLabel label;
  @JsonKey(name: "sampling_rate")
  int samplingRate;
  int duration;
  TimeseriesType? type;
  @JsonKey(name: "device_specs")
  dynamic deviceSpecs;
  List<String> signal;
}
