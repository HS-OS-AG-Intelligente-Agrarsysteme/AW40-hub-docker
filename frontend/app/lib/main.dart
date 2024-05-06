import "package:aw40_hub_frontend/aw_hub_app.dart";
import "package:aw40_hub_frontend/services/services.dart";
import "package:easy_localization/easy_localization.dart";
import "package:easy_logger/easy_logger.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_web_plugins/url_strategy.dart";
import "package:http/http.dart" as http;
import "package:logging/logging.dart";

final GlobalKey<NavigatorState> globalNavKey =
    GlobalKey<NavigatorState>(debugLabel: "globalNavKey");
final Logger _logger = Logger("main");

Future<void> main() async {
  await _initialize();
  final String d = EnvironmentService().isDebugMode ? "in debug mode" : "";
  _logger.info(
    "Initialised, running $d on ${EnvironmentService().hostPlatform.name}.",
  );
  runApp(const AWHubApp());
}

Future<void> _initialize() async {
  // Needed to access the assets bundle.
  WidgetsFlutterBinding.ensureInitialized();
  await _initLocalization();
  await ConfigService().initialize();
  // Get rid of super annoying # symbol in the URI.
  if (kIsWeb) setUrlStrategy(PathUrlStrategy());
  _initRootLogger();
  ConfigService().logValues();
  await _checkBackendHealth();
}

Future<void> _checkBackendHealth() async {
  await HttpService(http.Client()).checkBackendHealth().then((response) {
    response.statusCode == 200
        ? _logger.info("Backend healthcheck passed.")
        : _logger.severe(
            "Backend healthcheck failed! "
            "${response.statusCode}: ${response.body}",
          );
  }).catchError((error) {
    _logger.severe("Error checking backend health: $error");
  });
}

Future<void> _initLocalization() async {
  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableLevels = const <LevelMessages>[
    LevelMessages.warning,
    LevelMessages.error,
  ];
}

void _initRootLogger() {
  // In debug mode, use INFO level, otherwise get level from config map, if
  // unavailable, use WARNING.
  Logger.root.level = EnvironmentService().isDebugMode
      ? Level.INFO
      : HelperService.getLogLevelFromConfigMap() ?? Level.WARNING;

  Logger.root.onRecord.listen((final record) {
    debugPrint(
      "${record.level.name}: ${record.loggerName}:"
      "${record.time}: ${record.message}",
    );
  });
}
