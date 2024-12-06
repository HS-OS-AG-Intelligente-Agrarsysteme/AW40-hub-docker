import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

class OfferAssetsForm extends StatelessWidget {
  const OfferAssetsForm({
    required this.priceController,
    required this.licenseController,
    required this.privateKeyController,
    super.key,
  });

  final TextEditingController priceController;
  final TextEditingController licenseController;
  final TextEditingController privateKeyController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        SizedBox(
          width: 192,
          child: TextFormField(
            controller: priceController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: tr("assets.upload.price"),
              suffixText: "€",
              border: const OutlineInputBorder(),
              errorStyle: const TextStyle(height: 0.1),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return tr("general.obligatoryField");
              }
              // Validate decimal format (2 decimal places)
              const pricePattern = r"^\d+([.,]\d{1,2})?$";
              final regExp = RegExp(pricePattern);
              if (!regExp.hasMatch(value)) {
                return tr("assets.upload.invalidPriceFormat");
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 192,
          child: TextFormField(
            controller: licenseController,
            decoration: InputDecoration(
              labelText: tr("assets.upload.license"),
              border: const OutlineInputBorder(),
              errorStyle: const TextStyle(height: 0.1),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return tr("general.obligatoryField");
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 192,
          child: TextFormField(
            controller: privateKeyController,
            decoration: InputDecoration(
              labelText: tr("assets.upload.privateKey"),
              border: const OutlineInputBorder(),
              errorStyle: const TextStyle(height: 0.1),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return tr("general.obligatoryField");
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
