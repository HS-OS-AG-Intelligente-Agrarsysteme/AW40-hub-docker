import "dart:convert";

import "package:aw40_hub_frontend/dtos/dtos.dart";
import "package:aw40_hub_frontend/exceptions/exceptions.dart";
import "package:aw40_hub_frontend/forms/upload_omniview_form.dart";
import "package:aw40_hub_frontend/forms/upload_picoscope_form.dart";
import "package:aw40_hub_frontend/forms/upload_timeseries_form.dart";
import "package:aw40_hub_frontend/models/action_model.dart";
import "package:aw40_hub_frontend/providers/providers.dart";
import "package:aw40_hub_frontend/services/helper_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:change_case/change_case.dart";
import "package:collection/collection.dart";
import "package:cross_file/cross_file.dart";
import "package:desktop_drop/desktop_drop.dart";
import "package:dotted_border/dotted_border.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:provider/provider.dart";

class FileUploadArea extends StatefulWidget {
  const FileUploadArea({
    required this.caseId,
    required this.todos,
    super.key,
  });

  final String caseId;

  final List<ActionModel> todos;

  @override
  State<FileUploadArea> createState() => _FileUploadAreaState();
}

class _FileUploadAreaState extends State<FileUploadArea> {
  bool _dragging = false;
  final Logger _logger = Logger("diagnosis detail view");
  XFile? _file;
  TimeseriesFormat selectedTimeseriesFormat = TimeseriesFormat.timeseries;

  Widget _getTimeseriesUploadForm(TimeseriesFormat format) {
    switch (format) {
      case TimeseriesFormat.timeseries:
        return const UploadTimeseriesForm();
      case TimeseriesFormat.picoscope:
        return const UploadPicoscopeForm();
      case TimeseriesFormat.omniview:
        return const UploadOmniviewForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final diagnosisStatusOnContainerColor =
        HelperService.getDiagnosisStatusOnContainerColor(
      colorScheme,
      DiagnosisStatus.action_required,
    );
    final DatasetType? datasetType = widget.todos.firstOrNull?.dataType;
    final XFile? file = _file;

    switch (datasetType) {
      case DatasetType.obd:
        return Text(
          "OBD | VCDS",
          style: textTheme.bodyLarge?.copyWith(
            color: diagnosisStatusOnContainerColor,
          ),
        );
      case DatasetType.timeseries:
        return Column(
          children: [
            SegmentedButton(
              showSelectedIcon: false,
              segments: TimeseriesFormat.values.map((v) {
                return ButtonSegment(
                  value: v,
                  label: Text(v.name.toTitleCase()),
                );
              }).toList(),
              selected: {selectedTimeseriesFormat},
              onSelectionChanged: (Set<TimeseriesFormat> newSelection) {
                setState(() => selectedTimeseriesFormat = newSelection.first);
              },
            ),
            Container(
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.onTertiaryContainer,
                  width: 2,
                ),
              ),
              child: _getTimeseriesUploadForm(selectedTimeseriesFormat),
            )
          ],
        );
      case DatasetType.symptom:
        return Text(
          "Symptom",
          style: textTheme.bodyLarge?.copyWith(
            color: diagnosisStatusOnContainerColor,
          ),
        );
      case DatasetType.unknown:
      case null:
    }

    // Return error UI.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Card(
        color: colorScheme.errorContainer,
        child: ListTile(
          isThreeLine: true,
          leading: Icon(Icons.error, color: colorScheme.error),
          title: Text(
            datasetType == null
                ? tr("diagnoses.todos.noTodosFound")
                : tr("diagnoses.todos.unknownDatasetType"),
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),
          ),
          subtitle: Text(
            datasetType == null
                ? tr("diagnoses.todos.noTodosFoundDescription")
                : tr("diagnoses.todos.unknownDatasetTypeDescription"),
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ),
      ),
    );
  }

  Widget createTextfields(DatasetType datasetType, Color fieldColor) {
    switch (datasetType) {
      case DatasetType.obd:
        //placeholder
        return Center(
          child: _dragging
              ? _buildButton(fieldColor, DatasetType.obd)
              : IconButton(
                  icon: const Icon(Icons.upload_file),
                  style: IconButton.styleFrom(
                    foregroundColor: fieldColor,
                  ),
                  onPressed: null,
                ),
        );

      case DatasetType.timeseries:
        return Column(
          children: [
            TextFormField(
              controller: _componentController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: fieldColor,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: fieldColor,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                filled: true,
                fillColor: fieldColor.withOpacity(0.2),
                label: const Text("Component"),
                labelStyle: TextStyle(color: fieldColor),
              ),
              style: TextStyle(color: fieldColor),
              cursorColor: fieldColor,
              cursorWidth: 1,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _samplingRateController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: fieldColor,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: fieldColor,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                filled: true,
                fillColor: fieldColor.withOpacity(0.2),
                label: const Text("Sampling Rate"),
                labelStyle: TextStyle(color: fieldColor),
              ),
              style: TextStyle(color: fieldColor),
              cursorColor: fieldColor,
              cursorWidth: 1,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: fieldColor,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: fieldColor,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                filled: true,
                fillColor: fieldColor.withOpacity(0.2),
                label: const Text("Duration"),
                labelStyle: TextStyle(color: fieldColor),
              ),
              style: TextStyle(color: fieldColor),
              cursorColor: fieldColor,
              cursorWidth: 1,
            ),
            const SizedBox(height: 16),
            Center(
              child: (_componentController.text.isNotEmpty &&
                      _samplingRateController.text.isNotEmpty &&
                      _durationController.text.isNotEmpty &&
                      _dragging)
                  ? _buildButton(fieldColor, DatasetType.timeseries)
                  : IconButton(
                      icon: const Icon(Icons.upload_file),
                      style: IconButton.styleFrom(
                        foregroundColor: fieldColor,
                      ),
                      onPressed: null,
                    ),
            )
          ],
        );
      case DatasetType.unknown:
        // TODO: Implement
        return const Placeholder();
      case DatasetType.symptom:
        // TODO: Implement
        return const Placeholder();
    }
  }

  Widget _buildButton(Color iconColor, DatasetType datasetType) {
    return IconButton(
      icon: const Icon(Icons.upload_file),
      style: IconButton.styleFrom(
        foregroundColor: iconColor,
      ),
      onPressed: () async => _uploadFile(datasetType),
      tooltip: tr("diagnoses.details.uploadFileTooltip"),
    );
  }

  void _onDragDone(DropDoneDetails dropDoneDetails) {
    setState(() {
      final files = dropDoneDetails.files;
      if (files.isEmpty) {
        throw AppException(
          exceptionType: ExceptionType.unexpectedNullValue,
          exceptionMessage: "`dropDoneDetails.files` is empty.",
        );
      }
      _file = files.first;
    });
  }

  Future<void> _uploadFile(DatasetType datasetType) async {
    final ScaffoldMessengerState scaffoldMessengerState =
        ScaffoldMessenger.of(context);
    final diagnosisProvider = Provider.of<DiagnosisProvider>(
      context,
      listen: false,
    );

    try {
      final XFile file = _file!;
      final String fileContent = await file.readAsString();
      bool result = false;

      switch (datasetType) {
        case DatasetType.obd:
          final Map<String, dynamic> jsonMap = jsonDecode(fileContent);
          final NewOBDDataDto newOBDDataDto = NewOBDDataDto.fromJson(jsonMap);

          result = await diagnosisProvider.uploadObdData(
            widget.caseId,
            newOBDDataDto,
          );
          break;
        case DatasetType.timeseries:
          final List<int> byteData = utf8.encode(fileContent);
          final String component = _componentController.text.toLowerCase();
          final int? samplingRate = int.tryParse(_samplingRateController.text);
          final int? duration = int.tryParse(_durationController.text);
          result = await diagnosisProvider.uploadOmniviewData(
            widget.caseId,
            byteData,
            file.name,
            component,
            samplingRate!,
            duration!,
          );
          break;
        case DatasetType.unknown:
          throw AppException(
            exceptionType: ExceptionType.unexpectedNullValue,
            exceptionMessage: "Unknown data type: "
                "${widget.todos.first.dataType}",
          );
        case DatasetType.symptom:
          // TODO: Handle this case.
          break;
      }

      _showMessage(
        result
            ? tr("diagnoses.details.uploadDataSuccessMessage")
            : tr("diagnoses.details.uploadDataErrorMessage"),
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

  static void _showMessage(String text, ScaffoldMessengerState state) {
    final SnackBar snackBar = SnackBar(
      content: Center(child: Text(text)),
    );
    state.showSnackBar(snackBar);
  }
}
