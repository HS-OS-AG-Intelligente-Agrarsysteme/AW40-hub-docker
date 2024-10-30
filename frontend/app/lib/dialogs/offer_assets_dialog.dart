import "dart:async";

import "package:aw40_hub_frontend/dtos/new_case_dto.dart";
import "package:aw40_hub_frontend/dtos/new_customer_dto.dart";
import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/forms/offer_assets_form.dart";
import "package:aw40_hub_frontend/forms/update_customer_form.dart";
import "package:aw40_hub_frontend/models/customer_model.dart";
import "package:aw40_hub_frontend/providers/customer_provider.dart";
import "package:aw40_hub_frontend/text_input_formatters/upper_case_text_input_formatter.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:easy_localization/easy_localization.dart";
import "package:enum_to_string/enum_to_string.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:logging/logging.dart";
import "package:provider/provider.dart";
import "package:routemaster/routemaster.dart";

class OfferAssetsDialog extends StatefulWidget {
  const OfferAssetsDialog({
    super.key,
  });

  @override
  State<OfferAssetsDialog> createState() => _OfferAssetsDialogState();
}

class _OfferAssetsDialogState extends State<OfferAssetsDialog> {
  // ignore: unused_field
  final Logger _logger = Logger("add_case_dialog");
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _filenameController = TextEditingController();
  final TextEditingController _assetsDatatypeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _licenceController = TextEditingController();

  final title = tr("cases.actions.addCase");

  @override
  Widget build(BuildContext context) {
    final CustomerProvider customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(title),
      content: OfferAssetsDialogForm(
        formKey: _formKey,
        priceController: _priceController,
        filenameController: _filenameController,
        assetsDatatypeController: _assetsDatatypeController,
        nameController: _nameController,
        detailsController: _detailsController,
        authorController: _authorController,
        licenceController: _licenceController,
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
          onPressed: () async {
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

              String customerId = lastSelectedCustomer?.id ?? "";
              if (customerId.isEmpty) {
                final NewCustomerDto newCustomerDto = _createNewCustomerDto();
                final CustomerModel? newCustomer =
                    await customerProvider.addCustomer(newCustomerDto);

                if (newCustomer?.id == null) {
                  throw AppException(
                    exceptionType: ExceptionType.unexpectedNullValue,
                    exceptionMessage: newCustomer == null
                        ? "new customer was null."
                        : "ID of new customer was null.",
                  );
                }
                customerId = newCustomer!.id!;
              }

              final NewCaseDto newCaseDto = NewCaseDto(
                _vinController.text,
                customerId,
                caseOccasion,
                milage,
              );
              // ignore: use_build_context_synchronously
              unawaited(Routemaster.of(context).pop<NewCaseDto>(newCaseDto));
            }
          },
          child: Text(tr("general.save")),
        ),
      ],
    );
  }

  Future<void> _onCancel(BuildContext context) async {
    await Routemaster.of(context).pop();
  }
}

// ignore: must_be_immutable
class OfferAssetsDialogForm extends StatefulWidget {
  OfferAssetsDialogForm({
    required this.formKey,
    required this.priceController,
    required this.filenameController,
    required this.assetsDatatypeController,
    required this.nameController,
    required this.detailsController,
    required this.authorController,
    required this.licenceController,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController priceController;
  TextEditingController filenameController;
  final TextEditingController assetsDatatypeController;
  final TextEditingController nameController;
  final TextEditingController detailsController;
  final TextEditingController authorController;
  final TextEditingController licenceController;

  @override
  State<OfferAssetsDialogForm> createState() => _AddCaseDialogFormState();
}

class _AddCaseDialogFormState extends State<OfferAssetsDialogForm> {
  bool showAddCustomerFields = false;

  List<CustomerModel>? customerModels;
  CustomerModel? lastSelectedCustomer;
  late String _previousCustomerIdText;

  @override
  void initState() {
    super.initState();
    _previousCustomerIdText = widget.customerIdController.text;
    widget.customerIdController.addListener(_onCustomerIdChanged);
  }

  @override
  void dispose() {
    widget.customerIdController.removeListener(_onCustomerIdChanged);
    super.dispose();
  }

  void _onCustomerIdChanged() {
    final String currentCustomerIdText = widget.customerIdController.text;

    if (currentCustomerIdText.length < _previousCustomerIdText.length) {
      lastSelectedCustomer = null;
      widget.updateCustomer(null);
      setState(() {});
    }

    _previousCustomerIdText = currentCustomerIdText;
  }

  @override
  Widget build(BuildContext context) {
    final CustomerProvider customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);
    if (customerModels == null) {
      return FutureBuilder(
        // ignore: discarded_futures
        future: customerProvider.getCustomers(0, 30),
        builder: (
          BuildContext context,
          AsyncSnapshot<List<CustomerModel>> snapshot,
        ) {
          if (snapshot.connectionState != ConnectionState.done ||
              !snapshot.hasData) {
            return const SizedBox(
              height: 516,
              width: 400,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          customerModels = snapshot.data;
          if (customerModels == null) {
            throw AppException(
              exceptionType: ExceptionType.notFound,
              exceptionMessage: "Received no customers.",
            );
          }
          return _buildAddCaseDialogForm();
        },
      );
    } else {
      // Wenn customerModels nicht null sind, direkt das UI aufbauen
      return Form(
      key: widget.formKey,
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OfferAssetsForm(priceController: widget.priceController, dataNameController: widget.dataNameController, nameController, descriptionController, authorController, assetsDataType, license )
            OfferAssetsForm(
              priceController: _priceController,
              lastNameController: lastNameController,
              phoneController: phoneController,
              emailController: emailController,
              postcodeController: postcodeController,
              cityController: cityController,
              streetController: streetController,
              housenumberController: housenumberController,
            )
          ],
        ),
      ),
    );();
    }
  }

  Widget _buildAddCaseDialogForm() {
    return Form(
      key: widget.formKey,
      child: SizedBox(
        height: 518,
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 227,
                  height: 66,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    inputFormatters: [UpperCaseTextInputFormatter()],
                    decoration: InputDecoration(
                      labelText: tr("general.vehicleVin"),
                      border: const OutlineInputBorder(),
                      errorStyle: const TextStyle(height: 0.1),
                    ),
                    controller: widget.vinController,
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
                      if (value.length != 17) {
                        return tr("cases.addCaseDialog.vinLengthInvalid");
                      }
                      if (value.contains(RegExp("[IOQ]"))) {
                        return tr(
                          "cases.addCaseDialog.vinCharactersInvalid",
                        );
                      }

                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 157,
                  height: 66,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: widget.milageController,
                    decoration: InputDecoration(
                      labelText: tr("general.milage"),
                      border: const OutlineInputBorder(),
                      errorStyle: const TextStyle(height: 0.1),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return tr("general.obligatoryField");
                      }
                      return null;
                    },
                    onSaved: (value) {
                      if (value == null) {
                        throw AppException(
                          exceptionType: ExceptionType.unexpectedNullValue,
                          exceptionMessage:
                              "Milage was null, validation failed.",
                        );
                      }
                      if (value.isEmpty) {
                        throw AppException(
                          exceptionType: ExceptionType.unexpectedNullValue,
                          exceptionMessage:
                              "Milage was empty, validation failed.",
                        );
                      }
                    },
                  ),
                ),
              ],
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
                  initialValue: CaseOccasion.fromString(
                    widget.occasionController.text,
                  ),
                  onSaved: (CaseOccasion? newValue) {
                    if (newValue == null) {
                      throw AppException(
                        exceptionType: ExceptionType.unexpectedNullValue,
                        exceptionMessage: "Occasion was null.",
                      );
                    }
                    widget.occasionController.text =
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
                          widget.occasionController.text =
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
              children: [
                Tooltip(
                  message: tr("cases.addCaseDialog.customerTooltip"),
                  child: DropdownMenu<String>(
                    enabled: !showAddCustomerFields,
                    controller: showAddCustomerFields
                        ? null
                        : widget.customerIdController,
                    label: Text(tr("general.customer")),
                    hintText: tr("forms.optional"),
                    leadingIcon: (lastSelectedCustomer == null)
                        ? null
                        : const Icon(
                            Icons.check,
                            color: Colors.green,
                          ),
                    enableFilter: true,
                    width: 320,
                    menuHeight: 350,
                    onSelected: (value) async =>
                        _onCustomerSelection(context, value),
                    menuStyle: const MenuStyle(alignment: Alignment.bottomLeft),
                    dropdownMenuEntries:
                        customerModels!.map<DropdownMenuEntry<String>>(
                      (CustomerModel customer) {
                        return DropdownMenuEntry<String>(
                          value: customer.id ?? "",
                          label: "${customer.firstname} ${customer.lastname}",
                        );
                      },
                    ).toList(),
                  ),
                ),
                const SizedBox(width: 20),
                if (showAddCustomerFields)
                  Tooltip(
                    message: tr(
                      "cases.addCaseDialog.cancelCreateNewCustomerTooltip",
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        showAddCustomerFields = false;
                        setState(() {});
                      },
                    ),
                  )
                else
                  Tooltip(
                    message: tr(
                      "cases.addCaseDialog.createNewCustomerTooltip",
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.person_add),
                      onPressed: () {
                        widget.customerIdController.clear();
                        lastSelectedCustomer = null;
                        widget.updateCustomer(null);
                        showAddCustomerFields = true;
                        setState(() {});
                      },
                    ),
                  ),
              ],
            ),
            if (showAddCustomerFields)
              CustomerAttributesForm(
                firstNameController: widget.firstNameController,
                lastNameController: widget.lastNameController,
                phoneController: widget.phoneController,
                emailController: widget.emailController,
                postcodeController: widget.postcodeController,
                cityController: widget.cityController,
                streetController: widget.streetController,
                housenumberController: widget.housenumberController,
              )
          ],
        ),
      ),
    );
  }