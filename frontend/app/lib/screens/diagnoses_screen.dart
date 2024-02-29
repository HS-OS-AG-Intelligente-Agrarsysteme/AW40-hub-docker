import "package:aw40_hub_frontend/views/diagnoses_view.dart";
import "package:flutter/material.dart";

class DiagnosesScreen extends StatelessWidget {
  const DiagnosesScreen({super.key, this.diagnosisId});

  final String? diagnosisId;

  @override
  Widget build(BuildContext context) => DiagnosesView(diagnosisId: diagnosisId);
}
