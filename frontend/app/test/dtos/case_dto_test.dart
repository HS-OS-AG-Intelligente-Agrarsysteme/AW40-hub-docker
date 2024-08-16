import "package:aw40_hub_frontend/dtos/case_dto.dart";
import "package:aw40_hub_frontend/dtos/obd_data_dto.dart";
import "package:aw40_hub_frontend/dtos/symptom_dto.dart";
import "package:aw40_hub_frontend/dtos/timeseries_data_dto.dart";
import "package:aw40_hub_frontend/models/case_model.dart";
import "package:aw40_hub_frontend/models/obd_data_model.dart";
import "package:aw40_hub_frontend/models/symptom_model.dart";
import "package:aw40_hub_frontend/models/timeseries_data_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("CaseDto primary constructor", () {
    const id = "test_id";
    final timeStamp = DateTime.utc(2021);
    const occasion = CaseOccasion.unknown;
    const milage = 100;
    const status = CaseStatus.closed;
    const customerId = "some_customer_id";
    const vehicleVin = "12345678901234567";
    const workshopId = "some_workshop_id";
    const diagnosisId = "some_diagnosis_id";
    final timeseriesData = <TimeseriesDataDto>[
      TimeseriesDataDto(
        DateTime.utc(2021),
        "some_component",
        TimeseriesDataLabel.norm,
        1,
        3,
        TimeseriesType.oscillogram,
        0,
        2,
        "some_String",
      )
    ];
    final obdData = <ObdDataDto>[
      ObdDataDto(
        DateTime.utc(2021),
        <dynamic>[1, 2, 3],
        <String>["some_component"],
        0,
      )
    ];
    final symptoms = <SymptomDto>[
      SymptomDto(
        DateTime.utc(2021),
        "some_component",
        SymptomLabel.unknown,
        2,
      )
    ];
    const timeseriesDataAdded = 8;
    const obdDataAdded = 5;
    const symptomsAdded = 9;
    final CaseDto caseDto = CaseDto(
      id,
      timeStamp,
      occasion,
      milage,
      status,
      customerId,
      vehicleVin,
      workshopId,
      diagnosisId,
      timeseriesData,
      obdData,
      symptoms,
      timeseriesDataAdded,
      obdDataAdded,
      symptomsAdded,
    );
    test("correctly assigns id", () {
      expect(caseDto.id, id);
    });
    test("correctly assigns timestamp", () {
      expect(caseDto.timestamp, timeStamp);
    });
    test("correctly assigns occasion", () {
      expect(caseDto.occasion, occasion);
    });
    test("correctly assigns milage", () {
      expect(caseDto.milage, milage);
    });
    test("correctly assigns status", () {
      expect(caseDto.status, status);
    });
    test("correctly assigns customerId", () {
      expect(caseDto.customerId, customerId);
    });
    test("correctly assigns vehicleVin", () {
      expect(caseDto.vehicleVin, vehicleVin);
    });
    test("correctly assigns workshopId", () {
      expect(caseDto.workshopId, workshopId);
    });
    test("correctly assigns diagnosisId", () {
      expect(caseDto.diagnosisId, diagnosisId);
    });
    test("correctly assigns timeseriesData", () {
      expect(caseDto.timeseriesData, timeseriesData);
    });
    test("correctly assigns obdData", () {
      expect(caseDto.obdData, obdData);
    });
    test("correctly assigns symptoms", () {
      expect(caseDto.symptoms, symptoms);
    });
    test("correctly assigns timeseriesDataAdded", () {
      expect(caseDto.timeseriesDataAdded, timeseriesDataAdded);
    });
    test("correctly assigns obdDataAdded", () {
      expect(caseDto.obdDataAdded, obdDataAdded);
    });
    test("correctly assigns symptomsAdded", () {
      expect(caseDto.symptomsAdded, symptomsAdded);
    });
  });
  group("CaseDto fromJson constructor", () {
    const id = "test_id";
    final timeStamp = DateTime.utc(2021);
    const occasion = CaseOccasion.unknown;
    const milage = 100;
    const status = CaseStatus.closed;
    const customerId = "some_customer_id";
    const vehicleVin = "12345678901234567";
    const workshopId = "some_workshop_id";
    const diagnosisId = "some_diagnosis_id";
    final timeseriesData = <TimeseriesDataDto>[
      TimeseriesDataDto(
        DateTime.utc(2021),
        "some_component",
        TimeseriesDataLabel.norm,
        1,
        3,
        TimeseriesType.oscillogram,
        0,
        2,
        "some_string",
      )
    ];
    final obdData = <ObdDataDto>[
      ObdDataDto(
        DateTime.utc(2021),
        <dynamic>[1, 2, 3],
        <String>["some_component"],
        0,
      )
    ];
    final symptoms = <SymptomDto>[
      SymptomDto(
        DateTime.utc(2021),
        "some_component",
        SymptomLabel.unknown,
        2,
      )
    ];
    const timeseriesDataAdded = 8;
    const obdDataAdded = 5;
    const symptomsAdded = 9;
    final Map<String, dynamic> json = <String, dynamic>{
      "_id": id,
      "timestamp": timeStamp.toIso8601String(),
      "occasion": occasion.name,
      "milage": milage,
      "status": status.name,
      "customer_id": customerId,
      "vehicle_vin": vehicleVin,
      "workshop_id": workshopId,
      "diagnosis_id": diagnosisId,
      "timeseries_data": timeseriesData.map((e) => e.toJson()).toList(),
      "obd_data": obdData.map((e) => e.toJson()).toList(),
      "symptoms": symptoms.map((e) => e.toJson()).toList(),
      "timeseries_data_added": timeseriesDataAdded,
      "obd_data_added": obdDataAdded,
      "symptoms_added": symptomsAdded,
    };
    final CaseDto caseDto = CaseDto.fromJson(json);
    test("correctly assigns id", () {
      expect(caseDto.id, id);
    });
    test("correctly assigns timestamp", () {
      expect(caseDto.timestamp, timeStamp);
    });
    test("correctly assigns occasion", () {
      expect(caseDto.occasion, occasion);
    });
    test("correctly assigns milage", () {
      expect(caseDto.milage, milage);
    });
    test("correctly assigns status", () {
      expect(caseDto.status, status);
    });
    test("correctly assigns customerId", () {
      expect(caseDto.customerId, customerId);
    });
    test("correctly assigns vehicleVin", () {
      expect(caseDto.vehicleVin, vehicleVin);
    });
    test("correctly assigns workshopId", () {
      expect(caseDto.workshopId, workshopId);
    });
    test("correctly assigns diagnosisId", () {
      expect(caseDto.diagnosisId, diagnosisId);
    });
    test("correctly assigns timeseriesData", () {
      expect(caseDto.timeseriesData, isA<List<TimeseriesDataDto>>());
    });
    test("correctly assigns obdData", () {
      expect(caseDto.obdData, isA<List<ObdDataDto>>());
    });
    test("correctly assigns symptoms", () {
      expect(caseDto.symptoms, isA<List<SymptomDto>>());
    });
    test("correctly assigns timeseriesDataAdded", () {
      expect(caseDto.timeseriesDataAdded, timeseriesDataAdded);
    });
    test("correctly assigns obdDataAdded", () {
      expect(caseDto.obdDataAdded, obdDataAdded);
    });
    test("correctly assigns symptomsAdded", () {
      expect(caseDto.symptomsAdded, symptomsAdded);
    });
  });
  group("CaseDto toJson method", () {
    const id = "test_id";
    final timeStamp = DateTime.utc(2021);
    const occasion = CaseOccasion.unknown;
    const milage = 100;
    const status = CaseStatus.closed;
    const customerId = "some_customer_id";
    const vehicleVin = "12345678901234567";
    const workshopId = "some_workshop_id";
    const diagnosisId = "some_diagnosis_id";
    final timeseriesData = <TimeseriesDataDto>[
      TimeseriesDataDto(
        DateTime.utc(2021),
        "some_component",
        TimeseriesDataLabel.norm,
        1,
        3,
        TimeseriesType.oscillogram,
        0,
        2,
        "some_string",
      )
    ];
    final obdData = <ObdDataDto>[
      ObdDataDto(
        DateTime.utc(2021),
        <dynamic>[1, 2, 3],
        <String>["some_component"],
        0,
      )
    ];
    final symptoms = <SymptomDto>[
      SymptomDto(
        DateTime.utc(2021),
        "some_component",
        SymptomLabel.unknown,
        2,
      )
    ];
    const timeseriesDataAdded = 8;
    const obdDataAdded = 5;
    const symptomsAdded = 9;
    final CaseDto caseDto = CaseDto(
      id,
      timeStamp,
      occasion,
      milage,
      status,
      customerId,
      vehicleVin,
      workshopId,
      diagnosisId,
      timeseriesData,
      obdData,
      symptoms,
      timeseriesDataAdded,
      obdDataAdded,
      symptomsAdded,
    );
    final Map<String, dynamic> json = caseDto.toJson();
    test("correctly assigns id", () {
      expect(json["_id"], id);
    });
    test("correctly assigns timestamp", () {
      expect(json["timestamp"], timeStamp.toIso8601String());
    });
    test("correctly assigns occasion", () {
      expect(json["occasion"], occasion.name);
    });
    test("correctly assigns milage", () {
      expect(json["milage"], milage);
    });
    test("correctly assigns status", () {
      expect(json["status"], status.name);
    });
    test("correctly assigns customerId", () {
      expect(json["customer_id"], customerId);
    });
    test("correctly assigns vehicleVin", () {
      expect(json["vehicle_vin"], vehicleVin);
    });
    test("correctly assigns workshopId", () {
      expect(json["workshop_id"], workshopId);
    });
    test("correctly assigns diagnosisId", () {
      expect(json["diagnosis_id"], diagnosisId);
    });
    test("correctly assigns timeseriesData", () {
      expect(json["timeseries_data"], timeseriesData);
    });
    test("correctly assigns obdData", () {
      expect(json["obd_data"], obdData);
    });
    test("correctly assigns symptoms", () {
      expect(json["symptoms"], symptoms);
    });
    test("correctly assigns timeseriesDataAdded", () {
      expect(json["timeseries_data_added"], timeseriesDataAdded);
    });
    test("correctly assigns obdDataAdded", () {
      expect(json["obd_data_added"], obdDataAdded);
    });
    test("correctly assigns symptomsAdded", () {
      expect(json["symptoms_added"], symptomsAdded);
    });
  });
  group("CaseDto toModel method", () {
    const id = "test_id";
    final timeStamp = DateTime.utc(2021);
    const occasion = CaseOccasion.unknown;
    const milage = 100;
    const status = CaseStatus.closed;
    const customerId = "some_customer_id";
    const vehicleVin = "12345678901234567";
    const workshopId = "some_workshop_id";
    const diagnosisId = "some_diagnosis_id";
    final timeseriesData = <TimeseriesDataDto>[
      TimeseriesDataDto(
        DateTime.utc(2021),
        "some_component",
        TimeseriesDataLabel.norm,
        1,
        3,
        TimeseriesType.oscillogram,
        0,
        2,
        "some_string",
      )
    ];
    final obdData = <ObdDataDto>[
      ObdDataDto(
        DateTime.utc(2021),
        <dynamic>[1, 2, 3],
        <String>["some_component"],
        0,
      )
    ];
    final symptoms = <SymptomDto>[
      SymptomDto(
        DateTime.utc(2021),
        "some_component",
        SymptomLabel.unknown,
        2,
      )
    ];
    const timeseriesDataAdded = 8;
    const obdDataAdded = 5;
    const symptomsAdded = 9;
    final CaseDto caseDto = CaseDto(
      id,
      timeStamp,
      occasion,
      milage,
      status,
      customerId,
      vehicleVin,
      workshopId,
      diagnosisId,
      timeseriesData,
      obdData,
      symptoms,
      timeseriesDataAdded,
      obdDataAdded,
      symptomsAdded,
    );
    final CaseModel caseModel = caseDto.toModel();
    test("correctly assigns id", () {
      expect(caseModel.id, id);
    });
    test("correctly assigns timestamp", () {
      expect(caseModel.timestamp, timeStamp);
    });
    test("correctly assigns occasion", () {
      expect(caseModel.occasion, occasion);
    });
    test("correctly assigns milage", () {
      expect(caseModel.milage, milage);
    });
    test("correctly assigns status", () {
      expect(caseModel.status, status);
    });
    test("correctly assigns customerId", () {
      expect(caseModel.customerId, customerId);
    });
    test("correctly assigns vehicleVin", () {
      expect(caseModel.vehicleVin, vehicleVin);
    });
    test("correctly assigns workshopId", () {
      expect(caseModel.workshopId, workshopId);
    });
    test("correctly assigns diagnosisId", () {
      expect(caseModel.diagnosisId, diagnosisId);
    });
    test("correctly assigns timeseriesData", () {
      expect(caseModel.timeseriesData, isA<List<TimeseriesDataModel>>());
    });
    test("correctly assigns obdData", () {
      expect(caseModel.obdData, isA<List<ObdDataModel>>());
    });
    test("correctly assigns symptoms", () {
      expect(caseModel.symptoms, isA<List<SymptomModel>>());
    });
  });
}
