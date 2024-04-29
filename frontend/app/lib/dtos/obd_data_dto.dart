import "package:aw40_hub_frontend/models/obd_data_model.dart";
import "package:json_annotation/json_annotation.dart";

part "obd_data_dto.g.dart";

@JsonSerializable()
class ObdDataDto {
  ObdDataDto(
    this.timestamp,
    this.obdSpecs,
    this.dtcs,
    this.dataId,
  );

  factory ObdDataDto.fromJson(Map<String, dynamic> json) {
    return _$ObdDataDtoFromJson(json);
  }
  Map<String, dynamic> toJson() => _$ObdDataDtoToJson(this);

  ObdDataModel toModel() {
    return ObdDataModel(
      timestamp: timestamp,
      obdSpecs: obdSpecs,
      dtcs: dtcs,
      dataId: dataId,
    );
  }

  DateTime timestamp;
  List<dynamic>? obdSpecs;
  List<String>? dtcs; //Length 5
  int dataId;
}
