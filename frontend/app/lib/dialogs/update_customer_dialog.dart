import "dart:async";

import "package:aw40_hub_frontend/dtos/customer_update_dto.dart";
import "package:aw40_hub_frontend/forms/update_customer_form.dart";
import "package:aw40_hub_frontend/models/customer_model.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:routemaster/routemaster.dart";

class UpdateCustomerDialog extends StatefulWidget {
  const UpdateCustomerDialog({
    required this.customerModel,
    super.key,
  });

  final CustomerModel customerModel;

  @override
  State<UpdateCustomerDialog> createState() => _UpdateCustomerDialogState();
}

class _UpdateCustomerDialogState extends State<UpdateCustomerDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _postcodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _housenumberController = TextEditingController();

  final title = tr("customers.actions.updateCustomer");

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    _firstNameController.text = widget.customerModel.firstname;
    _lastNameController.text = widget.customerModel.lastname;
    _phoneController.text = widget.customerModel.phone ?? "";
    _emailController.text = widget.customerModel.email ?? "";
    _postcodeController.text = widget.customerModel.postcode ?? "";
    _cityController.text = widget.customerModel.city ?? "";
    _streetController.text = widget.customerModel.street ?? "";
    _housenumberController.text = widget.customerModel.housenumber ?? "";

    return AlertDialog(
      title: Text(title),
      content: UpdateDialogForm(
        formKey: _formKey,
        firstNameController: _firstNameController,
        lastNameController: _lastNameController,
        phoneController: _phoneController,
        emailController: _emailController,
        streetController: _streetController,
        housenumberController: _housenumberController,
        postcodeController: _postcodeController,
        cityController: _cityController,
        customerModel: widget.customerModel,
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
          onPressed: _submitUpdateCustomerForm,
          child: Text(tr("general.save")),
        ),
      ],
    );
  }

  void _submitUpdateCustomerForm() {
    final FormState? currentFormKeyState = _formKey.currentState;
    if (currentFormKeyState != null && currentFormKeyState.validate()) {
      currentFormKeyState.save();

      final String firstname = _firstNameController.text;
      final String lastname = _lastNameController.text;
      final String? email =
          _emailController.text.isEmpty ? null : _emailController.text;
      final String? phone =
          _phoneController.text.isEmpty ? null : _phoneController.text;
      final String? street =
          _streetController.text.isEmpty ? null : _streetController.text;
      final String? housenumber = _housenumberController.text.isEmpty
          ? null
          : _housenumberController.text;
      final String? postcode =
          _postcodeController.text.isEmpty ? null : _postcodeController.text;
      final String? city =
          _cityController.text.isEmpty ? null : _cityController.text;

      final CustomerUpdateDto customerUpdateDto = CustomerUpdateDto(
        firstname,
        lastname,
        email,
        phone,
        street,
        housenumber,
        postcode,
        city,
      );
      unawaited(
        Routemaster.of(context).pop<CustomerUpdateDto>(customerUpdateDto),
      );
    }
  }

  Future<void> _onCancel(BuildContext context) async {
    await Routemaster.of(context).pop();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _postcodeController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _housenumberController.dispose();
    super.dispose();
  }
}

class UpdateDialogForm extends StatelessWidget {
  const UpdateDialogForm({
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneController,
    required this.emailController,
    required this.postcodeController,
    required this.cityController,
    required this.streetController,
    required this.housenumberController,
    required this.customerModel,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;

  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController postcodeController;
  final TextEditingController cityController;
  final TextEditingController streetController;
  final TextEditingController housenumberController;
  final CustomerModel customerModel;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomerAttributesForm(
              firstNameController: firstNameController,
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
    );
  }
}
