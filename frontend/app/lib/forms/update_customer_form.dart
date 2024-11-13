import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

class CustomerAttributesForm extends StatelessWidget {
  const CustomerAttributesForm({
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.streetController,
    required this.housenumberController,
    required this.postcodeController,
    required this.cityController,
    super.key,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController streetController;
  final TextEditingController housenumberController;
  final TextEditingController postcodeController;
  final TextEditingController cityController;

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
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: tr("general.firstname"),
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
                          "First name was null, validation failed.",
                    );
                  }
                  if (value.isEmpty) {
                    throw AppException(
                      exceptionType: ExceptionType.unexpectedNullValue,
                      exceptionMessage:
                          "First name was empty, validation failed.",
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 192,
              height: 66,
              child: TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: tr("general.lastname"),
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
                          "Last name was null, validation failed.",
                    );
                  }
                  if (value.isEmpty) {
                    throw AppException(
                      exceptionType: ExceptionType.unexpectedNullValue,
                      exceptionMessage:
                          "Last name was empty, validation failed.",
                    );
                  }
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
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: tr("general.email"),
                  border: const OutlineInputBorder(),
                  errorStyle: const TextStyle(height: 0.1),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null;
                  }
                  const emailPattern =
                      r"^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
                  final regExp = RegExp(emailPattern);
                  if (!regExp.hasMatch(value)) {
                    return tr("general.invalidEmail");
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
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: tr("general.phone"),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              width: 280,
              height: 66,
              child: TextFormField(
                controller: streetController,
                decoration: InputDecoration(
                  labelText: tr("general.street"),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 104,
              height: 66,
              child: TextFormField(
                controller: housenumberController,
                decoration: InputDecoration(
                  labelText: tr("general.housenumber"),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              width: 104,
              height: 66,
              child: TextFormField(
                controller: postcodeController,
                decoration: InputDecoration(
                  labelText: tr("general.postcode"),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 280,
              height: 66,
              child: TextFormField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: tr("general.city"),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
