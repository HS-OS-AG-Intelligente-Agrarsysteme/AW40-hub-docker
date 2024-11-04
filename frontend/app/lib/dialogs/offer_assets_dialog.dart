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
  final ValueNotifier<AssetsDatatype?> _assetsDatatypeController = ValueNotifier<AssetsDatatype?>(null,);
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final ValueNotifier<Licence?> _licenseController = ValueNotifier<Licence?>(null,);

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
        licenseController: _licenseController,
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
    required this.licenseController,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController priceController;
  final TextEditingController filenameController;
  final ValueNotifier<AssetsDatatype?> assetsDatatypeController;
  final TextEditingController nameController;
  final TextEditingController detailsController;
  final TextEditingController authorController;
  final ValueNotifier<Licence?> licenseController;

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
            OfferAssetsForm(
              priceController: widget.priceController,
              filenameController: widget.filenameController,
              assetsDatatypeController: widget.assetsDatatypeController,
              nameController: widget.nameController,
              detailsController: widget.detailsController,
              authorController: widget.authorController,
              licenseController: widget.licenseController,
            )
          ],
        ),
      ),
    );();
    }
  }
}
