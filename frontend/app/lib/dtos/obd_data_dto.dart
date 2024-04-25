import "package:aw40_hub_frontend/dtos/action_dto.dart";
import "package:aw40_hub_frontend/models/obd_data_model.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
import "package:json_annotation/json_annotation.dart";

part "obd_data_dto.g.dart";

@JsonSerializable()
class DiagnosisDto {
  DiagnosisDto(
    this.timestamp,
    this.obdSpecs,
    this.dtcs,
    this.data_id,
  );

  factory DiagnosisDto.fromJson(Map<String, dynamic> json) {
    return _$ObdDataDtoFromJson(json);
  }
  Map<String, dynamic> toJson() => _$ObdDataDtoToJson(this);

  ObdDataModel toModel() {
    return ObdDataModel(
    timestamp: timestamp,
    obdSpecs: obdSpecs,
    dtcs dtcs,
    data_id: data_id,
        );
  }

  String timestamp;
  List<dynamic>? obdSpecs;
  List<dynamic>? dtcs; //Length 5
  int data_id;
}
