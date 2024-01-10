import "package:aw40_hub_frontend/text_input_formatters/text_input_formatters.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("UpperCaseTextInputFormatter", () {
    test("should convert lower case to upper case", () {
      final UpperCaseTextInputFormatter formatter =
          UpperCaseTextInputFormatter();
      const TextEditingValue textEditingValue = TextEditingValue(text: "abc");
      final TextEditingValue newValue = formatter.formatEditUpdate(
        TextEditingValue.empty,
        textEditingValue,
      );
      expect(newValue.text, "ABC");
    });
    test("should leave upper case untouched", () {
      const String upperCaseString = "ABC";
      final UpperCaseTextInputFormatter formatter =
          UpperCaseTextInputFormatter();
      const TextEditingValue textEditingValue =
          TextEditingValue(text: upperCaseString);
      final TextEditingValue newValue = formatter.formatEditUpdate(
        TextEditingValue.empty,
        textEditingValue,
      );
      expect(newValue.text, upperCaseString);
    });
    test("should leave numbers untouched", () {
      final UpperCaseTextInputFormatter formatter =
          UpperCaseTextInputFormatter();
      const numbersString = "1234567890";
      const TextEditingValue textEditingValue =
          TextEditingValue(text: numbersString);
      final TextEditingValue newValue = formatter.formatEditUpdate(
        TextEditingValue.empty,
        textEditingValue,
      );
      expect(newValue.text, numbersString);
    });
    test("should leave special characters untouched", () {
      final UpperCaseTextInputFormatter formatter =
          UpperCaseTextInputFormatter();
      const specialCharactersString = r"[]{}@€\|<>#'*+-_";
      const TextEditingValue textEditingValue =
          TextEditingValue(text: specialCharactersString);
      final TextEditingValue newValue = formatter.formatEditUpdate(
        TextEditingValue.empty,
        textEditingValue,
      );
      expect(newValue.text, specialCharactersString);
    });
    test("should leave empty string untouched", () {
      final UpperCaseTextInputFormatter formatter =
          UpperCaseTextInputFormatter();
      const TextEditingValue textEditingValue = TextEditingValue.empty;
      final TextEditingValue newValue = formatter.formatEditUpdate(
        TextEditingValue.empty,
        textEditingValue,
      );
      expect(newValue.text, "");
    });
  });
}
