import "package:aw40_hub_frontend/models/asset_definition_model.dart";
import "package:json_annotation/json_annotation.dart";

part "asset_definition_dto.g.dart";

@JsonSerializable()
class AssetDefinitionDto {
  AssetDefinitionDto(
    this.vin,
    this.obdDataDtc,
    this.timeseriesDataComponent,
  );

  factory AssetDefinitionDto.fromJson(Map<String, dynamic> json) =>
      _$AssetDefinitionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AssetDefinitionDtoToJson(this);

  AssetDefinitionModel toModel() {
    return AssetDefinitionModel(
      vin: vin,
      obdDataDtc: obdDataDtc,
      timeseriesDataComponent: timeseriesDataComponent,
    );
  }

  String? vin;
  @JsonKey(name: "obd_data_dtc")
  String? obdDataDtc;
  @JsonKey(name: "timeseries_data_component")
  String? timeseriesDataComponent;
}
