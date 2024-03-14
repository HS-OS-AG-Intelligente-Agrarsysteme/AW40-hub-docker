enum AuthorizedGroup {
  // ignore: constant_identifier_names
  Analysts,
  // ignore: constant_identifier_names
  Mechanics,
}

enum ExceptionType {
  notFound,
  unexpectedNullValue,
  other,
  unknown,
}

enum HostPlatform {
  web,
  android,
  ios,
  windows,
  linux,
  macos,
}

enum TokenType {
  jwt,
  refresh,
  id,
}

enum ConfigKey {
  apiAddress,
  frontendAddress,
  keyCloakAddress,
  keyCloakClient,
  keyCloakRealm,
  logLevel,
  redirectUriMobile,
  proxyDefaultScheme,
}

enum LocalStorageKey {
  verifier,
  redirectUri,
  refreshToken,
}

enum CaseOccasion {
  unknown,
  // ignore: constant_identifier_names
  service_routine,
  // ignore: constant_identifier_names
  problem_defect,
}

enum CaseStatus {
  open,
  closed,
}

// Order determines sort order ascending from action required onwards
enum DiagnosisStatus {
  // ignore: constant_identifier_names
  action_required,
  scheduled,
  processing,
  finished,
  failed,
}

enum NavigationType {
  internal,
  external,
}

enum SymptomLabel {
  unknown,
  ok,
  defect,
}
