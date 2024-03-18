import "package:aw40_hub_frontend/scaffolds/scaffolds.dart";
import "package:aw40_hub_frontend/screens/screens.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
import "package:flutter/material.dart";
import "package:routemaster/routemaster.dart";

class MechanicRoute {
  static bool isMechanic(List<AuthorizedGroup> groups) {
    // in dieser file lassen oder woanders hin
    if (groups.contains(AuthorizedGroup.Mechanics)) return true;
    return false;
  }

  static Map<String, PageBuilder> mechanicRoute() {
    return {
      "/": (RouteData info) {
        return const Redirect(kRouteCases);
      },
    };
  }
}
