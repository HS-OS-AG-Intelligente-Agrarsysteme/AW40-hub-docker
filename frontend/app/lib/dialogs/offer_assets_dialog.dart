import "dart:async";

import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/forms/offer_assets_form.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
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
  final Logger _logger = Logger("offer_assets_dialog");
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _filenameController = TextEditingController();
  final ValueNotifier<AssetsDatatype?> _assetsDatatypeController =
      ValueNotifier<AssetsDatatype?>(
    null,
  );
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final ValueNotifier<Licence?> _licenseController = ValueNotifier<Licence?>(
    null,
  );

  final title = tr("assets.offerAssets");

  @override
  Widget build(BuildContext context) {
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

              final double? price = double.tryParse(_priceController.text);
              if (price == null) {
                throw AppException(
                  exceptionType: ExceptionType.unexpectedNullValue,
                  exceptionMessage: "Price was null or invalid.",
                );
              }

              final String filename = _filenameController.text;
              if (filename.isEmpty) {
                throw AppException(
                  exceptionType: ExceptionType.unexpectedNullValue,
                  exceptionMessage: "Filename was empty.",
                );
              }

              final AssetsDatatype? assetType = _assetsDatatypeController.value;
              if (assetType == null) {
                throw AppException(
                  exceptionType: ExceptionType.unexpectedNullValue,
                  exceptionMessage: "Asset type was not selected.",
                );
              }

              final String name = _nameController.text;
              if (name.isEmpty) {
                throw AppException(
                  exceptionType: ExceptionType.unexpectedNullValue,
                  exceptionMessage: "Name was empty.",
                );
              }

              final String details = _detailsController.text;
              if (details.isEmpty) {
                throw AppException(
                  exceptionType: ExceptionType.unexpectedNullValue,
                  exceptionMessage: "Details were empty.",
                );
              }

              final String author = _authorController.text;
              if (author.isEmpty) {
                throw AppException(
                  exceptionType: ExceptionType.unexpectedNullValue,
                  exceptionMessage: "Author was empty.",
                );
              }

              final Licence? licenseType = _licenseController.value;
              if (licenseType == null) {
                throw AppException(
                  exceptionType: ExceptionType.unexpectedNullValue,
                  exceptionMessage: "License type was not selected.",
                );
              }

              /*final MarketplaceAssetDto marketplaceAssetDto =
                  NeMarketplaceAssetDtowAssetDto(
                      price: _priceController.text,
                      filename: _filenameController.text,
                      assetType: _assetsDatatypeController.value,
                      name: _nameController.text,
                      details: _detailsController.text,
                      author: _authorController.text,
                      licenseType: _licenseController.value);
              // ignore: use_build_context_synchronously
              unawaited(
                  Routemaster.of(context).pop<NewCaseDto>(MarketplaceAssetDto));*/
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
  const OfferAssetsDialogForm({
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
  @override
  Widget build(BuildContext context) {
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
    );
  }
}
