import "package:http/http.dart";
import "package:logging/logging.dart";

export "constants.dart";
export "enums.dart";
export "extensions.dart";

final Logger _logger = Logger(
  "diagnosis_provider",
); //funktioniert das mit logger hier oder muss übergeben werden??

bool verifyStatusCode(
  int actualStatusCode,
  int expectedStatusCode,
  String errorMessage,
  Response response,
) {
  if (actualStatusCode != expectedStatusCode) {
    _logger.warning(
      "$errorMessage"
      "${response.statusCode}: ${response.reasonPhrase}",
    );
    return false;
  }
  return true;
}
