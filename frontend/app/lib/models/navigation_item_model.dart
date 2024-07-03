import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter/material.dart";

class NavigationMenuItemModel {
  const NavigationMenuItemModel({
    required this.title,
    required this.icon,
    required this.destination,
    this.navigationType = NavigationType.internal,
    this.actions,
  });

  final String title;
  final Icon icon;
  final NavigationType navigationType;
  final String destination;
  final List<Widget>? actions;

  bool get isExternal => navigationType == NavigationType.external;
}
