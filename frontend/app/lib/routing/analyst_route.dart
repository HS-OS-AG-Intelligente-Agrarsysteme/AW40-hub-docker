import "package:aw40_hub_frontend/scaffolds/scaffolds.dart";
import "package:aw40_hub_frontend/screens/screens.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
import "package:flutter/material.dart";
import "package:routemaster/routemaster.dart";

class AnalystRoute {
  static bool isAnalyst(List<AuthorizedGroup> groups) {
    if (groups.contains(AuthorizedGroup.Analysts)) return true;
    return false;
  }

  //hier zuweisung von den Routes
  static Map<String, PageBuilder> analystRoute() {
    return {
      "/": (RouteData info) {
        return const Redirect(kRouteCases);
      },
    };
  }
}
