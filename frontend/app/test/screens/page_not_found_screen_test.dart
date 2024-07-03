import "package:aw40_hub_frontend/screens/page_not_found_screen.dart";
import "package:flutter/widgets.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("PageNotFoundScreen", () {
    testWidgets("uses pageNotFound.title string", (widgetTester) async {
      await widgetTester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: PageNotFoundScreen(),
        ),
      );
      final Finder pageNotFoundTextFinder = find.text("pageNotFound.title");
      expect(pageNotFoundTextFinder, findsOneWidget);
    });
  });
}
