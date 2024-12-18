import "package:aw40_hub_frontend/forms/base_upload_form.dart";
import "package:aw40_hub_frontend/providers/case_provider.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:easy_localization/easy_localization.dart";
import "package:enum_to_string/enum_to_string.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class UploadSymptomForm extends StatefulWidget {
  const UploadSymptomForm({required this.caseId, super.key});

  final String caseId;

  @override
  State<UploadSymptomForm> createState() => _UploadSymptomFormState();
}

class _UploadSymptomFormState extends State<UploadSymptomForm> {
  final TextEditingController _componentController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  SymptomLabel? selectedLabel;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: BaseUploadForm(
        content: Column(
          children: [
            TextFormField(
              validator: _validation,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _componentController,
              minLines: 1,
              maxLines: null,
              decoration: InputDecoration(
                labelText: tr("forms.symptom.component.label"),
                hintText: tr("forms.symptom.component.hint"),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownMenu<SymptomLabel>(
              controller: _labelController,
              label: Text(tr("forms.symptom.label")),
              hintText: tr("forms.optional"),
              onSelected: (SymptomLabel? symptomLabel) {
                setState(() {
                  selectedLabel = symptomLabel;
                });
              },
              dropdownMenuEntries:
                  SymptomLabel.values.map<DropdownMenuEntry<SymptomLabel>>(
                (SymptomLabel symptomLabel) {
                  return DropdownMenuEntry<SymptomLabel>(
                    value: symptomLabel,
                    label: symptomLabel.name,
                  );
                },
              ).toList(),
            ),
          ],
        ),
        onSubmit: _onSubmit,
      ),
    );
  }

  String? _validation(String? value) {
    if (value == null || value.isEmpty) {
      return tr("forms.validation.enterText");
    }
    return null;
  }

  Future<void> _onSubmit() async {
    final messengerState = ScaffoldMessenger.of(context);
    final FormState? formState = _formKey.currentState;
    if (formState != null && !formState.validate()) return;

    final provider = Provider.of<CaseProvider>(context, listen: false);

    final String component = _componentController.text;
    final SymptomLabel? label =
        EnumToString.fromString(SymptomLabel.values, _labelController.text);
    if (label == null) return;

    final bool result = await provider.uploadSymptomData(
      widget.caseId,
      component,
      label,
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
