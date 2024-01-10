import "package:aw40_hub_frontend/utils/constants.dart";
import "package:flutter/material.dart";

/// This is a convenient widget for the individual "sections" of the UI.
class HubCard extends StatelessWidget {
  const HubCard({this.child, super.key});
  final Widget? child;

  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        color: kPrimaryColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
