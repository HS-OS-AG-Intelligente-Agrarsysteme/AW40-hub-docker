import "package:enum_to_string/enum_to_string.dart";
import "package:logging/logging.dart";

enum AuthorizedGroup {
  // ignore: constant_identifier_names
  Analysts,
  // ignore: constant_identifier_names
  Mechanics,
}

enum ExceptionType { notFound, unexpectedNullValue, other, unknown }

enum HostPlatform { web, android, ios, windows, linux, macos }

enum TokenType { jwt, refresh, id }

enum ConfigKey {
  // Note: Always do this in alphabetical order. Unit tests for ConfigService
  // are relying on it.
  apiAddress,
  frontendAddress,
  keyCloakAddress,
  keyCloakClient,
  keyCloakRealm,
  logLevel,
  proxyDefaultScheme,
  redirectUriMobile,
  useMockData,
}

enum LocalStorageKey { verifier, redirectUri, refreshToken }

enum CaseOccasion {
  unknown,
  // ignore: constant_identifier_names
  service_routine,
  // ignore: constant_identifier_names
  problem_defect,
}

enum CaseStatus { open, closed }

// Order determines sort order ascending from action required onwards
enum DiagnosisStatus {
  // ignore: constant_identifier_names
  action_required,
  scheduled,
  processing,
  finished,
  failed,
}

enum NavigationType { internal, external }

enum SymptomLabel { unknown, ok, defect }

enum TimeseriesDataLabel { unknown, norm, anomaly }

enum DatasetType {
  obd,
  timeseries,
  symptom,
  unknown;

  factory DatasetType.fromJson(String value) {
    final DatasetType? result =
        EnumToString.fromString(DatasetType.values, value);
    if (result == null) {
      Logger("DatasetType").warning("Unknown DatasetType: $value");
      return DatasetType.unknown;
    }
    return result;
  }
}

enum PicoscopeLabel { unknown, norm, anomaly }

enum TimeseriesType { oscillogram }

enum StateMachineEvent {
  stateTransition,
  retrievedDataSet,
  heatmaps,
  causalGraphVisualizations,
  faultPaths,
  diagnosisFailed,
  unknown,
}

enum ObdFormat { obd, vcds }

enum TimeseriesFormat { timeseries, omniview, picoscope }
