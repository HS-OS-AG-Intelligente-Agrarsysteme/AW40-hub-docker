import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

class NoDiagnosesScreen extends StatelessWidget {
  const NoDiagnosesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        tr("no.diagnoses"),
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }
}
