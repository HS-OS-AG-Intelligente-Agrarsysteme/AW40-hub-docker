import "dart:async";

import "package:aw40_hub_frontend/data_sources/detail_view_sources.dart";
import "package:aw40_hub_frontend/dialogs/update_case_dialog.dart";
import "package:aw40_hub_frontend/dtos/case_update_dto.dart";
import "package:aw40_hub_frontend/models/models.dart";
import "package:aw40_hub_frontend/providers/providers.dart";
import "package:aw40_hub_frontend/utils/extensions.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:routemaster/routemaster.dart";

class CaseDetailView extends StatelessWidget {
  const CaseDetailView({
    required this.caseModel,
    required this.onClose,
    super.key,
  });

  final CaseModel caseModel;
  final void Function() onClose;

  @override
  Widget build(BuildContext context) {
    return DesktopCaseDetailView(
      caseModel: caseModel,
      onClose: onClose,
      onDelete: () async => _onDeleteButtonPress(
        context,
        Provider.of<AuthProvider>(context, listen: false).loggedInUser,
        caseModel.id,
      ),
    );
  }

  static Future<bool?> _showConfirmDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tr("cases.details.dialog.title")),
          content: Text(tr("cases.details.dialog.description")),
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
    String caseModelId,
  ) async {
    final caseProvider = Provider.of<CaseProvider>(
      context,
      listen: false,
    );

    await _showConfirmDeleteDialog(context).then((bool? dialogResult) async {
      final ScaffoldMessengerState scaffoldMessengerState =
          ScaffoldMessenger.of(context);
      if (dialogResult == null || !dialogResult) return;
      final bool result = await caseProvider.deleteCase(caseModelId);
      final String message = result
          ? tr("cases.details.deleteCaseSuccessMessage")
          : tr("cases.details.deleteCaseErrorMessage");
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

class DesktopCaseDetailView extends StatefulWidget {
  const DesktopCaseDetailView({
    required this.caseModel,
    required this.onClose,
    required this.onDelete,
    super.key,
  });

  final CaseModel caseModel;
  final void Function() onClose;
  final void Function() onDelete;

  @override
  State<DesktopCaseDetailView> createState() => _DesktopCaseDetailViewState();
}

class _DesktopCaseDetailViewState extends State<DesktopCaseDetailView> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final caseProvider = Provider.of<CaseProvider>(context, listen: false);
    final diagnosisProvider =
        Provider.of<DiagnosisProvider>(context, listen: false);
    final Routemaster routemaster = Routemaster.of(context);

    final List<String> attributesCase = [
      tr("general.id"),
      tr("general.status"),
      tr("general.occasion"),
      tr("general.date"),
      tr("general.milage"),
      tr("general.customerId"),
      tr("general.vehicleVin"),
      tr("general.workshopId"),
    ];
    final List<String> valuesCase = [
      widget.caseModel.id,
      tr("cases.details.status.${widget.caseModel.status.name}"),
      tr("cases.details.occasion.${widget.caseModel.occasion.name}"),
      widget.caseModel.timestamp.toGermanDateString(),
      widget.caseModel.milage.toString(),
      widget.caseModel.customerId,
      widget.caseModel.vehicleVin,
      widget.caseModel.workshopId,
    ];

    return SizedBox.expand(
      child: SingleChildScrollView(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_double_arrow_right),
                      iconSize: 28,
                      onPressed: widget.onClose,
                      style: IconButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                      ),
                    ),
                    // const SizedBox(width: 16),
                    Text(
                      tr("cases.details.headline"),
                      style: textTheme.displaySmall,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_forever),
                      iconSize: 28,
                      style: IconButton.styleFrom(
                        foregroundColor: colorScheme.error,
                      ),
                      onPressed:
                          caseProvider.workShopId == widget.caseModel.workshopId
                              ? widget.onDelete
                              : null,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Table(
                  columnWidths: const {0: IntrinsicColumnWidth()},
                  children: List.generate(
                    attributesCase.length,
                    (i) => TableRow(
                      children: [
                        const SizedBox(height: 32),
                        Text(attributesCase[i]),
                        Text(valuesCase[i]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.edit),
                      label: Text(tr("general.edit")),
                      onPressed: caseProvider.workShopId ==
                              widget.caseModel.workshopId
                          ? () async {
                              final CaseUpdateDto? caseUpdateDto =
                                  await _showUpdateCaseDialog(widget.caseModel);
                              if (caseUpdateDto == null) return;
                              await caseProvider.updateCase(
                                widget.caseModel.id,
                                caseUpdateDto,
                              );
                            }
                          : null,
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.tab),
                      onPressed: caseProvider.workShopId ==
                              widget.caseModel.workshopId
                          ? () async {
                              if (widget.caseModel.diagnosisId == null) {
                                String message;
                                final ScaffoldMessengerState
                                    scaffoldMessengerState =
                                    ScaffoldMessenger.of(context);
                                final DiagnosisModel? createdDiagnosis =
                                    await diagnosisProvider
                                        .startDiagnosis(widget.caseModel.id);

                                if (createdDiagnosis != null) {
                                  message = tr(
                                    // ignore: lines_longer_than_80_chars
                                    "diagnoses.details.startDiagnosisSuccessMessage",
                                  );

                                  routemaster.push(
                                      "/diagnoses/${createdDiagnosis.id}");
                                } else {
                                  message = tr(
                                    // ignore: lines_longer_than_80_chars
                                    "diagnoses.details.startDiagnosisFailureMessage",
                                  );
                                }
                                _showMessage(message, scaffoldMessengerState);
                              } else {
                                routemaster.push(
                                  "/diagnoses/${widget.caseModel.diagnosisId}",
                                );
                              }
                            }
                          : null,
                      label: Text(
                        tr(
                          widget.caseModel.diagnosisId == null
                              ? "cases.details.startDiagnosis"
                              : "cases.details.showDiagnosis",
                        ),
                      ),
                    ),
                  ],
                ),
                //const SizedBox(height: 16),
                const Divider(height: 32, thickness: .1, color: Colors.white),
                //const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PaginatedDataTable(
                        source: CaseDetailDataTableSource(
                          themeData: Theme.of(context),
                          caseModels: widget.caseModel,
                          dataType:
                              "OBD", // => hier Liste mit den 3 Types die dann durchgelaufen werden
                        ),
                        showCheckboxColumn: false,
                        rowsPerPage: 12,
                        columns: [
                          DataColumn(label: Text(tr("general.id"))),
                          DataColumn(label: Text(tr("general.date"))),
                          const DataColumn(label: Text("DataType")),
                        ],
                      ),
                    )
                  ],
                ),

                /*SingleChildScrollView(
                scrollDirection: Axis
                    .horizontal, // Allows horizontal scrolling for wider tables
                child: DataTable(
                  columnSpacing: 56,
                  columns: [
                    DataColumn(label: Text(tr("general.id"))),
                    DataColumn(label: Text(tr("general.date"))),
                    DataColumn(label: Text(tr("general.type"))),
                  ],
                  rows: List.generate(
                    attributesID.length,
                    (i) => DataRow(
                      cells: [
                        DataCell(Text(
                          attributesID[i],
                        )), // Example, adjust according to your data structure
                        DataCell(Text(attributesTimestamp[
                            i])), // Example, adjust according to your data structure
                        DataCell(Text(attributesType[
                            i])), // Example, adjust according to your data structure
                      ],
                    ),
                  ),
                ),
              )


             //table Data
             Table(
                columnWidths: const {0: IntrinsicColumnWidth()},
                children: List.generate(
                  attributesData.length,
                  (i) => TableRow(
                    children: [
                      const SizedBox(height: 32),
                      Text(attributesData[i]),
                      //Text(valuesData[i]),
                    ],
                  ),
                ),
              ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<CaseUpdateDto?> _showUpdateCaseDialog(CaseModel caseModel) async {
    return showDialog<CaseUpdateDto>(
      context: context,
      builder: (BuildContext context) {
        return UpdateCaseDialog(caseModel: caseModel);
      },
    );
  }

  static void _showMessage(String text, ScaffoldMessengerState state) {
    final SnackBar snackBar = SnackBar(
      content: Center(child: Text(text)),
    );
    state.showSnackBar(snackBar);
  }
}
