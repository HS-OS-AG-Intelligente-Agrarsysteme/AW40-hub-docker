import "package:aw40_hub_frontend/configs/configs.dart";
import "package:aw40_hub_frontend/main.dart";
import "package:aw40_hub_frontend/providers/providers.dart";
import "package:aw40_hub_frontend/routing/router.dart";
import "package:aw40_hub_frontend/services/mock_http_service.dart";
import "package:aw40_hub_frontend/services/services.dart";
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
            update: (_, authProvider, caseProvider) =>
                // ignore: discarded_futures
                caseProvider!..fetchAndSetAuthToken(authProvider),
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
