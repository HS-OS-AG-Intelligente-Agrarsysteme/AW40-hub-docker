class AssetDefinitionModel {
  AssetDefinitionModel({
    required this.vin,
    required this.obdDataDtc,
    required this.timeseriesDataComponent,
  });

  String? vin;
  String? obdDataDtc;
  String? timeseriesDataComponent;

  Map<String, dynamic> toJsonWithoutNullValues() {
    final Map<String, dynamic> data = {};

    if (vin != null) data["vin"] = vin;
    if (obdDataDtc != null) data["obdDataDtc"] = obdDataDtc;
    if (timeseriesDataComponent != null) {
      data["timeseriesDataComponent"] = timeseriesDataComponent;
    }

    return data;
  }
}
