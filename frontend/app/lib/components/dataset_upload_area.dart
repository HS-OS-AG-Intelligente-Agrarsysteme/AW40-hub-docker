import "package:aw40_hub_frontend/forms/upload_obd_form.dart";
import "package:aw40_hub_frontend/forms/upload_omniview_form.dart";
import "package:aw40_hub_frontend/forms/upload_picoscope_form.dart";
import "package:aw40_hub_frontend/forms/upload_symptom_form.dart";
import "package:aw40_hub_frontend/forms/upload_timeseries_form.dart";
import "package:aw40_hub_frontend/forms/upload_vcds_form.dart";
import "package:aw40_hub_frontend/models/action_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:change_case/change_case.dart";
import "package:collection/collection.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";

class DatasetUploadArea extends StatefulWidget {
  const DatasetUploadArea({
    required this.caseId,
    required this.todos,
    super.key,
  });

  final String caseId;

  final List<ActionModel> todos;

  @override
  State<DatasetUploadArea> createState() => _DatasetUploadAreaState();
}

class _DatasetUploadAreaState extends State<DatasetUploadArea> {
  // ignore: unused_field
  final Logger _logger = Logger("diagnosis detail view");
  TimeseriesFormat selectedTimeseriesFormat = TimeseriesFormat.timeseries;
  ObdFormat selectedObdFormat = ObdFormat.obd;

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

  Widget _getObdUploadForm(ObdFormat format) {
    switch (format) {
      case ObdFormat.obd:
        return const UploadObdForm();
      case ObdFormat.vcds:
        return const UploadVcdsForm();
    }
  }

  Widget _buildChild() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final DatasetType? datasetType = widget.todos.firstOrNull?.dataType;

    switch (datasetType) {
      case DatasetType.obd:
        return Column(
          children: [
            SegmentedButton(
              showSelectedIcon: false,
              segments: ObdFormat.values.map((v) {
                return ButtonSegment(
                  value: v,
                  label: Text(v.name.toTitleCase()),
                );
              }).toList(),
              selected: {selectedObdFormat},
              onSelectionChanged: (Set<ObdFormat> newSelection) {
                setState(() => selectedObdFormat = newSelection.first);
              },
            ),
            const SizedBox(height: 16),
            _getObdUploadForm(selectedObdFormat)
          ],
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
            const SizedBox(height: 16),
            _getTimeseriesUploadForm(selectedTimeseriesFormat),
          ],
        );
      case DatasetType.symptom:
        return const UploadSymptomForm();
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 68, vertical: 16),
      child: _buildChild(),
    );
  }
}
