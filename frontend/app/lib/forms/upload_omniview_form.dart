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
  final TextEditingController _controllerFilename = TextEditingController();
  final TextEditingController _controllerComponent = TextEditingController();
  final TextEditingController _controllerDuration = TextEditingController();
  final TextEditingController _controllerSamplingRate = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseUploadForm(
      content: Column(
        children: [
          FileUploadFormComponent(onFileDrop: (Uint8List file) => _file = file),
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
            controller: _controllerComponent,
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
            controller: _controllerDuration,
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
            controller: _controllerSamplingRate,
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
        _controllerComponent.text.isEmpty ||
        _controllerSamplingRate.text.isEmpty ||
        _controllerDuration.text.isEmpty) {
      messengerState.showSnackBar(
        SnackBar(content: Text(tr("Please fill in all fields."))),
      );
      return;
    }
    final String filename = _controllerFilename.text;
    final String component = _controllerComponent.text;
    final int? samplingRate = int.tryParse(_controllerSamplingRate.text);
    final int? duration = int.tryParse(_controllerDuration.text);
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
