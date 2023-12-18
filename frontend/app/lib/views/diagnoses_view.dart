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
    this.diagnosisId,
  });

  late DiagnosisProvider _diagnosisProvider;
  final String? diagnosisId;

  @override
  Widget build(BuildContext context) {
    _diagnosisProvider = Provider.of<DiagnosisProvider>(context);
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

          return DesktopDiagnosisView(
            diagnosisModels: diagnosisModels,
            diagnosisId: diagnosisId,
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<List<DiagnosisModel>> _getDiagnoses(
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
  DesktopDiagnosisView({
    required this.diagnosisModels,
    this.diagnosisId,
    super.key,
  });

  final List<DiagnosisModel> diagnosisModels;
  String? diagnosisId;

  @override
  State<DesktopDiagnosisView> createState() => _DesktopDiagnosisViewState();
}

class _DesktopDiagnosisViewState extends State<DesktopDiagnosisView> {
  final Logger _logger = Logger("diagnoses_view_state");

  @override
  Widget build(BuildContext context) {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context);
    final Routemaster routemaster = Routemaster.of(context);
    if (widget.diagnosisId != null) {
      diagnosisProvider.currentDiagnosisIndex = null;
      widget.diagnosisId = null;
    }
    diagnosisProvider.currentDiagnosisIndex ??= getCaseIndex(context) ?? 0;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: PaginatedDataTable(
              source: DiagnosisDataTableSource(
                themeData: Theme.of(context),
                currentIndex: diagnosisProvider.currentDiagnosisIndex,
                diagnosisModels: widget.diagnosisModels,
                onPressedRow: (int i) => setState(() {
                  final DiagnosisModel model = widget.diagnosisModels[i];
                  routemaster.push("/diagnoses/${model.id}");
                }),
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
        if (diagnosisProvider.currentDiagnosisIndex != null &&
            widget.diagnosisModels.isNotEmpty)
          Expanded(
            flex: 2,
            child: DiagnosisDetailView(
              diagnosisModel: widget
                  .diagnosisModels[diagnosisProvider.currentDiagnosisIndex!],
            ),
          )
      ],
    );
  }

  int? getCaseIndex(BuildContext context) {
    final pathParameters = Routemaster.of(context).currentRoute.pathParameters;
    final String? diagnosisIdString = pathParameters["diagnosisId"];
    final DiagnosisModel? foundModel = widget.diagnosisModels.firstWhereOrNull(
      (diagnosisModel) => diagnosisModel.id == diagnosisIdString,
    );
    if (foundModel == null) {
      _logger.info(
        "Could not resolve diagnosis with ID: $diagnosisIdString",
      );
    }
    return foundModel == null
        ? null
        : widget.diagnosisModels.indexOf(foundModel);
  }
}
