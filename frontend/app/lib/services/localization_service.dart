import "package:aw40_hub_frontend/configs/configs.dart";
import "package:collection/collection.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";

class LocalizationService {
  factory LocalizationService() => _localizationService;
  LocalizationService._singleton();
  static final LocalizationService _localizationService =
      LocalizationService._singleton();

  Locale currentLocale = kStartLocale;

  static Locale? getLocaleFromLangCode(String langCode) {
    final RegExp langCodePattern = RegExp(r"^[a-z]{2}_[A-Z]{2}$");
    if (!langCodePattern.hasMatch(langCode)) {
      return null;
    }
    return Locale(
      langCode.split("_")[0],
      langCode.split("_")[1],
    );
  }

  static String getLanguageNameFromLocale(Locale locale) {
    return kSupportedLocales.keys
            .firstWhereOrNull((String k) => kSupportedLocales[k] == locale) ??
        locale.toString();
  }

  Future<void> changeUserLocale({
    required Locale changedLocale,
    required BuildContext buildContext,
  }) async {
    final String value = changedLocale.toString();
    final Locale locale = LocalizationService.getLocaleFromLangCode(
          value,
        ) ??
        kStartLocale;
    try {
      // Using try catch block to prevent runtime error if buildContext is not
      // safe
      await buildContext.setLocale(locale);
      currentLocale = locale;
      Logger("localization_service").info("Set locale to $currentLocale");
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      Logger("localization_service").warning(
        "language_service changeUserLocale: setLocale failed with error $e",
      );
    }
  }
}
