import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/services/config_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:collection/collection.dart";
import "package:flutter_test/flutter_test.dart";
import "package:logging/logging.dart";

void main() {
  group("ConfigService", () {
    final ConfigService configService = ConfigService();
    setUp(configService.reset);
    test("should be Singleton", () {
      final ConfigService configService1 = ConfigService();
      final ConfigService configService2 = ConfigService();
      expect(identical(configService1, configService2), true);
    });
    test("logValues() logs once for each ConfigKey", () async {
      final Logger testLogger = Logger("test_logger");
      final logRecords = <LogRecord>[];
      testLogger.onRecord.listen(logRecords.add);
      configService.logValues();
      expect(logRecords.length, ConfigKey.values.length);
    });
    test("logValues() logs in order of ConfigKeys", () async {
      final Logger testLogger = Logger("test_logger");
      final logRecords = <LogRecord>[];
      testLogger.onRecord.listen(logRecords.add);
      configService.logValues();
      ConfigKey.values.forEachIndexed((i, k) {
        expect(
          logRecords[i].message,
          contains(k.name),
          reason: "${i}th key should contain ${k.name},"
              " but was '${logRecords[i].message}'",
        );
      });
    });
    test("_configMap is empty before calling initialize()", () {
      final Logger testLogger = Logger("test_logger");
      final logRecords = <LogRecord>[];
      testLogger.onRecord.listen(logRecords.add);

      configService.logValues();

      ConfigKey.values.forEachIndexed((i, k) {
        expect(
          logRecords[i].message,
          contains("not found"),
          reason: "key $k should not be in _configMap, but was found",
        );
      });
    });
    test("_configMap is populated after calling initialize()", () async {
      final Logger testLogger = Logger("test_logger");
      final logRecords = <LogRecord>[];
      testLogger.onRecord.listen(logRecords.add);

      await configService.initialize();
      configService.logValues();

      ConfigKey.values.forEachIndexed((i, k) {
        expect(
          logRecords[i].message,
          isNot(contains("not found")),
          reason: "key $k should be in _configMap, but was not found",
        );
        expect(
          logRecords[i].message,
          isNot(contains("empty value")),
          reason: "key $k was in _configMap, but had empty value",
        );
      });
    });
    test("calling getConfigValue() before initialize() throws exception", () {
      expect(
        () => configService.getConfigValue(ConfigKey.apiAddress),
        throwsA(isA<AppException>()),
      );
    });
    test(
      "calling getConfigValue() after initialize() does not throw exception",
      () async {
        await configService.initialize();
        expect(
          () => configService.getConfigValue(ConfigKey.apiAddress),
          returnsNormally,
        );
      },
    );
    test("getConfigValue() should not return empty strings", () async {
      await configService.initialize();
      for (final configKey in ConfigKey.values) {
        final String value = configService.getConfigValue(configKey);
        expect(
          value,
          isNotEmpty,
          reason: "key $configKey should not have empty value",
        );
      }
    });
  });
}
