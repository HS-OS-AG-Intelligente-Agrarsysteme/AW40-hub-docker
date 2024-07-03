import "package:aw40_hub_frontend/utils/enums.dart";

/// `Exception`s are for expected cases and should be handled.
/// `Error`s should crash your code because you messed up.
class AppException implements Exception {
  AppException({required this.exceptionType, required this.exceptionMessage});

  ExceptionType exceptionType;
  String exceptionMessage;

  @override
  String toString() {
    final String out = "${exceptionType.name}Exception: $exceptionMessage";
    return out[0].toUpperCase() + out.substring(1);
  }
}
