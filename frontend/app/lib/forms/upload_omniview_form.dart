import "package:aw40_hub_frontend/components/file_upload_form_component.dart";
import "package:aw40_hub_frontend/forms/base_upload_form.dart";
import "package:aw40_hub_frontend/providers/diagnosis_provider.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class UploadOmniviewForm extends StatefulWidget {
  const UploadOmniviewForm({super.key});

  @override
  State<UploadOmniviewForm> createState() => _UploadOmniviewFormState();
}

class _UploadOmniviewFormState extends State<UploadOmniviewForm> {
  Uint8List? _file;
  String? _filename;
  final TextEditingController _componentController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _samplingRateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: BaseUploadForm(
        content: Column(
          children: [
            FileUploadFormComponent(
              onFileDrop: (Uint8List file, String name) {
                _file = file;
                _filename = name;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              validator: _validation,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _componentController,
              minLines: 1,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: "Components",
                hintText: "Enter a Component.",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              validator: _validation,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _durationController,
              minLines: 1,
              decoration: const InputDecoration(
                labelText: "Duration",
                hintText: "Enter a Duration.",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              validator: _validation,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _samplingRateController,
              minLines: 1,
              decoration: const InputDecoration(
                labelText: "Sampling Rate",
                hintText: "Enter a Sampling Rate.",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        onSubmit: _onSubmit,
      ),
    );
  }

  String? _validation(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter some text";
    }
    return null;
  }

  Future<void> _onSubmit() async {
    final messengerState = ScaffoldMessenger.of(context);
    final Uint8List? file = _file;
    if (file == null) {
      messengerState.showSnackBar(
        SnackBar(
          content: Text(tr("diagnoses.details.uploadDataErrorMessage")),
        ),
      );
      return;
    }
    final FormState? formState = _formKey.currentState;
    if (formState != null && !formState.validate()) return;

    final provider = Provider.of<DiagnosisProvider>(context, listen: false);
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
