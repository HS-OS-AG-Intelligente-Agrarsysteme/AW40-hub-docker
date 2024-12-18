import "package:aw40_hub_frontend/forms/base_upload_form.dart";
import "package:aw40_hub_frontend/providers/case_provider.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:easy_localization/easy_localization.dart";
import "package:enum_to_string/enum_to_string.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class UploadTimeseriesForm extends StatefulWidget {
  const UploadTimeseriesForm({required this.caseId, super.key});

  final String caseId;

  @override
  State<UploadTimeseriesForm> createState() => _UploadTimeseriesFormState();
}

class _UploadTimeseriesFormState extends State<UploadTimeseriesForm> {
  final TextEditingController _componentController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _samplingRateController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _signalController = TextEditingController();
  TimeseriesDataLabel? selectedLabel;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: BaseUploadForm(
        content: Column(
          children: [
            TextFormField(
              validator: _textValidation,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _componentController,
              decoration: InputDecoration(
                labelText: tr("forms.timeseries.component.label"),
                hintText: tr("forms.timeseries.component.hint"),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownMenu<TimeseriesDataLabel>(
              controller: _labelController,
              label: Text(tr("forms.timeseries.label")),
              onSelected: (TimeseriesDataLabel? timeseriesDataLabel) {
                setState(() {
                  selectedLabel = timeseriesDataLabel;
                });
              },
              dropdownMenuEntries: TimeseriesDataLabel.values
                  .map<DropdownMenuEntry<TimeseriesDataLabel>>(
                (TimeseriesDataLabel timeseriesDataLabel) {
                  return DropdownMenuEntry<TimeseriesDataLabel>(
                    value: timeseriesDataLabel,
                    label: timeseriesDataLabel.name,
                  );
                },
              ).toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              validator: _numberValidation,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: tr("forms.timeseries.duration.label"),
                hintText: tr("forms.timeseries.duration.hint"),
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
                labelText: tr("forms.timeseries.samplingRate.label"),
                hintText: tr("forms.timeseries.samplingRate.hint"),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              validator: _signalValidation,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _signalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: tr("forms.timeseries.signal.label"),
                hintText: tr("forms.timeseries.signal.hint"),
                suffixText: tr("forms.timeseries.signal.suffix"),
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

  String? _signalValidation(String? value) {
    if (value == null || value.isEmpty) {
      return tr("forms.validation.enterSignal");
    }
    final List<String> parts = value.split(",");
    for (final String part in parts) {
      if (part.trim().isEmpty || int.tryParse(part.trim()) == null) {
        return tr("forms.validation.separateWithComma");
      }
    }
    return null;
  }

  Future<void> _onSubmit() async {
    final FormState? formState = _formKey.currentState;
    if (formState != null && !formState.validate()) return;

    final messengerState = ScaffoldMessenger.of(context);
    final provider = Provider.of<CaseProvider>(context, listen: false);

    final String component = _componentController.text;
    final TimeseriesDataLabel? label = EnumToString.fromString(
      TimeseriesDataLabel.values,
      _labelController.text,
    );
    if (label == null) return;
    final int? samplingRate = int.tryParse(_samplingRateController.text);
    final int? duration = int.tryParse(_durationController.text);
    final List<int> signal = _signalController.text
        .split(",")
        .map((part) => int.parse(part.trim()))
        .toList();

    if (samplingRate == null || duration == null || signal.contains(null)) {
      messengerState.showSnackBar(
        SnackBar(content: Text(tr("forms.validation.invalidNumber"))),
      );
      return;
    }

    final bool result = await provider.uploadTimeseriesData(
      widget.caseId,
      component,
      label,
      samplingRate,
      duration,
      signal,
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
