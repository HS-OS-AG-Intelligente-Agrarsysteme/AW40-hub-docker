import "dart:ui";

const Map<String, Locale> kSupportedLocales = {
  "de": Locale("de", "DE"),
  "en": Locale("en", "GB"),
};

const String kLocalesPath = "assets/localization";
const Locale kStartLocale = Locale("de", "DE");
const Locale kFallbackLocale = Locale("de", "DE");
