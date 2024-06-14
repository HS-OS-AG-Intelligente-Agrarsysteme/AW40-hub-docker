import "package:aw40_hub_frontend/utils/extensions.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("DateTimeExtension", () {
    test("toGermanDateString() correctly formats string", () {
      final DateTime dateTime = DateTime(1993, 3, 28);
      final String germanDateString = dateTime.toGermanDateString();
      expect(germanDateString, "28.3.1993");
    });
  });
  group("StringExtension", () {
    group("substringBetween()", () {
      test(
        "with valid startDelimiter, no endDelimiter: "
        "returns substring after startDelimiter",
        () {
          const String string = "Hello, World!";
          final String substring = string.substringBetween(",");
          expect(substring, equals(" World!"));
        },
      );
      test(
        "with valid startDelimiter, valid endDelimiter: "
        "returns substring after startDelimiter and before endDelimiter",
        () {
          const String string = "Hello, World!";
          final String substring = string.substringBetween(",", "!");
          expect(substring, equals(" World"));
        },
      );
      test(
        "with valid startDelimiter, invalid endDelimiter: "
        "returns substring after startDelimiter",
        () {
          const String string = "Hello, World!";
          final String substring = string.substringBetween(",", "?");
          expect(substring, equals(" World!"));
        },
      );
      test(
        "with invalid startDelimiter, no endDelimiter: "
        "returns original string",
        () {
          const String string = "Hello, World!";
          final String substring = string.substringBetween("?");
          expect(substring, equals("Hello, World!"));
        },
      );
      test(
        "with invalid startDelimiter, valid endDelimiter: "
        "returns substring before endDelimiter",
        () {
          const String string = "Hello, World!";
          final String substring = string.substringBetween("?", "!");
          expect(substring, equals("Hello, World"));
        },
      );
      test(
        "with invalid startDelimiter, invalid endDelimiter: "
        "returns original string",
        () {
          const String string = "Hello, World!";
          final String substring = string.substringBetween("?", "?");
          expect(substring, equals("Hello, World!"));
        },
      );
      test(
        "uses first occurrence of startDelimiter",
        () {
          const String string = "Hello, World!";
          final String substring = string.substringBetween("o");
          expect(substring, equals(", World!"));
        },
      );
      test(
        "uses last occurrence of endDelimiter",
        () {
          const String string = "Hello, World!";
          final String substring = string.substringBetween(",", "o");
          expect(substring, equals(" W"));
        },
      );
      test(
        "throws RangeError if both delimiters are valid, "
        "but endDelimiter comes before startDelimiter",
        () {
          const String string = "Hello, World!";
          expect(() => string.substringBetween("o", "e"), throwsRangeError);
        },
      );
      test(
        "accounts for length of startDelimiter",
        () {
          const String string = "Hello, World!";
          final String substring = string.substringBetween("o, ");
          expect(substring, equals("World!"));
        },
      );
      test(
        "accounts for length of endDelimiter",
        () {
          const String string = "Hello, World!";
          final String substring = string.substringBetween("o", "rld!");
          expect(substring, equals(", Wo"));
        },
      );
    });
    group("capitalize()", () {
      test("capitalizes first character of string", () {
        const String string = "hello, world!";
        final String capitalizedString = string.capitalize();
        expect(capitalizedString, equals("Hello, world!"));
      });
      test("returns original string if empty", () {
        const String string = "";
        final String capitalizedString = string.capitalize();
        expect(capitalizedString, equals(string));
      });
      test("returns original string if already capitalized", () {
        const String string = "Hello, world!";
        final String capitalizedString = string.capitalize();
        expect(capitalizedString, equals(string));
      });
      test("capitalizes first and only character if only one character", () {
        const String string = "h";
        final String capitalizedString = string.capitalize();
        expect(capitalizedString, equals("H"));
      });
      test("does not trim leading white space", () {
        const String string = " hello, world!";
        final String capitalizedString = string.capitalize();
        expect(capitalizedString, startsWith(" "));
      });
      test("does not trim trailing white space", () {
        const String string = "hello, world! ";
        final String capitalizedString = string.capitalize();
        expect(capitalizedString, endsWith(" "));
      });
      test("does not advance to first non-whitespace character", () {
        const String string = " hello, world!";
        final String capitalizedString = string.capitalize();
        expect(capitalizedString, equals(string));
      });
    });
  });
}
