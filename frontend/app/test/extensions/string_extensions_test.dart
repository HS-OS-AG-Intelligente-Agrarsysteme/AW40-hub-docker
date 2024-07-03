import "package:aw40_hub_frontend/utils/extensions.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("StringExtension", () {
    group("substringBetween()", () {
      test(
        "with valid startDelimiter, no endDelimiter: "
        "returns substring after startDelimiter",
        () {
          const String string = "Hello, World!";
          final String substring = string.substringBetween(startDelimiter: ",");
          expect(substring, equals(" World!"));
        },
      );
      test(
        "with valid startDelimiter, valid endDelimiter: "
        "returns substring after startDelimiter and before endDelimiter",
        () {
          const String string = "Hello, World!";
          final String substring =
              string.substringBetween(startDelimiter: ",", endDelimiter: "!");
          expect(substring, equals(" World"));
        },
      );
      test(
        "with valid startDelimiter, invalid endDelimiter: "
        "returns substring after startDelimiter",
        () {
          const String string = "Hello, World!";
          final String substring =
              string.substringBetween(startDelimiter: ",", endDelimiter: "?");
          expect(substring, equals(" World!"));
        },
      );
      test(
        "with invalid startDelimiter, no endDelimiter: "
        "returns original string",
        () {
          const String string = "Hello, World!";
          final String substring = string.substringBetween(startDelimiter: "?");
          expect(substring, equals("Hello, World!"));
        },
      );
      test(
        "with invalid startDelimiter, valid endDelimiter: "
        "returns substring before endDelimiter",
        () {
          const String string = "Hello, World!";
          final String substring =
              string.substringBetween(startDelimiter: "?", endDelimiter: "!");
          expect(substring, equals("Hello, World"));
        },
      );
      test(
        "with invalid startDelimiter, invalid endDelimiter: "
        "returns original string",
        () {
          const String string = "Hello, World!";
          final String substring =
              string.substringBetween(startDelimiter: "?", endDelimiter: "?");
          expect(substring, equals("Hello, World!"));
        },
      );
      test(
        "uses first occurrence of startDelimiter",
        () {
          const String string = "Hello, World!";
          final String substring = string.substringBetween(startDelimiter: "o");
          expect(substring, equals(", World!"));
        },
      );
      test(
        "uses last occurrence of endDelimiter",
        () {
          const String string = "Hello, World!";
          final String substring =
              string.substringBetween(startDelimiter: ",", endDelimiter: "o");
          expect(substring, equals(" W"));
        },
      );
      test(
        "throws RangeError if both delimiters are valid, "
        "but endDelimiter comes before startDelimiter",
        () {
          const String string = "Hello, World!";
          expect(
            () => string.substringBetween(
              startDelimiter: "o",
              endDelimiter: "e",
            ),
            throwsRangeError,
          );
        },
      );
      test(
        "accounts for length of startDelimiter",
        () {
          const String string = "Hello, World!";
          final String substring =
              string.substringBetween(startDelimiter: "o, ");
          expect(substring, equals("World!"));
        },
      );
      test(
        "accounts for length of endDelimiter",
        () {
          const String string = "Hello, World!";
          final String substring = string.substringBetween(
            startDelimiter: "o",
            endDelimiter: "rld!",
          );
          expect(substring, equals(", Wo"));
        },
      );
    });
    group("substringAfter()", () {
      test("returns substring after delimiter", () {
        const String string = "Hello, World!";
        final String substring = string.substringAfter(",");
        expect(substring, equals(" World!"));
      });
      test("returns original string if delimiter not found", () {
        const String string = "Hello, World!";
        final String substring = string.substringAfter("?");
        expect(substring, equals(string));
      });
      test("returns empty string if delimiter is last character", () {
        const String string = "Hello, World!";
        final String substring = string.substringAfter("!");
        expect(substring, isEmpty);
      });
      test("returns substring after first occurrence of delimiter", () {
        const String string = "Hello, World!";
        final String substring = string.substringAfter("o");
        expect(substring, equals(", World!"));
      });
    });
    group("substringAfterLast()", () {
      test("returns substring after delimiter", () {
        const String string = "Hello, World!";
        final String substring = string.substringAfterLast(",");
        expect(substring, equals(" World!"));
      });
      test("returns original string if delimiter not found", () {
        const String string = "Hello, World!";
        final String substring = string.substringAfterLast("?");
        expect(substring, equals(string));
      });
      test("returns empty string if delimiter is last character", () {
        const String string = "Hello, World!";
        final String substring = string.substringAfterLast("!");
        expect(substring, isEmpty);
      });
      test("returns substring after last occurrence of delimiter", () {
        const String string = "Hello, World!";
        final String substring = string.substringAfterLast("o");
        expect(substring, equals("rld!"));
      });
    });
    group("substringBefore()", () {
      test("returns substring before delimiter", () {
        const String string = "Hello, World!";
        final String substring = string.substringBefore(",");
        expect(substring, equals("Hello"));
      });
      test("returns original string if delimiter not found", () {
        const String string = "Hello, World!";
        final String substring = string.substringBefore("?");
        expect(substring, equals(string));
      });
      test("returns empty string if delimiter is first character", () {
        const String string = "Hello, World!";
        final String substring = string.substringBefore("H");
        expect(substring, isEmpty);
      });
      test("returns substring before first occurrence of delimiter", () {
        const String string = "Hello, World!";
        final String substring = string.substringBefore("o");
        expect(substring, equals("Hell"));
      });
    });
    group("substringBeforeLast()", () {
      test("returns substring before delimiter", () {
        const String string = "Hello, World!";
        final String substring = string.substringBeforeLast(",");
        expect(substring, equals("Hello"));
      });
      test("returns original string if delimiter not found", () {
        const String string = "Hello, World!";
        final String substring = string.substringBeforeLast("?");
        expect(substring, equals(string));
      });
      test("returns empty string if delimiter is first character", () {
        const String string = "Hello, World!";
        final String substring = string.substringBeforeLast("H");
        expect(substring, isEmpty);
      });
      test("returns substring before last occurrence of delimiter", () {
        const String string = "Hello, World!";
        final String substring = string.substringBeforeLast("o");
        expect(substring, equals("Hello, W"));
      });
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
    group("constantCaseToCamelCase()", () {
      test("converts constant case string to camel case", () {
        const String constantCaseString = "HELLO_WORLD";
        final String camelCaseString =
            constantCaseString.constantCaseToCamelCase();
        expect(camelCaseString, equals("helloWorld"));
      });
      test("returns original string if empty", () {
        const String constantCaseString = "";
        final String camelCaseString =
            constantCaseString.constantCaseToCamelCase();
        expect(camelCaseString, equals(constantCaseString));
      });
    });
  });
}
