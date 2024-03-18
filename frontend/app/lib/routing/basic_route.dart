import "package:aw40_hub_frontend/scaffolds/scaffolds.dart";
import "package:aw40_hub_frontend/screens/screens.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
import "package:flutter/material.dart";
import "package:routemaster/routemaster.dart";

//alle routes in einer Klasse aufrufen??

class BasicRoute {
  /*static const String kRouteCases = "/cases";
  static const String kRouteDiagnosisDetails = "/diagnosis/details";
  static const String kRouteDiagnosis = "/diagnosis";
  static const String kRouteCustomers = "/customers";
  static const String kRouteVehicles = "/vehicles";*/

  static Map<String, PageBuilder> basicRoutes() {
    return {
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
      kRouteDiagnosisDetails: (RouteData info) {
        final String? diagnosisId = info.pathParameters["diagnosisId"];
        return MaterialPage<Widget>(
          child: ScaffoldWrapper(
            currentIndex: 1,
            child: DiagnosesScreen(diagnosisId: diagnosisId),
          ),
        );
      },
      kRouteDiagnosis: (RouteData info) {
        return const MaterialPage<Widget>(
          child: ScaffoldWrapper(
            currentIndex: 1,
            child: DiagnosesScreen(),
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
  }
}
