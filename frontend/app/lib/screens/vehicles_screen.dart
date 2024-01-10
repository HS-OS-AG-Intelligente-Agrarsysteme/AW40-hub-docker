import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(tr("vehicles.title")),
        ],
      ),
    );
  }
}
