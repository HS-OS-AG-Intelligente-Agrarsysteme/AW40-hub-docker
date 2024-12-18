import "package:aw40_hub_frontend/components/file_upload_form_component.dart";
import "package:aw40_hub_frontend/forms/base_upload_form.dart";
import "package:aw40_hub_frontend/providers/case_provider.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class UploadOmniviewForm extends StatefulWidget {
  const UploadOmniviewForm({required this.caseId, super.key});

  final String caseId;

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
              validator: _textValidation,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _componentController,
              decoration: InputDecoration(
                labelText: tr("forms.omniview.component.label"),
                hintText: tr("forms.omniview.component.hint"),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              validator: _numberValidation,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: tr("forms.omniview.duration.label"),
                hintText: tr("forms.omniview.duration.hint"),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              validator: _numberValidation,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _samplingRateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: tr("forms.omniview.samplingRate.label"),
                hintText: tr("forms.omniview.samplingRate.hint"),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        onSubmit: _onSubmit,
      ),
    );
  }

  String? _textValidation(String? value) {
    if (value == null || value.isEmpty) {
      return tr("forms.validation.enterText");
    }
    return null;
  }

  String? _numberValidation(String? value) {
    if (value == null || value.isEmpty) {
      return tr("forms.validation.enterNumber");
    }
    final int? numberValue = int.tryParse(value);
    if (numberValue == null) {
      return tr("forms.validation.enterValidNumber");
    }
    return null;
  }

  Future<void> _onSubmit() async {
    final messengerState = ScaffoldMessenger.of(context);
    final Uint8List? file = _file;
    if (file == null) {
      messengerState.showSnackBar(
        SnackBar(
          content: Text(tr("diagnoses.details.uploadDragAndDropfailed")),
        ),
      );
      return;
    }
    final FormState? formState = _formKey.currentState;
    if (formState != null && !formState.validate()) return;

    final provider = Provider.of<CaseProvider>(context, listen: false);
    final String? filename = _filename;
    if (filename == null) return;

    final String component = _componentController.text;
    final int? samplingRate = int.tryParse(_samplingRateController.text);
    final int? duration = int.tryParse(_durationController.text);

    if (samplingRate == null || duration == null) {
      messengerState.showSnackBar(
        SnackBar(content: Text(tr("forms.validation.invalidNumber"))),
      );
      return;
    }

    final bool result = await provider.uploadOmniviewData(
      widget.caseId,
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

    _closeForm();
  }

  void _closeForm() {
    Navigator.of(context).pop();
  }
}
