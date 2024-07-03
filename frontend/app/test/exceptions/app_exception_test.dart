import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("AppException", () {
    test("correctly assigns exceptionType", () {
      const exceptionType = ExceptionType.unexpectedNullValue;
      final AppException exception = AppException(
        exceptionType: exceptionType,
        exceptionMessage: "some exception message",
      );
      expect(exception.exceptionType, exceptionType);
    });
    test("correctly assigns exceptionMessage", () {
      const exceptionMessage = "some exception message";
      final AppException exception = AppException(
        exceptionType: ExceptionType.unexpectedNullValue,
        exceptionMessage: exceptionMessage,
      );
      expect(exception.exceptionMessage, exceptionMessage);
    });
    test("toString() returns correct string", () {
      final AppException exception = AppException(
        exceptionType: ExceptionType.unexpectedNullValue,
        exceptionMessage: "some exception message",
      );
      expect(
        exception.toString(),
        "UnexpectedNullValueException: some exception message",
      );
    });
  });
}
