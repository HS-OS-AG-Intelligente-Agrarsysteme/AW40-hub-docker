import "dart:async";
import "dart:convert";

import "package:aw40_hub_frontend/dtos/dtos.dart";
import "package:aw40_hub_frontend/models/models.dart";
import "package:aw40_hub_frontend/providers/providers.dart";
import "package:aw40_hub_frontend/services/services.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:cross_file/cross_file.dart";
import "package:desktop_drop/desktop_drop.dart";
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
  XFile? _file;
  final Logger _logger = Logger("diagnosis detail view");

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    final backgroundColor = HelperService.getDiagnosisStatusBackgroundColor(
      colorScheme,
      widget.diagnosisModel.status,
    );
    final foregroundColor = HelperService.getDiagnosisStatusForegroundColor(
      colorScheme,
      widget.diagnosisModel.status,
    );

    return SizedBox.expand(
      child: Card(
        color: colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                title: Text(
                  tr("diagnoses.details.headline"),
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(color: colorScheme.onPrimaryContainer),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.delete_forever),
                    iconSize: 28,
                    style: IconButton.styleFrom(
                      foregroundColor: colorScheme.error,
                    ),
                    onPressed: () async => _onDeleteButtonPress(
                      context,
                      Provider.of<AuthProvider>(context, listen: false)
                          .loggedInUser,
                      widget.diagnosisModel.caseId,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Case ID
              Text(
                "${tr('general.case')}: ${widget.diagnosisModel.caseId}",
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              // Coloured card for current State
              Card(
                color: backgroundColor,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        HelperService.getDiagnosisStatusIconData(
                          widget.diagnosisModel.status,
                        ),
                      ),
                      title: Text(
                        // ignore: lines_longer_than_80_chars
                        tr("diagnoses.status.${widget.diagnosisModel.status.name}"),
                        style: textTheme.bodyMedium?.copyWith(
                          color: foregroundColor,
                        ),
                      ),
                      iconColor: foregroundColor,
                      subtitle: widget.diagnosisModel.status ==
                              DiagnosisStatus.action_required
                          ? Tooltip(
                              message: HelperService.convertIso88591ToUtf8(
                                widget.diagnosisModel.todos[0].instruction,
                              ),
                              child: Text(
                                HelperService.convertIso88591ToUtf8(
                                  widget.diagnosisModel.todos[0].instruction,
                                ),
                                style: TextStyle(
                                  color: foregroundColor,
                                ),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : null,
                      trailing: widget.diagnosisModel.status ==
                              DiagnosisStatus.action_required
                          ? IconButton(
                              icon: const Icon(Icons.upload_file),
                              onPressed: _file == null ? null : uploadFile,
                              disabledColor: colorScheme.outline,
                              tooltip: _file == null
                                  ? null
                                  : tr("diagnoses.details.uploadFileTooltip"),
                            )
                          : null,
                    ),
                    if (widget.diagnosisModel.status ==
                        DiagnosisStatus.action_required) ...[
                      const SizedBox(height: 16),
                      DiagnosisDragAndDropArea(
                        fileName: _file?.name,
                        onDragDone: (DropDoneDetails dropDoneDetails) {
                          setState(() {
                            final files = dropDoneDetails.files;
                            final XFile f = files.first;
                            _file = f;
                          });
                        },
                      ),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // TBD: State Machine Log
              const Expanded(child: Placeholder()),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> uploadFile() async {
    final ScaffoldMessengerState scaffoldMessengerState =
        ScaffoldMessenger.of(context);
    final diagnosisProvider = Provider.of<DiagnosisProvider>(
      context,
      listen: false,
    );

    diagnosisProvider.uploadedData = true;

    try {
      final XFile file = _file!;
      final String fileContent = await file.readAsString();
      bool result = false;

      switch (widget.diagnosisModel.todos.first.dataType) {
        case "obd":
          final Map<String, dynamic> jsonMap = jsonDecode(fileContent);
          final NewOBDDataDto newOBDDataDto = NewOBDDataDto.fromJson(jsonMap);

          result = await diagnosisProvider.uploadObdData(
            widget.diagnosisModel.caseId,
            newOBDDataDto,
          );
          break;
        case "oscillogram":
          final List<int> byteData = utf8.encode(fileContent);
          result = await diagnosisProvider.uploadPicoscopeData(
            widget.diagnosisModel.caseId,
            byteData,
            file.name,
          );
          break;
        case "symptom":
          final Map<String, dynamic> jsonMap = jsonDecode(fileContent);
          final NewSymptomDto newSymptomDto = NewSymptomDto.fromJson(jsonMap);

          result = await diagnosisProvider.uploadSymtomData(
            widget.diagnosisModel.caseId,
            newSymptomDto,
          );
          break;
      }

      _showMessage(
        result
            ? tr(
                "diagnoses.details.uploadDataSuccessMessage",
              )
            : tr(
                "diagnoses.details.uploadDataErrorMessage",
              ),
        scaffoldMessengerState,
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      _logger.info("Exception during file upload: $e");
      _showMessage(
        tr("diagnoses.details.uploadObdDataErrorMessage"),
        scaffoldMessengerState,
      );
    }
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
    LoggedInUserModel loggedInUserModel,
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
      if (deletionResult) {
        // diagnosisProvider.currentDiagnosisIndex = null;
      }
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
}

class DiagnosisDragAndDropArea extends StatefulWidget {
  const DiagnosisDragAndDropArea({
    required this.onDragDone,
    required this.fileName,
    super.key,
  });
  final String? fileName;
  final void Function(DropDoneDetails) onDragDone;

  @override
  State<DiagnosisDragAndDropArea> createState() =>
      _DiagnosisDragAndDropAreaState();
}

class _DiagnosisDragAndDropAreaState extends State<DiagnosisDragAndDropArea> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.fileName == null)
          Text(
            tr("diagnoses.details.uploadFile"),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary,
            ),
          )
        else
          Text(
            widget.fileName!,
            style: const TextStyle(color: Colors.blue),
          ),
        const SizedBox(height: 16),
        DropTarget(
          onDragDone: (details) => widget.onDragDone(details),
          onDragEntered: (_) => setState(() => _dragging = true),
          onDragExited: (_) => setState(() => _dragging = false),
          child: Container(
            height: 125,
            width: 300,
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: _dragging ? Colors.blue.withOpacity(0.4) : Colors.black26,
            ),
            child: Center(
              child: Center(
                child: Text(
                  tr("diagnoses.details.dragAndDrop"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
