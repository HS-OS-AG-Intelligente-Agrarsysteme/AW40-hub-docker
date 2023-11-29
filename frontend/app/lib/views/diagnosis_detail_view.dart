import "package:aw40_hub_frontend/models/models.dart";
import "package:aw40_hub_frontend/providers/providers.dart";
import "package:aw40_hub_frontend/services/helper_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:cross_file/cross_file.dart";
import "package:desktop_drop/desktop_drop.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
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
  final List<XFile> _list = [];
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final color = HelperService.getDiagnosisStatusBackgroundColor(
      colorScheme,
      widget.diagnosisModel.status,
    );
    final complementColor = HelperService.getDiagnosisStatusForegroundColor(
      colorScheme,
      widget.diagnosisModel.status,
    );

    return SizedBox.expand(
      child: Card(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
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
              Table(
                columnWidths: const {0: IntrinsicColumnWidth()},
                children: [
                  TableRow(
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        tr("general.case"),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        widget.diagnosisModel.caseId,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Current State
              Card(
                color: color,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        HelperService.getDiagnosisStatusIconData(
                          widget.diagnosisModel.status,
                        ),
                      ),
                      title: Text(
                        tr("diagnoses.status.${widget.diagnosisModel.status.name}"),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: complementColor,
                        ),
                      ),
                      iconColor: complementColor,
                      subtitle: widget.diagnosisModel.status ==
                              DiagnosisStatus.action_required
                          ? Text(
                              widget.diagnosisModel.todos[0].instruction,
                              style: TextStyle(
                                color: complementColor,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    // TODO display name of uploaded File here
                    // TODO remove Listview builder since there will only be max. one item

                    if (_list.length == 1)
                      ListTile(
                        title: Text(
                          _list[0].name,
                          style: const TextStyle(color: Colors.blue),
                        ),
                        selectedColor: Theme.of(context).colorScheme.secondary,
                      )
                    else
                      Text(
                        "Liste enthält ${_list.length} Elemente",
                        style: const TextStyle(color: Colors.blue),
                      ),

                    const SizedBox(height: 16),
                    DropTarget(
                      onDragDone: (detail) {
                        setState(() {
                          _list.addAll(detail.files);
                        });
                      },
                      onDragEntered: (detail) {
                        setState(() {
                          _dragging = true;
                        });
                      },
                      onDragExited: (detail) {
                        setState(() {
                          _dragging = false;
                        });
                      },
                      // TODO adjust colors and height/width
                      child: Container(
                        height: 125,
                        width: 300,
                        color: _dragging
                            ? Colors.blue.withOpacity(0.4)
                            : Colors.black26,
                        child: Center(
                          child: Center(
                            child: Text(
                              tr("diagnoses.details.dragAndDrop"),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Placeholder(
                fallbackHeight: 250,
              ),
            ],
          ),
        ),
      ),
    );
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
