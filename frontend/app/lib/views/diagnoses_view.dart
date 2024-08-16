import "dart:async";

import "package:aw40_hub_frontend/data_sources/diagnosis_data_table_source.dart";
import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/models/diagnosis_model.dart";
import "package:aw40_hub_frontend/providers/diagnosis_provider.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:aw40_hub_frontend/views/diagnosis_detail_view.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:provider/provider.dart";

class DiagnosesView extends StatelessWidget {
  const DiagnosesView({super.key, this.diagnosisId});

  final String? diagnosisId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // ignore: discarded_futures
      future: Provider.of<DiagnosisProvider>(context).getDiagnoses(),
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

          return DesktopDiagnosesView(
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
}

class DesktopDiagnosesView extends StatefulWidget {
  const DesktopDiagnosesView({
    required this.diagnosisModels,
    required this.initialDiagnosisIndex,
    super.key,
  });

  final List<DiagnosisModel> diagnosisModels;
  final int initialDiagnosisIndex;

  @override
  State<DesktopDiagnosesView> createState() => _DesktopDiagnosesViewState();
}

class _DesktopDiagnosesViewState extends State<DesktopDiagnosesView> {
  int? currentDiagnosisIndex;
  Timer? _timer;
  final Logger _logger = Logger("DesktopDiagnosesView");

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) async => _checkForUpdates(),
    );
  }

  Future<void> _checkForUpdates() async {
    final provider = Provider.of<DiagnosisProvider>(context, listen: false);
    final List<DiagnosisModel> models = widget.diagnosisModels;

    final Map<int, DiagnosisModel> updates = {};
    for (int i = 0; i < models.length; i++) {
      final DiagnosisModel oldModel = models[i];
      final DiagnosisModel? newModel =
          await provider.getDiagnosis(oldModel.caseId);
      if (newModel == null) {
        _logger.warning(
          "Could not fetch diagnosis with id ${oldModel.id}."
          " This is likely a mistake in the backend."
          " The frontend does not handle this error, please reload.",
        );
        continue;
      }
      if (newModel.status != oldModel.status) updates[i] = newModel;
    }
    setState(() => updates.forEach((i, model) => models[i] = model));
  }

  @override
  Widget build(BuildContext context) {
    currentDiagnosisIndex ??= widget.initialDiagnosisIndex;

    if (widget.diagnosisModels.isEmpty) {
      return Center(
        child: Text(
          tr("general.no.diagnoses"),
          style: Theme.of(context).textTheme.displaySmall,
        ),
      );
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
        // MRU: I don't think this check is necessary, but maybe someone added
        // it for a reason. I'm too afraid to remove it.
        if (widget.diagnosisModels.isNotEmpty)
          Expanded(
            flex: 2,
            child: DiagnosisDetailView(
              diagnosisModel: widget.diagnosisModels[currentDiagnosisIndex!],
            ),
          ),
      ],
    );
  }
}
