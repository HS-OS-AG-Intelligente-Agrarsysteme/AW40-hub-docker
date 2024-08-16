import "package:aw40_hub_frontend/forms/upload_obd_form.dart";
import "package:aw40_hub_frontend/forms/upload_omniview_form.dart";
import "package:aw40_hub_frontend/forms/upload_picoscope_form.dart";
import "package:aw40_hub_frontend/forms/upload_symptom_form.dart";
import "package:aw40_hub_frontend/forms/upload_timeseries_form.dart";
import "package:aw40_hub_frontend/forms/upload_vcds_form.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:change_case/change_case.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";

class DatasetUploadCaseView extends StatefulWidget {
  const DatasetUploadCaseView({
    required this.caseId,
    super.key,
  });

  final String caseId;

  @override
  State<DatasetUploadCaseView> createState() => _DatasetUploadCaseViewState();
}

class _DatasetUploadCaseViewState extends State<DatasetUploadCaseView> {
  // ignore: unused_field
  final Logger _logger = Logger("case detail view");
  Formats selectedFormat = Formats.timeseries;

  Widget _getUploadForm(Formats format) {
    switch (format) {
      case Formats.obd:
        return UploadObdForm(caseId: widget.caseId);
      case Formats.vcds:
        return UploadVcdsForm(caseId: widget.caseId);
      case Formats.timeseries:
        return UploadTimeseriesForm(caseId: widget.caseId);
      case Formats.omniview:
        return UploadOmniviewForm(caseId: widget.caseId);
      case Formats.picoscope:
        return UploadPicoscopeForm(caseId: widget.caseId);
      case Formats.symptom:
        return UploadSymptomForm(caseId: widget.caseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 68, vertical: 16),
      child: Column(
        children: [
          SegmentedButton(
            showSelectedIcon: false,
            segments: Formats.values.map((v) {
              return ButtonSegment(
                value: v,
                label: Text(v.name.toTitleCase()),
              );
            }).toList(),
            selected: {selectedFormat},
            onSelectionChanged: (Set<Formats> newSelection) {
              setState(() => selectedFormat = newSelection.first);
            },
          ),
          const SizedBox(height: 16),
          _getUploadForm(selectedFormat)
        ],
      ),
    );
  }
}
