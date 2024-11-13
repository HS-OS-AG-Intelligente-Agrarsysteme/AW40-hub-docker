import "dart:async";

import "package:aw40_hub_frontend/dtos/new_case_dto.dart";
import "package:aw40_hub_frontend/dtos/new_customer_dto.dart";
import "package:aw40_hub_frontend/exceptions/app_exception.dart";
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

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _postcodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _housenumberController = TextEditingController();

  CustomerModel? lastSelectedCustomer;

  final title = tr("cases.actions.addCase");

  @override
  Widget build(BuildContext context) {
    final CustomerProvider customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(title),
      content: AddCaseDialogForm(
        formKey: _formKey,
        vinController: _vinController,
        customerIdController: _customerIdController,
        occasionController: _occasionController,
        milageController: _milageController,
        cityController: _cityController,
        firstNameController: _firstNameController,
        housenumberController: _housenumberController,
        lastNameController: _lastNameController,
        streetController: _streetController,
        postcodeController: _postcodeController,
        emailController: _emailController,
        phoneController: _phoneController,
        updateCustomer: (CustomerModel? newCustomer) {
          lastSelectedCustomer = newCustomer;
        },
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

  NewCustomerDto _createNewCustomerDto() {
    final firstname = _firstNameController.text;
    final lastname = _lastNameController.text;
    final email = _emailController.text.isEmpty ? null : _emailController.text;
    final phone = _phoneController.text.isEmpty ? null : _phoneController.text;
    final street =
        _streetController.text.isEmpty ? null : _streetController.text;
    final housenumber = _housenumberController.text.isEmpty
        ? null
        : _housenumberController.text;
    final postcode =
        _postcodeController.text.isEmpty ? null : _postcodeController.text;
    final city = _cityController.text.isEmpty ? null : _cityController.text;

    return NewCustomerDto(
      firstname,
      lastname,
      email,
      phone,
      street,
      housenumber,
      postcode,
      city,
    );
  }

  Future<void> _onCancel(BuildContext context) async {
    await Routemaster.of(context).pop();
  }
}

// ignore: must_be_immutable
class AddCaseDialogForm extends StatefulWidget {
  AddCaseDialogForm({
    required this.formKey,
    required this.vinController,
    required this.customerIdController,
    required this.occasionController,
    required this.milageController,
    required this.firstNameController,
    required this.lastNameController,
    required this.postcodeController,
    required this.cityController,
    required this.streetController,
    required this.housenumberController,
    required this.phoneController,
    required this.emailController,
    required this.updateCustomer,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController vinController;
  TextEditingController customerIdController;
  final TextEditingController occasionController;
  final TextEditingController milageController;

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;

  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController postcodeController;
  final TextEditingController cityController;
  final TextEditingController streetController;
  final TextEditingController housenumberController;

  final Function(CustomerModel?) updateCustomer;

  @override
  State<AddCaseDialogForm> createState() => _AddCaseDialogFormState();
}

class _AddCaseDialogFormState extends State<AddCaseDialogForm> {
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
      return _buildAddCaseDialogForm();
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

  Future<void> _onCustomerSelection(
    BuildContext context,
    String? value,
  ) async {
    final customer = _getCustomerById(value);
    if (customer == null) return;
    await _showConfirmSelectCustomerDialog(context, customer)
        .then((bool? dialogResult) async {
      if (dialogResult ?? false) {
        widget.updateCustomer(customer);
        lastSelectedCustomer = customer;
      } else if (lastSelectedCustomer == null) {
        widget.customerIdController.clear();
      } else {
        final CustomerModel customer = lastSelectedCustomer!;
        widget.customerIdController.text =
            "${customer.firstname} ${customer.lastname}";
      }
      setState(() {});
    });
  }

  CustomerModel? _getCustomerById(String? id) {
    if (customerModels == null || id == null) return null;
    final List<CustomerModel?> customerModels_ = customerModels!;
    try {
      return customerModels_.firstWhere((element) => element?.id == id);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return null;
    }
  }

  Future<bool?> _showConfirmSelectCustomerDialog(
    BuildContext context,
    CustomerModel customer,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tr("cases.addCaseDialog.confirmDialog.title")),
          content: Text(
            tr(
              "cases.addCaseDialog.confirmDialog.description",
              namedArgs: {
                "customer": "${customer.firstname} ${customer.lastname}"
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(tr("general.no")),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(
                tr("general.yes"),
              ),
            ),
          ],
        );
      },
    );
  }
}
