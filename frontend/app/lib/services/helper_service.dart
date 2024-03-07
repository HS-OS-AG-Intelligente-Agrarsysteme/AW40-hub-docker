import "dart:convert";

import "package:aw40_hub_frontend/exceptions/exceptions.dart";
import "package:aw40_hub_frontend/main.dart";
import "package:aw40_hub_frontend/services/services.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:http/http.dart";
import "package:logging/logging.dart";

class HelperService {
  static Level? getLogLevelFromConfigMap() {
    final String logLevelValueFromConfigMap =
        ConfigService().getConfigValue(ConfigKey.logLevel);
    return HelperService.stringToLogLevel(logLevelValueFromConfigMap);
  }

  static Level? stringToLogLevel(String s) {
    return Level.LEVELS.firstWhereOrNull(
      (level) => level.toString().toLowerCase() == s.toLowerCase(),
    );
  }

  static BuildContext get globalContext {
    final BuildContext? context = globalNavKey.currentContext;
    if (context == null) {
      throw AppException(
        exceptionType: ExceptionType.notFound,
        exceptionMessage: "context from globalNavKey was null",
      );
    }
    return context;
  }

  static DateTime? awFormatToDateTime(String awDateString) {
    // 2023-05-17T10:52:26.149000
    final List<int> intList = awDateString
        .replaceAll(RegExp("[:T.]"), "-")
        .split("-")
        .map(int.parse)
        .toList();
    if (intList.length != 7) {
      Logger("helper_service").warning(
        "Extracted ${intList.length} elements from AW date string. Expected 7. "
        "AW String was: $awDateString, extracted ints were $intList",
      );
      return null;
    }
    return DateTime(
      intList[0],
      intList[1],
      intList[2],
      intList[3],
      intList[4],
      intList[5],
      intList[6],
    );
  }

  static IconData getDiagnosisStatusIconData(DiagnosisStatus diagnosisStatus) {
    switch (diagnosisStatus) {
      case DiagnosisStatus.processing:
        return Icons.pending;
      case DiagnosisStatus.scheduled:
        return Icons.schedule;
      case DiagnosisStatus.finished:
        return Icons.check_circle;
      case DiagnosisStatus.action_required:
        return Icons.circle_notifications;
      case DiagnosisStatus.failed:
        return Icons.cancel;
    }
  }

  static Color getDiagnosisStatusContainerColor(
    ColorScheme colorScheme,
    DiagnosisStatus diagnosisStatus,
  ) {
    switch (diagnosisStatus) {
      case DiagnosisStatus.processing:
      case DiagnosisStatus.scheduled:
        return colorScheme.primary;
      case DiagnosisStatus.finished:
        return colorScheme.secondary;
      case DiagnosisStatus.action_required:
        return colorScheme.tertiary;
      case DiagnosisStatus.failed:
        return colorScheme.error;
    }
  }

  static Color getDiagnosisStatusOnContainerColor(
    ColorScheme colorScheme,
    DiagnosisStatus diagnosisStatus,
  ) {
    switch (diagnosisStatus) {
      case DiagnosisStatus.processing:
      case DiagnosisStatus.scheduled:
        return colorScheme.onPrimary;
      case DiagnosisStatus.finished:
        return colorScheme.onSecondary;
      case DiagnosisStatus.action_required:
        return colorScheme.onTertiary;
      case DiagnosisStatus.failed:
        return colorScheme.onError;
    }
  }

  static String convertIso88591ToUtf8(String inputString) {
    // Encode string with ISO-8859-1
    final List<int> bytes = latin1.encode(inputString);

    // Decode bytes with UTF-8
    final String decodedString = utf8.decode(bytes);

    return decodedString;
  }

  static bool verifyStatusCode(
    int actualStatusCode,
    int expectedStatusCode,
    String errorMessage,
    Response response,
    Logger logger,
  ) {
    if (actualStatusCode == expectedStatusCode) return true;
    logger.warning(
      "$errorMessage"
      "${response.statusCode}: ${response.reasonPhrase}",
    );
    return false;
  }
}
