import "package:aw40_hub_frontend/providers/auth_provider.dart";
import "package:aw40_hub_frontend/scaffolds/scaffold_wrapper.dart";
import "package:aw40_hub_frontend/screens/cases_screen.dart";
import "package:aw40_hub_frontend/screens/customers_screen.dart";
import "package:aw40_hub_frontend/screens/diagnoses_screen.dart";
import "package:aw40_hub_frontend/screens/login_screen.dart";
import "package:aw40_hub_frontend/screens/no_authorization_screen.dart";
import "package:aw40_hub_frontend/screens/page_not_found_screen.dart";
import "package:aw40_hub_frontend/screens/vehicles_screen.dart";
import "package:aw40_hub_frontend/utils/constants.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:routemaster/routemaster.dart";
import "package:universal_html/html.dart";

RouteMap getRouteMap(AuthProvider authProvider) {
  final Logger logger = Logger("get_route_map");

  final Map<String, PageBuilder> routes = {};
  RouteSettings Function(String path) onUnknownRoute;

  final bool isLoggedIn = authProvider.isLoggedIn();
  logger.config("isLoggedIn: $isLoggedIn");
  if (!isLoggedIn) {
    onUnknownRoute = (String route) {
      logger.config(
        "Requested route $route, user not logged in, returning LoginScreen.",
      );
      final String? currentBrowserUrl = kIsWeb ? window.location.href : null;
      return MaterialPage<Widget>(
        child: LoginScreen(currentBrowserUrl: currentBrowserUrl),
      );
    };
  } else if (!authProvider.isAuthorized) {
    onUnknownRoute = (String route) {
      logger.config("User is not authorized.");
      return const MaterialPage<Widget>(
        child: ScaffoldWrapper(
          child: NoAuthorizationScreen(),
        ),
      );
    };
  } else {
    routes.addAll(_basicRoutes);
    onUnknownRoute = (String route) {
      return const MaterialPage<Widget>(
        child: ScaffoldWrapper(
          currentIndex: -1, // No nav item selected.
          child: PageNotFoundScreen(),
        ),
      );
    };
    final groups = authProvider.getUserGroups;
    if (groups.contains(AuthorizedGroup.Mechanics)) {
      logger.config(
        "User is authorized as Mechanic, access to MechanicRoutes.",
      );
      routes.addAll(_mechanicsRoutes);
    }
    if (groups.contains(AuthorizedGroup.Analysts)) {
      logger.config("User is authorized as Analyst, access to AnalystsRoutes.");
      routes.addAll(_analystsRoutes);
    }
  }

  final RouteMap routeMap = RouteMap(
    routes: routes,
    onUnknownRoute: onUnknownRoute,
  );
  return routeMap;
}

Map<String, PageBuilder> _basicRoutes = {
  "/": (RouteData info) {
    return const Redirect(kRouteCases);
  },
  kRouteCases: (RouteData info) {
    return const MaterialPage<Widget>(
      child: ScaffoldWrapper(
        currentIndex: 0,
        child: CasesScreen(),
      ),
    );
  },
  kRouteDiagnosis: (RouteData info) {
    final String? diagnosisId = info.pathParameters["diagnosisId"];
    return MaterialPage<Widget>(
      child: ScaffoldWrapper(
        currentIndex: 1,
        child: DiagnosesScreen(diagnosisId: diagnosisId),
      ),
    );
  },
  kRouteCustomers: (RouteData info) {
    return const MaterialPage<Widget>(
      child: ScaffoldWrapper(
        currentIndex: 2,
        child: CustomersScreen(),
      ),
    );
  },
  kRouteVecicles: (RouteData info) {
    return const MaterialPage<Widget>(
      child: ScaffoldWrapper(
        currentIndex: 3,
        child: VehiclesScreen(),
      ),
    );
  },
};

Map<String, PageBuilder> _mechanicsRoutes = {};

Map<String, PageBuilder> _analystsRoutes = {};
