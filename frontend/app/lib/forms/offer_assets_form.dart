import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

class OfferAssetsForm extends StatelessWidget {
  const OfferAssetsForm({
    required this.priceController,
    required this.dataNameController,
    required this.nameController,
    required this.descriptionController,
    required this.authorController,
    required this.assetsDataType,
    required this.license,
    super.key,
  });

  final TextEditingController priceController;
  final TextEditingController dataNameController;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController authorController;
  final ValueNotifier<AssetsDatatype?> assetsDataType;
  final ValueNotifier<Licence?> license;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              width: 192,
              height: 66,
              child: TextFormField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: tr("assets.price"),
                  border: const OutlineInputBorder(),
                  errorStyle: const TextStyle(height: 0.1),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr("general.obligatoryField");
                  }
                  // Validate decimal format (2 decimal places)
                  const pricePattern = r"^\d+(\.\d{1,2})?$";
                  final regExp = RegExp(pricePattern);
                  if (!regExp.hasMatch(value)) {
                    return tr("assets.invalidPriceFormat");
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 192,
              height: 66,
              child: TextFormField(
                controller: dataNameController,
                decoration: InputDecoration(
                  labelText: tr("assets.dataName"),
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
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              width: 192,
              height: 66,
              child: DropdownButtonFormField<AssetsDatatype>(
                value: assetsDataType.value,
                decoration: InputDecoration(
                  labelText: tr("assets.dataType"),
                  border: const OutlineInputBorder(),
                  errorStyle: const TextStyle(height: 0.1),
                ),
                items: AssetsDatatype.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      tr(
                        "assets.dataType${type.name[0].toUpperCase()}${type.name.substring(1)}",
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) => assetsDataType.value = value,
                validator: (value) {
                  if (value == null) {
                    return tr("general.obligatoryField");
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 192,
              height: 66,
              child: TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: tr("assets.name"),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr("general.obligatoryField");
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 66,
          child: TextFormField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: tr("assets.description"),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              width: 192,
              height: 66,
              child: TextFormField(
                controller: authorController,
                decoration: InputDecoration(
                  labelText: tr("assets.author"),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr("general.obligatoryField");
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 192,
              height: 66,
              child: DropdownButtonFormField<Licence>(
                value: license.value,
                decoration: InputDecoration(
                  labelText: tr("assets.license"),
                  border: const OutlineInputBorder(),
                  errorStyle: const TextStyle(height: 0.1),
                ),
                items: Licence.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      tr("assets.licence${type.name[0].toUpperCase()}${type.name.substring(1)}"),
                    ),
                  );
                }).toList(),
                onChanged: (value) => license.value = value,
                validator: (value) {
                  if (value == null) {
                    return tr("general.obligatoryField");
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
