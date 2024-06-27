import "dart:collection";

import "package:aw40_hub_frontend/env/env.dart";
import "package:aw40_hub_frontend/exceptions/exceptions.dart";
import "package:aw40_hub_frontend/services/services.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
import "package:logging/logging.dart";

class ConfigService {
  factory ConfigService() => _configService;

  ConfigService._singleton();

  static final ConfigService _configService = ConfigService._singleton();

  final Logger _logger = Logger("config_service");
  final Map<ConfigKey, String> _configMap = {};
  bool _initialized = false;

  /// Clears the config map and sets initialized to false.
  /// Necessary for testing singleton.
  void reset() {
    _configMap.clear();
    _initialized = false;
  }

  Future<void> initialize() async {
    // Note: LinkedHashMap preserves insertion order and iterates in that order.
    // It is the default map type in Dart, so this cast should always succeed.
    // However, I am a bit paranoid about this because a regular HashMap would
    // result in multiple tests failing.
    assert(_configMap is LinkedHashMap, "_configMap is not a LinkedHashMap.");

    await _importConfigValues();
    _initialized = true;
  }

  Future<void> _importConfigValues() async {
    // Note: Always do this in alphabetical order. Unit tests are relying on it.
    _configMap[ConfigKey.apiAddress] = Env.apiAddress;
    _configMap[ConfigKey.frontendAddress] = Env.frontendAddress;
    _configMap[ConfigKey.keyCloakAddress] = Env.keyCloakAddress;
    _configMap[ConfigKey.keyCloakClient] = Env.keyCloakClient;
    _configMap[ConfigKey.keyCloakRealm] = Env.keyCloakRealm;
    _configMap[ConfigKey.logLevel] = Env.logLevel;
    _configMap[ConfigKey.proxyDefaultScheme] = Env.proxyDefaultScheme;
    _configMap[ConfigKey.redirectUriMobile] = Env.redirectUriMobile;
    _configMap[ConfigKey.useMockData] =
        // ignore: do_not_use_environment
        const String.fromEnvironment("USE_MOCK_DATA", defaultValue: "false");

    if (EnvironmentService().hostPlatform == HostPlatform.android) {
      for (final key in ConfigKey.values) {
        final String value = _configMap[key]!;
        if (value.contains("localhost")) {
          _configMap[key] = _androidifyUrl(value);
        }
      }
    }
  }

  String getConfigValue(ConfigKey configKey) {
    _ensureInitDone();
    final String? configValue = _configMap[configKey];
    if (configValue == null) {
      throw AppException(
        exceptionMessage: "ConfigService getConfigValue: "
            "no value found for config with key: $configKey",
        exceptionType: ExceptionType.notFound,
      );
    }
    return configValue;
  }

  void _ensureInitDone() {
    if (!_initialized) {
      throw AppException(
        exceptionType: ExceptionType.other,
        exceptionMessage: "Called ConfigService method before init was done.",
      );
    }
  }

  /// Replaces `localhost` with `10.0.2.2`. On Android, `localhost` refers to
  /// the emulator itself, `10.0.2.2` refers to the webbrowser within the
  /// Android app.
  // TODO: Will this still work with proxies?
  String _androidifyUrl(String oldUrl) {
    final String newUrl = oldUrl.replaceFirst("localhost", "10.0.2.2");
    _logger.warning("Androidifying URL $oldUrl to $newUrl");
    return newUrl;
  }

  void logValues() {
    for (final configKey in ConfigKey.values) {
      if (!_configMap.containsKey(configKey)) {
        _logger.warning("$configKey not found in config map.");
      } else {
        final String value = _configMap[configKey]!;
        if (value.isEmpty) {
          _logger.warning("$configKey has empty value.");
        } else {
          _logger.info("$configKey: $value");
        }
      }
    }
  }
}
