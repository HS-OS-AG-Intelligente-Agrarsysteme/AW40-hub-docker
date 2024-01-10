import "package:aw40_hub_frontend/data_sources/diagnosis_data_table_source.dart";
import "package:aw40_hub_frontend/exceptions/exceptions.dart";
import "package:aw40_hub_frontend/models/case_model.dart";
import "package:aw40_hub_frontend/models/diagnosis_model.dart";
import "package:aw40_hub_frontend/providers/providers.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
import "package:aw40_hub_frontend/views/diagnosis_detail_view.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class DiagnosesView extends StatelessWidget {
  const DiagnosesView({super.key, this.diagnosisId});
  final String? diagnosisId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // ignore: discarded_futures
      future: _getDiagnoses(context),
      builder:
          (BuildContext context, AsyncSnapshot<List<DiagnosisModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final List<DiagnosisModel>? diagnosisModels = snapshot.data;
          if (diagnosisModels == null) {
            throw AppException(
              exceptionType: ExceptionType.notFound,
              exceptionMessage: "Received no diagnosis data.",
            );
          }
          diagnosisModels.sort((a, b) => a.status.index - b.status.index);
          final int initialDiagnosisIndex = diagnosisId == null
              ? 0
              : _getDiagnosisIndexFromId(diagnosisModels, diagnosisId!);

          return DesktopDiagnosisView(
            diagnosisModels: diagnosisModels,
            initialDiagnosisIndex: initialDiagnosisIndex,
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  /// Returns the index of the diagnosis with the given `id`.
  /// If no diagnosis with the given `id` is found, `0` is returned.
  static int _getDiagnosisIndexFromId(
    List<DiagnosisModel> models,
    String id,
  ) {
    final diagnosisIndex = models.indexWhere((d) => d.id == id);
    return diagnosisIndex == -1 ? 0 : diagnosisIndex;
  }

  static Future<List<DiagnosisModel>> _getDiagnoses(
    BuildContext context,
  ) async {
    final caseProvider = Provider.of<CaseProvider>(context);
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context);
    final List<CaseModel> caseModels = await caseProvider.getCurrentCases();
    final Future<List<DiagnosisModel>> diagnoses =
        diagnosisProvider.getDiagnoses(caseModels);

    return diagnoses;
  }
}

class DesktopDiagnosisView extends StatefulWidget {
  const DesktopDiagnosisView({
    required this.diagnosisModels,
    required this.initialDiagnosisIndex,
    super.key,
  });

  final List<DiagnosisModel> diagnosisModels;
  final int initialDiagnosisIndex;

  @override
  State<DesktopDiagnosisView> createState() => _DesktopDiagnosisViewState();
}

class _DesktopDiagnosisViewState extends State<DesktopDiagnosisView> {
  int? currentDiagnosisIndex;

  @override
  Widget build(BuildContext context) {
    currentDiagnosisIndex ??= widget.initialDiagnosisIndex;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: PaginatedDataTable(
              source: DiagnosisDataTableSource(
                themeData: Theme.of(context),
                currentIndex: currentDiagnosisIndex,
                diagnosisModels: widget.diagnosisModels,
                onPressedRow: (int i) =>
                    setState(() => currentDiagnosisIndex = i),
              ),
              showCheckboxColumn: false,
              rowsPerPage: 50,
              columns: [
                DataColumn(
                  label: Expanded(
                    child: Text(tr("general.id")),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(tr("general.status")),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(tr("general.case")),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(tr("general.date")),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.diagnosisModels.isNotEmpty)
          Expanded(
            flex: 2,
            child: DiagnosisDetailView(
              diagnosisModel: widget.diagnosisModels[currentDiagnosisIndex!],
            ),
          )
      ],
    );
  }
}
