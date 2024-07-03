import "package:aw40_hub_frontend/models/navigation_item_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("NavigationItemModel", () {
    const title = "Test Title";
    const icon = Icon(Icons.add);
    const destination = "some_destination";
    const navigationType = NavigationType.external;
    const actions = <Widget>[Text("le Test Text")];

    const navigationItemModel = NavigationMenuItemModel(
      title: title,
      icon: icon,
      destination: destination,
      navigationType: navigationType,
      actions: actions,
    );

    test("correctly assigns title", () {
      expect(navigationItemModel.title, title);
    });
    test("correctly assigns icon", () {
      expect(navigationItemModel.icon, icon);
    });
    test("correctly assigns destination", () {
      expect(navigationItemModel.destination, destination);
    });
    test("correctly assigns navigationType", () {
      expect(navigationItemModel.navigationType, navigationType);
    });
    test("correctly assigns actions", () {
      expect(navigationItemModel.actions, actions);
    });
    test("correctly assigns isExternal", () {
      expect(navigationItemModel.isExternal, true);
    });
  });
}
