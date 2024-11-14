class AssetDefinitionModel {
  AssetDefinitionModel({
    required this.vin,
    required this.obdDataDtc,
    required this.timeseriesDataComponent,
  });

  String? vin;
  String? obdDataDtc;
  String? timeseriesDataComponent;
}
