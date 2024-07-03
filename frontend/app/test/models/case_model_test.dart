import "package:aw40_hub_frontend/models/case_model.dart";
import "package:aw40_hub_frontend/models/obd_data_model.dart";
import "package:aw40_hub_frontend/models/symptom_model.dart";
import "package:aw40_hub_frontend/models/timeseries_data_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("CaseModel", () {
    const id = "test_id";
    final timestamp = DateTime.now();
    const occasion = CaseOccasion.unknown;
    const milage = 100;
    const status = CaseStatus.closed;
    const customerId = "some_customer_id";
    const vehicleVin = "12345678901234567";
    const workshopId = "some_workshop_id";
    const diagnosisId = "some_diagnosis_id";
    final timeseriesData = <TimeseriesDataModel>[
      TimeseriesDataModel(
        timestamp: DateTime.utc(2021),
        component: "some_component",
        label: TimeseriesDataLabel.norm,
        samplingRate: 1,
        duration: 3,
        type: TimeseriesType.oscillogram,
        deviceSpecs: 0,
        dataId: 2,
        signalId: "some_string",
      )
    ];
    final obdData = <ObdDataModel>[
      ObdDataModel(
        timestamp: DateTime.utc(2021),
        obdSpecs: <dynamic>[1, 2, 3],
        dtcs: <String>["some_component"],
        dataId: 0,
      )
    ];
    final symptoms = <SymptomModel>[
      SymptomModel(
        timestamp: DateTime.utc(2021),
        component: "some_component",
        label: SymptomLabel.unknown,
        dataId: 2,
      )
    ];
    const timeseriesDataAdded = 3;
    const obdDataAdded = 5;
    const symptomsAdded = 4;

    final caseModel = CaseModel(
      id: id,
      timestamp: timestamp,
      occasion: occasion,
      milage: milage,
      status: status,
      customerId: customerId,
      vehicleVin: vehicleVin,
      workshopId: workshopId,
      diagnosisId: diagnosisId,
      timeseriesData: timeseriesData,
      obdData: obdData,
      symptoms: symptoms,
      timeseriesDataAdded: timeseriesDataAdded,
      obdDataAdded: obdDataAdded,
      symptomsAdded: symptomsAdded,
    );
    test("correctly assigns id", () {
      expect(caseModel.id, id);
    });
    test("correctly assigns timestamp", () {
      expect(caseModel.timestamp, timestamp);
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
      expect(caseModel.timeseriesData, timeseriesData);
    });
    test("correctly assigns obdData", () {
      expect(caseModel.obdData, obdData);
    });
    test("correctly assigns symptoms", () {
      expect(caseModel.symptoms, symptoms);
    });
    test("correctly assigns timeseriesDataAdded", () {
      expect(caseModel.timeseriesDataAdded, timeseriesDataAdded);
    });
    test("correctly assigns obdDataAdded", () {
      expect(caseModel.obdDataAdded, obdDataAdded);
    });
    test("correctly assigns symptomsAdded", () {
      expect(caseModel.symptomsAdded, symptomsAdded);
    });
  });
}
