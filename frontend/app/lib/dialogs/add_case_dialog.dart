import "dart:async";

import "package:aw40_hub_frontend/dtos/new_case_dto.dart";
import "package:aw40_hub_frontend/exceptions/exceptions.dart";
import "package:aw40_hub_frontend/text_input_formatters/text_input_formatters.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
import "package:easy_localization/easy_localization.dart";
import "package:enum_to_string/enum_to_string.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:logging/logging.dart";
import "package:routemaster/routemaster.dart";

class AddCaseDialog extends StatefulWidget {
  const AddCaseDialog({
    super.key,
  });

  @override
  State<AddCaseDialog> createState() => _AddCaseDialogState();
}

class _AddCaseDialogState extends State<AddCaseDialog> {
  // ignore: unused_field
  final Logger _logger = Logger("add_case_dialog");
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vinController = TextEditingController();
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _occasionController = TextEditingController();
  final TextEditingController _milageController = TextEditingController();

  void _submitAddCaseForm() {
    final FormState? currentFormKeyState = _formKey.currentState;
    if (currentFormKeyState != null && currentFormKeyState.validate()) {
      currentFormKeyState.save();
      final CaseOccasion? caseOccasion = EnumToString.fromString(
        CaseOccasion.values,
        _occasionController.text,
      );
      if (caseOccasion == null) {
        throw AppException(
          exceptionType: ExceptionType.unexpectedNullValue,
          exceptionMessage: "CaseOccasion was null.",
        );
      }
      final int? milage = int.tryParse(_milageController.text);
      if (milage == null) {
        throw AppException(
          exceptionType: ExceptionType.unexpectedNullValue,
          exceptionMessage: "Milage was null.",
        );
      }
      final NewCaseDto newCaseDto = NewCaseDto(
        _vinController.text,
        _customerIdController.text,
        caseOccasion,
        milage,
      );
      unawaited(Routemaster.of(context).pop<NewCaseDto>(newCaseDto));
    }
  }

  Future<void> _onCancel(BuildContext context) async {
    await Routemaster.of(context).pop();
  }

  final title = tr("cases.actions.addCase");

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(title),
      content: AddDialogForm(
        formKey: _formKey,
        vinController: _vinController,
        customerIdController: _customerIdController,
        occasionController: _occasionController,
        milageController: _milageController,
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
          onPressed: _submitAddCaseForm,
          child: Text(tr("general.save")),
        ),
      ],
    );
  }
}

class AddDialogForm extends StatelessWidget {
  const AddDialogForm({
    required this.formKey,
    required this.vinController,
    required this.customerIdController,
    required this.occasionController,
    required this.milageController,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController vinController;
  final TextEditingController customerIdController;
  final TextEditingController occasionController;
  final TextEditingController milageController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            inputFormatters: [UpperCaseTextInputFormatter()],
            decoration: InputDecoration(
              labelText: tr("general.vehicleVin"),
              border: const OutlineInputBorder(),
            ),
            controller: vinController,
            onSaved: (vin) {
              if (vin == null) {
                throw AppException(
                  exceptionType: ExceptionType.unexpectedNullValue,
                  exceptionMessage: "VIN was null, validation failed.",
                );
              }
              if (vin.isEmpty) {
                throw AppException(
                  exceptionType: ExceptionType.unexpectedNullValue,
                  exceptionMessage: "VIN was empty, validation failed.",
                );
              }
            },
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return tr("general.obligatoryField");
              }
              if (value.contains(RegExp("[IOQ]"))) {
                return tr("cases.addCaseDialog.vinCharactersInvalid");
              }
              if (value.length != 17) {
                return tr("cases.addCaseDialog.vinLengthInvalid");
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: tr("general.customerId"),
              border: const OutlineInputBorder(),
            ),
            controller: customerIdController,
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
                  exceptionMessage: "CustomerId was null, validation failed.",
                );
              }
              if (customerId.isEmpty) {
                throw AppException(
                  exceptionType: ExceptionType.unexpectedNullValue,
                  exceptionMessage: "CustomerId was empty, validation failed.",
                );
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  tr("general.occasion"),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              FormField(
                initialValue: CaseOccasion.unknown,
                onSaved: (CaseOccasion? newValue) {
                  if (newValue == null) {
                    throw AppException(
                      exceptionType: ExceptionType.unexpectedNullValue,
                      exceptionMessage: "Occasion was null.",
                    );
                  }
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
                      selected: {field.value},
                      onSelectionChanged: (p0) {
                        final CaseOccasion newVal =
                            p0.isEmpty ? CaseOccasion.unknown : p0.first!;
                        // newCaseDto.occasion = newVal;
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
}
