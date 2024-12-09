import "dart:async";

import "package:aw40_hub_frontend/components/dataset_upload_case_view.dart";
import "package:aw40_hub_frontend/dialogs/update_case_dialog.dart";
import "package:aw40_hub_frontend/dtos/case_update_dto.dart";
import "package:aw40_hub_frontend/models/case_model.dart";
import "package:aw40_hub_frontend/models/data_model.dart";
import "package:aw40_hub_frontend/models/diagnosis_model.dart";
import "package:aw40_hub_frontend/models/logged_in_user_model.dart";
import "package:aw40_hub_frontend/models/obd_data_model.dart";
import "package:aw40_hub_frontend/models/symptom_model.dart";
import "package:aw40_hub_frontend/models/timeseries_data_model.dart";
import "package:aw40_hub_frontend/providers/auth_provider.dart";
import "package:aw40_hub_frontend/providers/case_provider.dart";
import "package:aw40_hub_frontend/providers/diagnosis_provider.dart";
import "package:aw40_hub_frontend/services/ui_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
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
      onDeleteData: (int? dataId, DatasetType datasetType) async =>
          _onDeleteDataPress(context, dataId, datasetType),
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

  Future<void> _onDeleteButtonPress(
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
      UIService.showMessage(message, scaffoldMessengerState);
    });

    onClose();
  }

  Future<void> _onDeleteDataPress(
    BuildContext context,
    int? dataId,
    DatasetType datasetType,
  ) async {
    final caseProvider = Provider.of<CaseProvider>(context, listen: false);
    final ScaffoldMessengerState scaffoldMessengerState =
        ScaffoldMessenger.of(context);

    final bool? dialogResult = await _showConfirmDeleteDialog(context);
    if (dialogResult == null || !dialogResult) return;

    bool result = false;
    switch (datasetType) {
      case DatasetType.timeseries:
        result = await caseProvider.deleteTimeseriesData(
          dataId,
          caseModel.workshopId,
          caseModel.id,
        );
        break;
      case DatasetType.obd:
        result = await caseProvider.deleteObdData(
          dataId,
          caseModel.workshopId,
          caseModel.id,
        );
        break;
      case DatasetType.symptom:
        result = await caseProvider.deleteSymptomData(
          dataId,
          caseModel.workshopId,
          caseModel.id,
        );
        break;
      case DatasetType.unknown:
        UIService.showMessage(
          tr("cases.details.deleteDataUnknownDataTypeMessage"),
          scaffoldMessengerState,
        );
        return;
    }

    final String message = result
        ? tr("cases.details.deleteDataSuccessMessage")
        : tr("cases.details.deleteDataErrorMessage");
    UIService.showMessage(message, scaffoldMessengerState);
  }
}

class DesktopCaseDetailView extends StatefulWidget {
  const DesktopCaseDetailView({
    required this.caseModel,
    required this.onClose,
    required this.onDelete,
    required this.onDeleteData,
    super.key,
  });

  final CaseModel caseModel;
  final void Function() onClose;
  final void Function() onDelete;
  final Future<void> Function(int? dataId, DatasetType datasetType)
      onDeleteData;

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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                          caseProvider.workshopId == widget.caseModel.workshopId
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
                      icon: const Icon(Icons.upload_rounded),
                      label: Text(tr("uploadData.label")),
                      onPressed: caseProvider.workshopId ==
                              widget.caseModel.workshopId
                          ? () async => showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  actions: [
                                    DatasetUploadCaseView(
                                      caseId: widget.caseModel.id,
                                    )
                                  ],
                                ),
                              )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.edit),
                      label: Text(tr("general.edit")),
                      onPressed: caseProvider.workshopId ==
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
                      onPressed: caseProvider.workshopId ==
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
                                    "/diagnoses/${createdDiagnosis.id}",
                                  );
                                } else {
                                  message = tr(
                                    // ignore: lines_longer_than_80_chars
                                    "diagnoses.details.startDiagnosisFailureMessage",
                                  );
                                }
                                UIService.showMessage(
                                  message,
                                  scaffoldMessengerState,
                                );
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
                const SizedBox(height: 32),
                Text(
                  tr("general.datasets"),
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                if (hasNoData)
                  Text(tr("general.noData"))
                else
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(5),
                      2: FlexColumnWidth(3),
                      3: FlexColumnWidth(),
                    },
                    children: [
                      TableRow(
                        children: [
                          Text(tr("general.id")),
                          Text(tr("general.date")),
                          Text(tr("general.dataType")),
                          const Text(""),
                        ],
                      ),
                      ...[
                        ...widget.caseModel.timeseriesData.map(buildDataRow),
                        ...widget.caseModel.obdData.map(buildDataRow),
                        ...widget.caseModel.symptoms.map(buildDataRow),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get hasNoData =>
      widget.caseModel.symptoms.isEmpty &&
      widget.caseModel.timeseriesData.isEmpty &&
      widget.caseModel.obdData.isEmpty;

  TableRow buildDataRow(DataModel model) {
    Text textWidget = const Text("");
    DatasetType datasetType = DatasetType.unknown;
    switch (model.runtimeType) {
      case ObdDataModel:
        textWidget = Text(tr("general.obd"));
        datasetType = DatasetType.obd;
        break;
      case TimeseriesDataModel:
        final timeseriesDataModel = model as TimeseriesDataModel;
        textWidget = Text(timeseriesDataModel.type?.name.capitalize() ?? "");
        datasetType = DatasetType.timeseries;
        break;
      case SymptomModel:
        textWidget = Text(tr("general.symptom"));
        datasetType = DatasetType.symptom;
        break;
    }

    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return TableRow(
      children: [
        SizedBox(
          height: 32,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(model.dataId.toString()),
          ),
        ),
        SizedBox(
          height: 32,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(model.timestamp?.toGermanDateTimeString() ?? ""),
          ),
        ),
        SizedBox(
          height: 32,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: textWidget,
          ),
        ),
        deleteButton(
          colorScheme,
          model.dataId,
          datasetType,
        ),
      ],
    );
  }

  IconButton deleteButton(
    ColorScheme colorScheme,
    int? dataId,
    DatasetType datasetType,
  ) {
    return IconButton(
      icon: const Icon(Icons.delete_forever),
      iconSize: 28,
      style: IconButton.styleFrom(
        foregroundColor: colorScheme.error,
      ),
      onPressed: () async {
        await widget.onDeleteData(dataId, datasetType);
      },
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
}
