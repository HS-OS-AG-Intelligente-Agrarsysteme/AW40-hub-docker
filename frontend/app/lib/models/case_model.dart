import "package:aw40_hub_frontend/utils/utils.dart";

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
  List<dynamic> timeseriesData;
  List<dynamic> obdData;
  List<dynamic> symptoms;
}
