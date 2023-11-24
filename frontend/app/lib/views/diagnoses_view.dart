import "package:aw40_hub_frontend/data_sources/diagnosis_data_table_source.dart";
import "package:aw40_hub_frontend/exceptions/exceptions.dart";
import "package:aw40_hub_frontend/models/case_model.dart";
import "package:aw40_hub_frontend/models/diagnosis_model.dart";
import "package:aw40_hub_frontend/providers/providers.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
import "package:aw40_hub_frontend/views/diagnosis_detail_view.dart";
import "package:collection/collection.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:provider/provider.dart";
import "package:routemaster/routemaster.dart";

class DiagnosesView extends StatelessWidget {
  DiagnosesView({
    super.key,
  });

  final Logger _logger = Logger("diagnoses_view");

  @override
  Widget build(BuildContext context) {
    final pathParameters = Routemaster.of(context).currentRoute.pathParameters;
    final String? diagnosisIdString = pathParameters["diagnosisId"];

    final diagnosisProvider = Provider.of<DiagnosisProvider>(context);
    return FutureBuilder(
      // ignore: discarded_futures
      future: _getDiagnoses(context, diagnosisProvider),
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

          final DiagnosisModel? foundModel = diagnosisModels.firstWhereOrNull(
            (diagnosisModel) => diagnosisModel.id == diagnosisIdString,
          );
          if (foundModel == null) {
            _logger.info(
              "Could not resolve diagnosis with ID: $diagnosisIdString",
            );
          }

          return DesktopDiagnosisView(
            diagnosisModels: diagnosisModels,
            diagnosisIndex:
                foundModel == null ? null : diagnosisModels.indexOf(foundModel),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<List<CaseModel>> _getCaseModels(BuildContext context) {
    final caseProvider = Provider.of<CaseProvider>(context);
    return caseProvider.getCurrentCases();
  }

  Future<List<DiagnosisModel>> _getDiagnoses(
    BuildContext context,
    DiagnosisProvider diagnosisProvider,
  ) async {
    final Future<List<CaseModel>> caseModels = _getCaseModels(context);
    final Future<List<DiagnosisModel>> diagnoses =
        diagnosisProvider.getDiagnoses(
      await caseModels,
      context,
    );

    return diagnoses;
  }
}

class DesktopDiagnosisView extends StatefulWidget {
  const DesktopDiagnosisView({
    required this.diagnosisModels,
    this.diagnosisIndex,
    super.key,
  });

  final List<DiagnosisModel> diagnosisModels;
  final int? diagnosisIndex;

  @override
  State<DesktopDiagnosisView> createState() => _DesktopDiagnosisViewState();
}

class _DesktopDiagnosisViewState extends State<DesktopDiagnosisView> {
  int? currentDiagnosisIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (currentDiagnosisIndex == -1) {
      currentDiagnosisIndex = widget.diagnosisIndex ??
          0; // show details of first element as default
    }
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
        if (currentDiagnosisIndex != null && widget.diagnosisModels.isNotEmpty)
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
