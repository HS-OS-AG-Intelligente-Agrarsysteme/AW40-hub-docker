import "package:aw40_hub_frontend/dtos/dtos.dart";
import "package:aw40_hub_frontend/models/models.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
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
  group("CaseUpdateDto primary constructor", () {
    final DateTime timeStamp = DateTime.utc(2021);
    const CaseOccasion occasion = CaseOccasion.unknown;
    const int milage = 100;
    const CaseStatus status = CaseStatus.closed;
    final CaseUpdateDto caseUpdateDto = CaseUpdateDto(
      timeStamp,
      occasion,
      milage,
      status,
    );
    test("correctly assigns timestamp", () {
      expect(caseUpdateDto.timestamp, timeStamp);
    });
    test("correctly assigns occasion", () {
      expect(caseUpdateDto.occasion, occasion);
    });
    test("correctly assigns milage", () {
      expect(caseUpdateDto.milage, milage);
    });
    test("correctly assigns status", () {
      expect(caseUpdateDto.status, status);
    });
  });
  group("CaseUpdateDto fromJson constructor", () {
    final DateTime timeStamp = DateTime.utc(2021);
    const CaseOccasion occasion = CaseOccasion.unknown;
    const int milage = 200;
    const CaseStatus status = CaseStatus.closed;
    final Map<String, dynamic> json = <String, dynamic>{
      "timestamp": timeStamp.toIso8601String(),
      "occasion": occasion.name,
      "milage": milage,
      "status": status.name,
    };
    final CaseUpdateDto caseUpdateDto = CaseUpdateDto.fromJson(json);
    test("correctly assigns timestamp", () {
      expect(caseUpdateDto.timestamp, timeStamp);
    });
    test("correctly assigns occasion", () {
      expect(caseUpdateDto.occasion, occasion);
    });
    test("correctly assigns milage", () {
      expect(caseUpdateDto.milage, milage);
    });
    test("correctly assigns status", () {
      expect(caseUpdateDto.status, status);
    });
  });
  group("CaseUpdateDto toJson method", () {
    final DateTime timeStamp = DateTime.utc(2021);
    const CaseOccasion occasion = CaseOccasion.unknown;
    const int milage = 300;
    const CaseStatus status = CaseStatus.open;
    final CaseUpdateDto caseUpdateDto = CaseUpdateDto(
      timeStamp,
      occasion,
      milage,
      status,
    );
    final Map<String, dynamic> json = caseUpdateDto.toJson();
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
  });
  group("DiagnosisDto primary constructor", () {
    const id = "test_id";
    final timeStamp = DateTime.utc(2021);
    const status = DiagnosisStatus.failed;
    const caseId = "some_case_id";
    const stateMachineLog = <dynamic>[1, 2, 3];
    final todos = <ActionDto>[ActionDto("1", "some action", "1", "2", "3")];
    final DiagnosisDto diagnosisDto = DiagnosisDto(
      id,
      timeStamp,
      status,
      caseId,
      stateMachineLog,
      todos,
    );
    test("correctly assigns id", () {
      expect(diagnosisDto.id, id);
    });
    test("correctly assigns timestamp", () {
      expect(diagnosisDto.timestamp, timeStamp);
    });
    test("correctly assigns status", () {
      expect(diagnosisDto.status, status);
    });
    test("correctly assigns caseId", () {
      expect(diagnosisDto.caseId, caseId);
    });
    test("correctly assigns stateMachineLog", () {
      expect(diagnosisDto.stateMachineLog, stateMachineLog);
    });
    test("correctly assigns todos", () {
      expect(diagnosisDto.todos, todos);
    });
  });
  group("DiagnosisDto fromJson constructor", () {
    const id = "test_id";
    final timeStamp = DateTime.utc(2021);
    const status = DiagnosisStatus.failed;
    const caseId = "some_case_id";
    const stateMachineLog = <dynamic>[1, 2, 3];
    final todos = <ActionDto>[ActionDto("1", "some action", "1", "2", "3")];
    final Map<String, dynamic> json = <String, dynamic>{
      "_id": id,
      "timestamp": timeStamp.toIso8601String(),
      "status": status.name,
      "case_id": caseId,
      "state_machine_log": stateMachineLog,
      "todos": todos.map((e) => e.toJson()).toList(),
    };
    final DiagnosisDto diagnosisDto = DiagnosisDto.fromJson(json);
    test("correctly assigns id", () {
      expect(diagnosisDto.id, id);
    });
    test("correctly assigns timestamp", () {
      expect(diagnosisDto.timestamp, timeStamp);
    });
    test("correctly assigns status", () {
      expect(diagnosisDto.status, status);
    });
    test("correctly assigns caseId", () {
      expect(diagnosisDto.caseId, caseId);
    });
    test("correctly assigns stateMachineLog", () {
      expect(diagnosisDto.stateMachineLog, stateMachineLog);
    });
    test("correctly assigns todos", () {
      expect(diagnosisDto.todos, isA<List<ActionDto>>());
    });
  });
  group("DiagnosisDto toJson method", () {
    const id = "test_id";
    final timeStamp = DateTime.utc(2021);
    const status = DiagnosisStatus.failed;
    const caseId = "some_case_id";
    const stateMachineLog = <dynamic>[1, 2, 3];
    final todos = <ActionDto>[ActionDto("1", "some action", "1", "2", "3")];
    final DiagnosisDto diagnosisDto = DiagnosisDto(
      id,
      timeStamp,
      status,
      caseId,
      stateMachineLog,
      todos,
    );
    final Map<String, dynamic> json = diagnosisDto.toJson();
    test("correctly assigns id", () {
      expect(json["_id"], id);
    });
    test("correctly assigns timestamp", () {
      expect(json["timestamp"], timeStamp.toIso8601String());
    });
    test("correctly assigns status", () {
      expect(json["status"], status.name);
    });
    test("correctly assigns caseId", () {
      expect(json["case_id"], caseId);
    });
    test("correctly assigns stateMachineLog", () {
      expect(json["state_machine_log"], stateMachineLog);
    });
    test("correctly assigns todos", () {
      expect(json["todos"], todos);
    });
  });
  group("DiagnosisDto toModel method", () {
    const id = "test_id";
    final timeStamp = DateTime.utc(2021);
    const status = DiagnosisStatus.failed;
    const caseId = "some_case_id";
    const stateMachineLog = <dynamic>[1, 2, 3];
    final actionDto = ActionDto("1", "some action", "1", "2", "3");
    final todoDtos = <ActionDto>[actionDto];
    final DiagnosisDto diagnosisDto = DiagnosisDto(
      id,
      timeStamp,
      status,
      caseId,
      stateMachineLog,
      todoDtos,
    );
    final DiagnosisModel diagnosisModel = diagnosisDto.toModel();
    test("correctly assigns id", () {
      expect(diagnosisModel.id, id);
    });
    test("correctly assigns timestamp", () {
      expect(diagnosisModel.timestamp, timeStamp);
    });
    test("correctly assigns status", () {
      expect(diagnosisModel.status, status);
    });
    test("correctly assigns caseId", () {
      expect(diagnosisModel.caseId, caseId);
    });
    test("correctly assigns stateMachineLog", () {
      expect(diagnosisModel.stateMachineLog, stateMachineLog);
    });
    test("correctly assigns todos", () {
      final List<ActionModel> todoModels =
          todoDtos.map((e) => e.toModel()).toList();
      assert(todoDtos.length == todoModels.length);

      for (var i = 0; i < todoDtos.length; i++) {
        final ActionDto todoDto = todoDtos[i];
        final ActionModel todoModel = todoModels[i];
        expect(todoModel.id, todoDto.id);
        expect(todoModel.instruction, todoDto.instruction);
        expect(todoModel.actionType, todoDto.actionType);
        expect(todoModel.dataType, todoDto.dataType);
        expect(todoModel.component, todoDto.component);
      }
    });
  });
  group("NewCaseDto primary constructor", () {
    const String vehicleVin = "12345678901234567";
    const String customerId = "some_customer_id";
    const CaseOccasion occasion = CaseOccasion.unknown;
    const int milage = 400;
    final NewCaseDto newCaseDto = NewCaseDto(
      vehicleVin,
      customerId,
      occasion,
      milage,
    );
    test("correctly assigns vehicleVin", () {
      expect(newCaseDto.vehicleVin, vehicleVin);
    });
    test("correctly assigns customerId", () {
      expect(newCaseDto.customerId, customerId);
    });
    test("correctly assigns occasion", () {
      expect(newCaseDto.occasion, occasion);
    });
    test("correctly assigns milage", () {
      expect(newCaseDto.milage, milage);
    });
  });
  group("NewCaseDto fromJson constructor", () {
    const String vehicleVin = "12345678901234567";
    const String customerId = "some.customer_id";
    const CaseOccasion occasion = CaseOccasion.unknown;
    const int milage = 500;
    final Map<String, dynamic> json = <String, dynamic>{
      "vehicle_vin": vehicleVin,
      "customer_id": customerId,
      "occasion": occasion.name,
      "milage": milage,
    };
    final NewCaseDto newCaseDto = NewCaseDto.fromJson(json);
    test("correctly assigns vehicleVin", () {
      expect(newCaseDto.vehicleVin, vehicleVin);
    });
    test("correctly assigns customerId", () {
      expect(newCaseDto.customerId, customerId);
    });
    test("correctly assigns occasion", () {
      expect(newCaseDto.occasion, occasion);
    });
    test("correctly assigns milage", () {
      expect(newCaseDto.milage, milage);
    });
  });
  group("NewCaseDto toJson method", () {
    const String vehicleVin = "12345678901234567";
    const String customerId = "some.customer_id";
    const CaseOccasion occasion = CaseOccasion.unknown;
    const int milage = 600;
    final NewCaseDto newCaseDto = NewCaseDto(
      vehicleVin,
      customerId,
      occasion,
      milage,
    );
    final Map<String, dynamic> json = newCaseDto.toJson();
    test("correctly assigns vehicleVin", () {
      expect(json["vehicle_vin"], vehicleVin);
    });
    test("correctly assigns customerId", () {
      expect(json["customer_id"], customerId);
    });
    test("correctly assigns occasion", () {
      expect(json["occasion"], occasion.name);
    });
    test("correctly assigns milage", () {
      expect(json["milage"], milage);
    });
  });
  group("NewSymptomDto primary constructor", () {
    const String component = "some_component";
    const SymptomLabel label = SymptomLabel.ok;
    final NewSymptomDto newSymptomDto = NewSymptomDto(
      component,
      label,
    );
    test("correctly assigns component", () {
      expect(newSymptomDto.component, component);
    });
    test("correctly assigns label", () {
      expect(newSymptomDto.label, label);
    });
  });
  group("NewSymptomDto fromJson constructor", () {
    final timestamp = DateTime.utc(2021).toIso8601String();
    const String component = "some_component";
    const SymptomLabel label = SymptomLabel.ok;
    final Map<String, dynamic> json = <String, dynamic>{
      "timestamp": timestamp,
      "component": component,
      "label": label.name,
    };
    final NewSymptomDto newSymptomDto = NewSymptomDto.fromJson(json);
    test("correctly assigns component", () {
      expect(newSymptomDto.component, component);
    });
    test("correctly assigns label", () {
      expect(newSymptomDto.label, label);
    });
  });
  group("NewSymptomDto toJson method", () {
    const String component = "some_component";
    const SymptomLabel label = SymptomLabel.ok;
    final NewSymptomDto newSymptomDto = NewSymptomDto(
      component,
      label,
    );
    final Map<String, dynamic> json = newSymptomDto.toJson();
    test("correctly assigns component", () {
      expect(json["component"], component);
    });
    test("correctly assigns label", () {
      expect(json["label"], label.name);
    });
  });
  group("NewOBDDataDto primary constructor", () {
    final obdSpecs = <dynamic>[1, 2, 3];
    final dtcs = <String>["some_component"];
    final NewOBDDataDto newOBDDataDto = NewOBDDataDto(
      obdSpecs,
      dtcs,
    );
    test("correctly assigns obdSpecs", () {
      expect(newOBDDataDto.obdSpecs, obdSpecs);
    });
    test("correctly assigns dtcs", () {
      expect(newOBDDataDto.dtcs, dtcs);
    });
  });
  group("NewTimeseriesDataDto fromJson constructor", () {
    const String component = "some_component";
    const TimeseriesDataLabel label = TimeseriesDataLabel.norm;
    const int samplingRate = 1;
    const int duration = 3;
    const TimeseriesType type = TimeseriesType.oscillogram;
    const dynamic deviceSpecs = 0;
    const signal = <String>["some_String", "3"];
    final Map<String, dynamic> json = <String, dynamic>{
      "component": component,
      "label": label.name,
      "sampling_rate": samplingRate,
      "duration": duration,
      "type": type.name,
      "device_specs": deviceSpecs,
      "signal": signal,
    };
    final NewTimeseriesDataDto newTimeseriesDataDto =
        NewTimeseriesDataDto.fromJson(json);
    test("correctly assigns component", () {
      expect(newTimeseriesDataDto.component, component);
    });
    test("correctly assigns label", () {
      expect(newTimeseriesDataDto.label, label);
    });
    test("correctly assigns samplingRate", () {
      expect(newTimeseriesDataDto.samplingRate, samplingRate);
    });
    test("correctly assigns duration", () {
      expect(newTimeseriesDataDto.duration, duration);
    });
    test("correctly assigns type", () {
      expect(newTimeseriesDataDto.type, type);
    });
    test("correctly assigns deviceSpecs", () {
      expect(newTimeseriesDataDto.deviceSpecs, deviceSpecs);
    });
    test("correctly assigns signal", () {
      expect(newTimeseriesDataDto.signal, signal);
    });
  });
  group("NewTimeseriesDataDto toJson method", () {
    const String component = "some_component";
    const TimeseriesDataLabel label = TimeseriesDataLabel.norm;
    const int samplingRate = 1;
    const int duration = 3;
    const TimeseriesType type = TimeseriesType.oscillogram;
    const dynamic deviceSpecs = 0;
    const signal = <String>["some_String", "3"];
    final NewTimeseriesDataDto newTimeseriesDataDto = NewTimeseriesDataDto(
      component,
      label,
      samplingRate,
      duration,
      type,
      deviceSpecs,
      signal,
    );
    final Map<String, dynamic> json = newTimeseriesDataDto.toJson();
    test("correctly assigns component", () {
      expect(json["component"], component);
    });
    test("correctly assigns label", () {
      expect(json["label"], label.name);
    });
    test("correctly assigns samplingRate", () {
      expect(json["sampling_rate"], samplingRate);
    });
    test("correctly assigns duration", () {
      expect(json["duration"], duration);
    });
    test("correctly assigns type", () {
      expect(json["type"], type.name);
    });
    test("correctly assigns deviceSpecs", () {
      expect(json["device_specs"], deviceSpecs);
    });
    test("correctly assigns signal", () {
      expect(json["signal"], signal);
    });
  });
  group("NewOBDDataDto fromJson constructor", () {
    final timestamp = DateTime.utc(2021).toIso8601String();
    final obdSpecs = <dynamic>[1, 2, 3];
    final dtcs = <String>["some_component"];
    final Map<String, dynamic> json = <String, dynamic>{
      "timestamp": timestamp,
      "obd_specs": obdSpecs,
      "dtcs": dtcs,
    };
    final NewOBDDataDto newOBDDataDto = NewOBDDataDto.fromJson(json);
    test("correctly assigns obdSpecs", () {
      expect(newOBDDataDto.obdSpecs, obdSpecs);
    });
    test("correctly assigns dtcs", () {
      expect(newOBDDataDto.dtcs, dtcs);
    });
  });
  group("NewOBDDataDto toJson method", () {
    final obdSpecs = <dynamic>[1, 2, 3];
    final dtcs = <String>["some_component"];
    final NewOBDDataDto newOBDDataDto = NewOBDDataDto(
      obdSpecs,
      dtcs,
    );
    final Map<String, dynamic> json = newOBDDataDto.toJson();
    test("correctly assigns dtcs", () {
      expect(json["obd_specs"], obdSpecs);
    });
    test("correctly assigns dtcs", () {
      expect(json["dtcs"], dtcs);
    });
  });
  group("ActionDto primary constructor", () {
    const String id = "some_id";
    const String instruction = "some_customer_id";
    const String actionType = "some_action_type";
    const String dataType = "some_data_type";
    const String component = "some_component";
    final ActionDto actionDto = ActionDto(
      id,
      instruction,
      actionType,
      dataType,
      component,
    );
    test("correctly assigns id", () {
      expect(actionDto.id, id);
    });
    test("correctly assigns instruction", () {
      expect(actionDto.instruction, instruction);
    });
    test("correctly assigns actionType", () {
      expect(actionDto.actionType, actionType);
    });
    test("correctly assigns dataType", () {
      expect(actionDto.dataType, dataType);
    });
    test("correctly assigns component", () {
      expect(actionDto.component, component);
    });
  });
  group("ActionDto fromJson constructor", () {
    const String id = "some_id";
    const String instruction = "some_customer_id";
    const String actionType = "some_action_type";
    const String dataType = "some_data_type";
    const String component = "some_component";
    final Map<String, dynamic> json = <String, dynamic>{
      "id": id,
      "instruction": instruction,
      "action_type": actionType,
      "data_type": dataType,
      "component": component,
    };
    final ActionDto actionDto = ActionDto.fromJson(json);
    test("correctly assigns id", () {
      expect(actionDto.id, id);
    });
    test("correctly assigns instruction", () {
      expect(actionDto.instruction, instruction);
    });
    test("correctly assigns actionType", () {
      expect(actionDto.actionType, actionType);
    });
    test("correctly assigns dataType", () {
      expect(actionDto.dataType, dataType);
    });
    test("correctly assigns component", () {
      expect(actionDto.component, component);
    });
  });
  group("ActionDto toJson method", () {
    const String id = "some_id";
    const String instruction = "some_customer_id";
    const String actionType = "some_action_type";
    const String dataType = "some_data_type";
    const String component = "some_component";
    final ActionDto actionDto = ActionDto(
      id,
      instruction,
      actionType,
      dataType,
      component,
    );
    final Map<String, dynamic> json = actionDto.toJson();
    test("correctly assigns id", () {
      expect(json["id"], id);
    });
    test("correctly assigns instruction", () {
      expect(json["instruction"], instruction);
    });
    test("correctly assigns actionType", () {
      expect(json["action_type"], actionType);
    });
    test("correctly assigns dataType", () {
      expect(json["data_type"], dataType);
    });
    test("correctly assigns component", () {
      expect(json["component"], component);
    });
  });
  group("ActionDto toModel method", () {
    const String id = "some_id";
    const String instruction = "some_customer_id";
    const String actionType = "some_action_type";
    const String dataType = "some_data_type";
    const String component = "some_component";
    final ActionDto actionDto = ActionDto(
      id,
      instruction,
      actionType,
      dataType,
      component,
    );
    final ActionModel actionModel = actionDto.toModel();
    test("correctly assigns id", () {
      expect(actionModel.id, id);
    });
    test("correctly assigns instruction", () {
      expect(actionModel.instruction, instruction);
    });
    test("correctly assigns actionType", () {
      expect(actionModel.actionType, actionType);
    });
    test("correctly assigns dataType", () {
      expect(actionModel.dataType, dataType);
    });
    test("correctly assigns component", () {
      expect(actionModel.component, component);
    });
  });
  group("ObdDataDto fromJson constructor", () {
    final timestamp = DateTime.utc(2021);
    final obdSpecs = <dynamic>[1, 2, 3];
    final dtcs = <String>["some_component"];
    const int dataId = 0;
    final Map<String, dynamic> json = <String, dynamic>{
      "timestamp": timestamp.toIso8601String(),
      "obd_specs": obdSpecs,
      "dtcs": dtcs,
      "data_id": dataId,
    };
    final ObdDataDto obdDataDto = ObdDataDto.fromJson(json);
    test("correctly assigns timestamp", () {
      expect(obdDataDto.timestamp, timestamp);
    });
    test("correctly assigns obdSpecs", () {
      expect(obdDataDto.obdSpecs, obdSpecs);
    });
    test("correctly assigns dtcs", () {
      expect(obdDataDto.dtcs, dtcs);
    });
    test("correctly assigns dataId", () {
      expect(obdDataDto.dataId, dataId);
    });
  });
  group("ObdDataDto toJson method", () {
    final timestamp = DateTime.utc(2021);
    final obdSpecs = <dynamic>[1, 2, 3];
    final dtcs = <String>["some_component"];
    const int dataId = 0;
    final ObdDataDto obdDataDto = ObdDataDto(
      timestamp,
      obdSpecs,
      dtcs,
      dataId,
    );
    final Map<String, dynamic> json = obdDataDto.toJson();
    test("correctly assigns timestamp", () {
      expect(json["timestamp"], timestamp.toIso8601String());
    });
    test("correctly assigns obdSpecs", () {
      expect(json["obd_specs"], obdSpecs);
    });
    test("correctly assigns dtcs", () {
      expect(json["dtcs"], dtcs);
    });
    test("correctly assigns dataId", () {
      expect(json["data_id"], dataId);
    });
  });
  group("ObdDataDto toModel method", () {
    final timestamp = DateTime.utc(2021);
    final obdSpecs = <dynamic>[1, 2, 3];
    final dtcs = <String>["some_component"];
    const int dataId = 0;
    final ObdDataDto obdDataDto = ObdDataDto(
      timestamp,
      obdSpecs,
      dtcs,
      dataId,
    );
    final ObdDataModel obdDataModel = obdDataDto.toModel();
    test("correctly assigns timestamp", () {
      expect(obdDataModel.timestamp, timestamp);
    });
    test("correctly assigns obdSpecs", () {
      expect(obdDataModel.obdSpecs, obdSpecs);
    });
    test("correctly assigns dtcs", () {
      expect(obdDataModel.dtcs, dtcs);
    });
    test("correctly assigns dataId", () {
      expect(obdDataModel.dataId, dataId);
    });
  });
  group("TimeseriesDataDto fromJson constructor", () {
    final timestamp = DateTime.utc(2021);
    const String component = "some_component";
    const TimeseriesDataLabel label = TimeseriesDataLabel.norm;
    const int samplingRate = 1;
    const int duration = 3;
    const TimeseriesType type = TimeseriesType.oscillogram;
    const dynamic deviceSpecs = 0;
    const int dataId = 5;
    const signalId = "some_string";
    final Map<String, dynamic> json = <String, dynamic>{
      "timestamp": timestamp.toIso8601String(),
      "component": component,
      "label": label.name,
      "sampling_rate": samplingRate,
      "duration": duration,
      "type": type.name,
      "device_specs": deviceSpecs,
      "data_id": dataId,
      "signal_id": signalId,
    };
    final TimeseriesDataDto timeseriesDataDto =
        TimeseriesDataDto.fromJson(json);
    test("correctly assigns timestamp", () {
      expect(timeseriesDataDto.timestamp, timestamp);
    });
    test("correctly assigns component", () {
      expect(timeseriesDataDto.component, component);
    });
    test("correctly assigns label", () {
      expect(timeseriesDataDto.label, label);
    });
    test("correctly assigns samplingRate", () {
      expect(timeseriesDataDto.samplingRate, samplingRate);
    });
    test("correctly assigns duration", () {
      expect(timeseriesDataDto.duration, duration);
    });
    test("correctly assigns type", () {
      expect(timeseriesDataDto.type, type);
    });
    test("correctly assigns deviceSpecs", () {
      expect(timeseriesDataDto.deviceSpecs, deviceSpecs);
    });
    test("correctly assigns dataId", () {
      expect(timeseriesDataDto.dataId, dataId);
    });
    test("correctly assigns signalId", () {
      expect(timeseriesDataDto.signalId, signalId);
    });
  });
  group("TimeseriesDataDto toJson method", () {
    final timestamp = DateTime.utc(2021);
    const String component = "some_component";
    const TimeseriesDataLabel label = TimeseriesDataLabel.norm;
    const int samplingRate = 1;
    const int duration = 3;
    const TimeseriesType type = TimeseriesType.oscillogram;
    const dynamic deviceSpecs = 0;
    const int dataId = 5;
    const signalId = "some_String";
    final TimeseriesDataDto timeseriesDataDto = TimeseriesDataDto(
      timestamp,
      component,
      label,
      samplingRate,
      duration,
      type,
      deviceSpecs,
      dataId,
      signalId,
    );
    final Map<String, dynamic> json = timeseriesDataDto.toJson();
    test("correctly assigns timestamp", () {
      expect(json["timestamp"], timestamp.toIso8601String());
    });
    test("correctly assigns component", () {
      expect(json["component"], component);
    });
    test("correctly assigns label", () {
      expect(json["label"], label.name);
    });
    test("correctly assigns samplingRate", () {
      expect(json["sampling_rate"], samplingRate);
    });
    test("correctly assigns duration", () {
      expect(json["duration"], duration);
    });
    test("correctly assigns type", () {
      expect(json["type"], type.name);
    });
    test("correctly assigns deviceSpecs", () {
      expect(json["device_specs"], deviceSpecs);
    });
    test("correctly assigns dataId", () {
      expect(json["data_id"], dataId);
    });
    test("correctly assigns signalId", () {
      expect(json["signal_id"], signalId);
    });
  });
  group("TimeseriesDataDto toModel method", () {
    final timestamp = DateTime.utc(2021);
    const String component = "some_component";
    const TimeseriesDataLabel label = TimeseriesDataLabel.norm;
    const int samplingRate = 1;
    const int duration = 3;
    const TimeseriesType type = TimeseriesType.oscillogram;
    const dynamic deviceSpecs = 0;
    const int dataId = 5;
    const signalId = "some_String";
    final TimeseriesDataDto timeseriesDataDto = TimeseriesDataDto(
      timestamp,
      component,
      label,
      samplingRate,
      duration,
      type,
      deviceSpecs,
      dataId,
      signalId,
    );
    final TimeseriesDataModel timeseriesDataModel = timeseriesDataDto.toModel();
    test("correctly assigns timestamp", () {
      expect(timeseriesDataModel.timestamp, timestamp);
    });
    test("correctly assigns component", () {
      expect(timeseriesDataModel.component, component);
    });
    test("correctly assigns label", () {
      expect(timeseriesDataModel.label, label);
    });
    test("correctly assigns samplingRate", () {
      expect(timeseriesDataModel.samplingRate, samplingRate);
    });
    test("correctly assigns duration", () {
      expect(timeseriesDataModel.duration, duration);
    });
    test("correctly assigns type", () {
      expect(timeseriesDataModel.type, type);
    });
    test("correctly assigns deviceSpecs", () {
      expect(timeseriesDataModel.deviceSpecs, deviceSpecs);
    });
    test("correctly assigns dataId", () {
      expect(timeseriesDataModel.dataId, dataId);
    });
    test("correctly assigns signalId", () {
      expect(timeseriesDataModel.signalId, signalId);
    });
  });
  group("SymptomDto fromJson constructor", () {
    final timestamp = DateTime.utc(2021);
    const String component = "some_component";
    const SymptomLabel label = SymptomLabel.unknown;
    const int dataId = 2;
    final Map<String, dynamic> json = <String, dynamic>{
      "timestamp": timestamp.toIso8601String(),
      "component": component,
      "label": label.name,
      "data_id": dataId,
    };
    final SymptomDto symptomDto = SymptomDto.fromJson(json);
    test("correctly assigns timestamp", () {
      expect(symptomDto.timestamp, timestamp);
    });
    test("correctly assigns component", () {
      expect(symptomDto.component, component);
    });
    test("correctly assigns label", () {
      expect(symptomDto.label, label);
    });
    test("correctly assigns dataId", () {
      expect(symptomDto.dataId, dataId);
    });
  });
  group("SymptomDto toJson method", () {
    final timestamp = DateTime.utc(2021);
    const String component = "some_component";
    const SymptomLabel label = SymptomLabel.unknown;
    const int dataId = 2;
    final SymptomDto symptomDto = SymptomDto(
      timestamp,
      component,
      label,
      dataId,
    );
    final Map<String, dynamic> json = symptomDto.toJson();
    test("correctly assigns timestamp", () {
      expect(json["timestamp"], timestamp.toIso8601String());
    });
    test("correctly assigns component", () {
      expect(json["component"], component);
    });
    test("correctly assigns label", () {
      expect(json["label"], label.name);
    });
    test("correctly assigns dataId", () {
      expect(json["data_id"], dataId);
    });
  });
  group("SymptomDto toModel method", () {
    final timestamp = DateTime.utc(2021);
    const String component = "some_component";
    const SymptomLabel label = SymptomLabel.unknown;
    const int dataId = 2;
    final SymptomDto symptomDto = SymptomDto(
      timestamp,
      component,
      label,
      dataId,
    );
    final SymptomModel symptomModel = symptomDto.toModel();
    test("correctly assigns timestamp", () {
      expect(symptomModel.timestamp, timestamp);
    });
    test("correctly assigns component", () {
      expect(symptomModel.component, component);
    });
    test("correctly assigns label", () {
      expect(symptomModel.label, label);
    });
    test("correctly assigns dataId", () {
      expect(symptomModel.dataId, dataId);
    });
  });
}
