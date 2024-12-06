import "package:aw40_hub_frontend/configs/localization_config.dart";
import "package:aw40_hub_frontend/main.dart";
import "package:aw40_hub_frontend/providers/asset_provider.dart";
import "package:aw40_hub_frontend/providers/auth_provider.dart";
import "package:aw40_hub_frontend/providers/case_provider.dart";
import "package:aw40_hub_frontend/providers/customer_provider.dart";
import "package:aw40_hub_frontend/providers/diagnosis_provider.dart";
import "package:aw40_hub_frontend/providers/knowledge_provider.dart";
import "package:aw40_hub_frontend/providers/theme_provider.dart";
import "package:aw40_hub_frontend/providers/vehicle_provider.dart";
import "package:aw40_hub_frontend/routing/router.dart";
import "package:aw40_hub_frontend/services/auth_service.dart";
import "package:aw40_hub_frontend/services/config_service.dart";
import "package:aw40_hub_frontend/services/http_service.dart";
import "package:aw40_hub_frontend/services/mock_http_service.dart";
import "package:aw40_hub_frontend/services/storage_service.dart";
import "package:aw40_hub_frontend/services/token_service.dart";
import "package:aw40_hub_frontend/themes/color_schemes.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:easy_localization/easy_localization.dart";
import "package:easy_localization_loader/easy_localization_loader.dart";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:provider/provider.dart";
import "package:routemaster/routemaster.dart";

class AWHubApp extends StatelessWidget {
  const AWHubApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final useMockData =
        ConfigService().getConfigValue(ConfigKey.useMockData) == "true";
    final httpService =
        useMockData ? MockHttpService() : HttpService(http.Client());
    return EasyLocalization(
      path: kLocalesPath,
      supportedLocales: kSupportedLocales.values.toList(),
      startLocale: kStartLocale,
      fallbackLocale: kStartLocale,
      assetLoader: YamlAssetLoader(),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(
              http.Client(),
              StorageService(),
              TokenService(),
              AuthService(),
              ConfigService(),
            ),
          ),
          ChangeNotifierProxyProvider<AuthProvider, CaseProvider>(
            create: (_) => CaseProvider(httpService),
            update: (_, authProvider, caseProvider) =>
                // ignore: discarded_futures
                caseProvider!..fetchAndSetAuthToken(authProvider),
          ),
          ChangeNotifierProxyProvider<AuthProvider, DiagnosisProvider>(
            create: (_) => DiagnosisProvider(httpService),
            update: (_, authProvider, diagnosisProvider) =>
                // ignore: discarded_futures
                diagnosisProvider!..fetchAndSetAuthToken(authProvider),
          ),
          ChangeNotifierProxyProvider<AuthProvider, CustomerProvider>(
            create: (_) => CustomerProvider(httpService),
            update: (_, authProvider, customerProvider) =>
                // ignore: discarded_futures
                customerProvider!..fetchAndSetAuthToken(authProvider),
          ),
          ChangeNotifierProxyProvider<AuthProvider, VehicleProvider>(
            create: (_) => VehicleProvider(httpService),
            update: (_, authProvider, vehicleProvider) =>
                // ignore: discarded_futures
                vehicleProvider!..fetchAndSetAuthToken(authProvider),
          ),
          ChangeNotifierProxyProvider<AuthProvider, AssetProvider>(
            create: (_) => AssetProvider(httpService),
            update: (_, authProvider, assetProvider) =>
                // ignore: discarded_futures
                assetProvider!..fetchAndSetAuthToken(authProvider),
          ),
          ChangeNotifierProxyProvider<AuthProvider, KnowledgeProvider>(
            create: (_) => KnowledgeProvider(httpService),
            update: (_, authProvider, knowledgeProvider) =>
                // ignore: discarded_futures
                knowledgeProvider!..fetchAndSetAuthToken(authProvider),
          ),
          ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider(),
          ),
        ],
        child: const AWMaterialApp(),
      ),
    );
  }
}

class AWMaterialApp extends StatelessWidget {
  const AWMaterialApp({super.key});

  @override
  Widget build(final BuildContext context) {
    return MaterialApp.router(
      title: "AW 4.0 Hub",
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      routerDelegate: RoutemasterDelegate(
        routesBuilder: (BuildContext context) {
          final authProvider = Provider.of<AuthProvider>(context);
          return getRouteMap(authProvider);
        },
        navigatorKey: globalNavKey,
      ),
      routeInformationParser: const RoutemasterParser(),
    );
  }
}
