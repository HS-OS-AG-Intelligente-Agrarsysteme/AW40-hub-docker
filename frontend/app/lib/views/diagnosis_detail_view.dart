import "dart:async";

import "package:aw40_hub_frontend/components/dataset_upload_area.dart";
import "package:aw40_hub_frontend/components/state_machine_log_view.dart";
import "package:aw40_hub_frontend/models/action_model.dart";
import "package:aw40_hub_frontend/models/diagnosis_model.dart";
import "package:aw40_hub_frontend/models/state_machine_log_entry_model.dart";
import "package:aw40_hub_frontend/providers/diagnosis_provider.dart";
import "package:aw40_hub_frontend/services/helper_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:aw40_hub_frontend/utils/extensions.dart";
import "package:collection/collection.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:provider/provider.dart";

class DiagnosisDetailView extends StatefulWidget {
  const DiagnosisDetailView({
    required this.diagnosisModel,
    super.key,
  });

  final DiagnosisModel diagnosisModel;

  @override
  State<DiagnosisDetailView> createState() => _DiagnosisDetailView();
}

class _DiagnosisDetailView extends State<DiagnosisDetailView> {
  final Logger _logger = Logger("diagnosis detail view");
  static const double _spacing = 16;

  @override
  Widget build(BuildContext context) {
    _updateCaseId();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DiagnosisStatus status = widget.diagnosisModel.status;

    final diagnosisStatusContainerColor =
        HelperService.getDiagnosisStatusContainerColor(
      colorScheme,
      status,
    );
    final diagnosisStatusOnContainerColor =
        HelperService.getDiagnosisStatusOnContainerColor(
      colorScheme,
      status,
    );
    final diagnosisStatusIconData = HelperService.getDiagnosisStatusIconData(
      status,
    );

    return SizedBox.expand(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(_spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr("diagnoses.details.headline"),
                    style: textTheme.displaySmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_forever),
                    iconSize: 28,
                    style: IconButton.styleFrom(
                      foregroundColor: colorScheme.error,
                    ),
                    onPressed: () async => _onDeleteButtonPress(
                      context,
                      widget.diagnosisModel.caseId,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: _spacing),
              // Case ID
              Text(
                "${tr('general.case')}: ${widget.diagnosisModel.caseId}",
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: _spacing),
              // Coloured card for current State
              Card(
                color: diagnosisStatusContainerColor,
                child: Column(
                  children: [
                    // State icon, name, description.
                    ListTile(
                      leading: Icon(diagnosisStatusIconData),
                      title: Text(
                        tr("diagnoses.status.${status.name}"),
                      ),
                      subtitle: _getSubtitle,
                      textColor: diagnosisStatusOnContainerColor,
                      iconColor: diagnosisStatusOnContainerColor,
                    ),
                    // If diagnosis requires file upload, show FileUploadArea.
                    if (status == DiagnosisStatus.action_required)
                      DatasetUploadArea(
                        caseId: widget.diagnosisModel.caseId,
                        todos: widget.diagnosisModel.todos,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: _spacing),
              // State Machine Log
              Expanded(
                child: widget.diagnosisModel.stateMachineLog.isEmpty
                    ? const Center(
                        child: Text("No state machine log available."),
                      )
                    : StateMachineLogView(
                        stateMachineLog: widget.diagnosisModel.stateMachineLog,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateCaseId() {
    Provider.of<DiagnosisProvider>(
      context,
      listen: false,
    ).diagnosisCaseId = widget.diagnosisModel.caseId;
  }

  Text? get _getSubtitle {
    final DiagnosisStatus status = widget.diagnosisModel.status;
    switch (status) {
      case DiagnosisStatus.finished:
        final String? faultPath = _getFaultPathFromStateMachineLog(
          widget.diagnosisModel.stateMachineLog,
        );
        return Text(
          faultPath == null
              ? "tr('diagnoses.details.noFaultPathFound')"
              : "Fault path: $faultPath",
        );
      case DiagnosisStatus.action_required:
        final ActionModel? todo = widget.diagnosisModel.todos.firstOrNull;
        if (todo == null) {
          _logger.warning(
            "Status is action_required, but found empty todo list.",
          );
          break;
        }
        return Text(
          HelperService.convertIso88591ToUtf8(
            todo.instruction,
          ),
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        );
      case DiagnosisStatus.scheduled:
        break;
      case DiagnosisStatus.processing:
        break;
      case DiagnosisStatus.failed:
        break;
    }
    return null;
  }

  static Future<bool?> _showConfirmDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tr("diagnoses.details.dialog.title")),
          content: Text(tr("diagnoses.details.dialog.description")),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(tr("general.cancel")),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(
                tr("general.delete"),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _onDeleteButtonPress(
    BuildContext context,
    String diagnosisModelCaseId,
  ) async {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(
      context,
      listen: false,
    );

    await _showConfirmDeleteDialog(context).then((bool? dialogResult) async {
      final ScaffoldMessengerState scaffoldMessengerState =
          ScaffoldMessenger.of(context);
      if (dialogResult == null || !dialogResult) return;
      final bool deletionResult =
          await diagnosisProvider.deleteDiagnosis(diagnosisModelCaseId);
      final String message = deletionResult
          ? tr("diagnoses.details.deleteDiagnosisSuccessMessage")
          : tr("diagnoses.details.deleteDiagnosisErrorMessage");
      _showMessage(message, scaffoldMessengerState);
    });
  }

  static void _showMessage(String text, ScaffoldMessengerState state) {
    final SnackBar snackBar = SnackBar(
      content: Center(child: Text(text)),
    );
    state.showSnackBar(snackBar);
  }

  String? _getFaultPathFromStateMachineLog(
    List<StateMachineLogEntryModel> stateMachineLog,
  ) {
    for (final StateMachineLogEntryModel entry in stateMachineLog) {
      if (entry.message.contains("FAULT_PATHS")) {
        final String message = entry.message;
        return message.substringBetween(
          startDelimiter: "['",
          endDelimiter: "']",
        );
      }
    }
    return "tr('diagnoses.details.noFaultPathFound')";
  }
}
