import "package:aw40_hub_frontend/components/file_upload_form_component.dart";
import "package:aw40_hub_frontend/forms/base_upload_form.dart";
import "package:aw40_hub_frontend/providers/diagnosis_provider.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:provider/provider.dart";

class UploadOmniviewForm extends StatefulWidget {
  const UploadOmniviewForm({super.key});

  @override
  State<UploadOmniviewForm> createState() => _UploadOmniviewFormState();
}

class _UploadOmniviewFormState extends State<UploadOmniviewForm> {
  //final Logger _logger = Logger("UploadOmniviewForm");
  Uint8List? _file;
  String? _filename;
  final TextEditingController _controllerFilename = TextEditingController();
  final TextEditingController _componentController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _samplingRateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseUploadForm(
      content: Column(
        children: [
          FileUploadFormComponent(onFileDrop: (Uint8List file, String name) {
            _file = file;
            _filename = name;
          }),
          const SizedBox(height: 16),
          TextFormField(
            controller: _controllerFilename,
            minLines: 1,
            maxLines: null,
            //keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              labelText: "Filename",
              hintText: "Enter a Filename.",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _componentController,
            minLines: 1,
            maxLines: null,
            //keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              labelText: "Components",
              hintText: "Enter a Component.",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _durationController,
            minLines: 1,
            //keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              labelText: "Duration",
              hintText: "Enter a Duration.",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _samplingRateController,
            minLines: 1,
            //keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              labelText: "Sampling Rate",
              hintText: "Enter a Sampling Rate.",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      onSubmit: _onSubmit,
    );
  }

  Future<void> _onSubmit() async {
    final provider = Provider.of<DiagnosisProvider>(context, listen: false);
    final messengerState = ScaffoldMessenger.of(context);

    if (_controllerFilename.text.isEmpty ||
        _componentController.text.isEmpty ||
        _samplingRateController.text.isEmpty ||
        _durationController.text.isEmpty) {
      messengerState.showSnackBar(
        SnackBar(content: Text(tr("Please fill in all fields."))),
      );
      return;
    }

    final String? filename = _filename;
    if (filename == null) return;
    final String component = _componentController.text;
    final int? samplingRate = int.tryParse(_samplingRateController.text);
    final int? duration = int.tryParse(_durationController.text);
    if (samplingRate == null || duration == null) {
      messengerState.showSnackBar(
        SnackBar(content: Text(tr("Invalid numbers in fields."))),
      );
      return;
    }

    final Uint8List? file = _file;
    if (file == null) {
      messengerState.showSnackBar(
        SnackBar(
          content: Text(tr("diagnoses.details.uploadDataErrorMessage")),
        ),
      );
      return;
    }

    final bool result = await provider.uploadOmniviewData(
      provider.diagnosisCaseId,
      file,
      filename,
      component,
      samplingRate,
      duration,
    );
    final String snackBarText = result
        ? tr("diagnoses.details.uploadDataSuccessMessage")
        : tr("diagnoses.details.uploadDataErrorMessage");
    messengerState.showSnackBar(SnackBar(content: Text(snackBarText)));
  }
}
