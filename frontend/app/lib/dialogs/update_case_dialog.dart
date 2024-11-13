import "dart:async";

import "package:aw40_hub_frontend/dtos/case_update_dto.dart";
import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/models/case_model.dart";
import "package:aw40_hub_frontend/utils/constants.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:aw40_hub_frontend/utils/extensions.dart";
import "package:easy_localization/easy_localization.dart";
import "package:enum_to_string/enum_to_string.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:routemaster/routemaster.dart";

class UpdateCaseDialog extends StatefulWidget {
  const UpdateCaseDialog({
    required this.caseModel,
    super.key,
  });

  final CaseModel caseModel;

  @override
  State<UpdateCaseDialog> createState() => _UpdateCaseDialogState();
}

class _UpdateCaseDialogState extends State<UpdateCaseDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _occasionController = TextEditingController();
  final TextEditingController _timestampController = TextEditingController();
  final TextEditingController _milageController = TextEditingController();
  final title = tr("cases.actions.updateCase");

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    _milageController.text = widget.caseModel.milage.toString();
    _timestampController.text =
        widget.caseModel.timestamp.toGermanDateTimeString();
    _occasionController.text =
        EnumToString.convertToString(widget.caseModel.occasion);
    _statusController.text =
        EnumToString.convertToString(widget.caseModel.status);

    return AlertDialog(
      title: Text(title),
      content: UpdateDialogForm(
        formKey: _formKey,
        statusController: _statusController,
        occasionController: _occasionController,
        timestampController: _timestampController,
        milageController: _milageController,
        caseModel: widget.caseModel,
      ),
      actions: [
        TextButton(
          onPressed: () async => _onCancel(context),
          child: Text(
            tr("general.cancel"),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
        TextButton(
          onPressed: _submitUpdateCaseForm,
          child: Text(tr("general.save")),
        ),
      ],
    );
  }

  void _submitUpdateCaseForm() {
    final FormState? currentFormKeyState = _formKey.currentState;
    if (currentFormKeyState != null && currentFormKeyState.validate()) {
      currentFormKeyState.save();
      final CaseStatus? caseStatus = EnumToString.fromString(
        CaseStatus.values,
        _statusController.text,
      );
      if (caseStatus == null) {
        throw AppException(
          exceptionType: ExceptionType.unexpectedNullValue,
          exceptionMessage: "CaseStatus was null.",
        );
      }
      final CaseOccasion? caseOccasion = EnumToString.fromString(
        CaseOccasion.values,
        _occasionController.text,
      );
      final DateTime? timestamp = _timestampController.text.toDateTime();
      if (timestamp == null) {
        throw AppException(
          exceptionType: ExceptionType.unexpectedNullValue,
          exceptionMessage: "Timestamp was null.",
        );
      }
      final int? milage = int.tryParse(_milageController.text);
      if (milage == null) {
        throw AppException(
          exceptionType: ExceptionType.unexpectedNullValue,
          exceptionMessage: "Milage was null.",
        );
      }

      final CaseUpdateDto caseUpdateDto = CaseUpdateDto(
        timestamp,
        caseOccasion ?? CaseOccasion.unknown,
        milage,
        caseStatus,
      );
      unawaited(Routemaster.of(context).pop<CaseUpdateDto>(caseUpdateDto));
    }
  }

  Future<void> _onCancel(BuildContext context) async {
    await Routemaster.of(context).pop();
  }

  @override
  void dispose() {
    _statusController.dispose();
    _milageController.dispose();
    _occasionController.dispose();
    _timestampController.dispose();
    super.dispose();
  }
}

class UpdateDialogForm extends StatelessWidget {
  const UpdateDialogForm({
    required this.formKey,
    required this.statusController,
    required this.occasionController,
    required this.timestampController,
    required this.milageController,
    required this.caseModel,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController statusController;
  final TextEditingController occasionController;
  final TextEditingController timestampController;
  final TextEditingController milageController;
  final CaseModel caseModel;

  @override
  Widget build(BuildContext context) {
    CaseStatus selectedStatus = caseModel.status;
    CaseOccasion selectedOccasion = caseModel.occasion;

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr("general.status"),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(width: 16),
              FormField(
                onSaved: (CaseStatus? newValue) {
                  if (newValue == null) return;
                  statusController.text =
                      EnumToString.convertToString(newValue);
                },
                builder: (FormFieldState<CaseStatus> field) {
                  return SizedBox(
                    width: 275,
                    child: SegmentedButton(
                      emptySelectionAllowed: true,
                      segments: <ButtonSegment<CaseStatus>>[
                        ButtonSegment<CaseStatus>(
                          value: CaseStatus.open,
                          label: Text(tr("cases.status.open")),
                        ),
                        ButtonSegment<CaseStatus>(
                          value: CaseStatus.closed,
                          label: Text(tr("cases.status.closed")),
                        ),
                      ],
                      selected: {selectedStatus},
                      onSelectionChanged: (p0) {
                        final CaseStatus newVal = p0.first;
                        selectedStatus = newVal;
                        statusController.text =
                            EnumToString.convertToString(newVal);
                        field.didChange(newVal);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr("general.occasion"),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(width: 16),
              FormField(
                onSaved: (CaseOccasion? newValue) {
                  if (newValue == null) return;
                  occasionController.text =
                      EnumToString.convertToString(newValue);
                },
                builder: (FormFieldState<CaseOccasion> field) {
                  return SizedBox(
                    width: 275,
                    child: SegmentedButton(
                      emptySelectionAllowed: true,
                      segments: <ButtonSegment<CaseOccasion>>[
                        ButtonSegment<CaseOccasion>(
                          value: CaseOccasion.service_routine,
                          label: Text(tr("cases.occasions.service")),
                        ),
                        ButtonSegment<CaseOccasion>(
                          value: CaseOccasion.problem_defect,
                          label: Text(tr("cases.occasions.problem")),
                        ),
                      ],
                      selected: {selectedOccasion},
                      onSelectionChanged: (p0) {
                        final CaseOccasion newVal =
                            p0.isEmpty ? CaseOccasion.unknown : p0.first;
                        selectedOccasion = newVal;
                        occasionController.text =
                            EnumToString.convertToString(newVal);
                        field.didChange(newVal);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            readOnly: true,
            controller: timestampController,
            decoration: InputDecoration(
              labelText: tr("general.date"),
              border: const OutlineInputBorder(),
            ),
            onTap: () async {
              final DateTime? selectedDateTime = await pickDateTime(context);
              if (selectedDateTime != null) {
                timestampController.text =
                    selectedDateTime.toGermanDateTimeString();
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: milageController,
            decoration: InputDecoration(
              labelText: tr("general.milage"),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return tr("general.obligatoryField");
              }
              return null;
            },
            onSaved: (customerId) {
              if (customerId == null) {
                throw AppException(
                  exceptionType: ExceptionType.unexpectedNullValue,
                  exceptionMessage: "Milage was null, validation failed.",
                );
              }
              if (customerId.isEmpty) {
                throw AppException(
                  exceptionType: ExceptionType.unexpectedNullValue,
                  exceptionMessage: "Milage was empty, validation failed.",
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<DateTime?> pickDateTime(BuildContext context) async {
    final Future<DateTime?> datePicker = showDatePicker(
      context: context,
      initialDate: caseModel.timestamp,
      firstDate: DateTime(firstDateInDialog),
      lastDate: DateTime(lastDateInDialog),
    );

    final Future<TimeOfDay?> timePicker = showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        caseModel.timestamp,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? Container(),
        );
      },
    );

    final DateTime? date = await datePicker;
    if (date == null) return null;

    final TimeOfDay? time = await timePicker;
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}
