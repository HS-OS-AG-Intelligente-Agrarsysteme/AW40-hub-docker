import "package:aw40_hub_frontend/models/obd_data_model.dart";
import "package:aw40_hub_frontend/models/symptom_model.dart";
import "package:aw40_hub_frontend/models/timeseries_data_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";

class CaseModel {
  CaseModel({
    required this.id,
    required this.timestamp,
    required this.occasion,
    required this.milage,
    required this.status,
    required this.customerId,
    required this.vehicleVin,
    required this.workshopId,
    required this.diagnosisId,
    required this.timeseriesData,
    required this.obdData,
    required this.symptoms,
    required this.timeseriesDataAdded,
    required this.obdDataAdded,
    required this.symptomsAdded,
  });

  String id;
  DateTime timestamp;
  CaseOccasion occasion;
  int milage;
  CaseStatus status;
  String customerId;
  String vehicleVin;
  String workshopId;
  String? diagnosisId;
  List<TimeseriesDataModel> timeseriesData;
  List<ObdDataModel> obdData;
  List<SymptomModel> symptoms;
  int? timeseriesDataAdded;
  int? obdDataAdded;
  int? symptomsAdded;
}
