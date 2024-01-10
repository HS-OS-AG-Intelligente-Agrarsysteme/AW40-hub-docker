import "package:aw40_hub_frontend/providers/case_provider.dart";
import "package:aw40_hub_frontend/screens/screens.dart";
import "package:aw40_hub_frontend/services/http_service.dart";
import "package:aw40_hub_frontend/views/views.dart";
import "package:flutter/widgets.dart";
import "package:flutter_test/flutter_test.dart";
import "package:provider/provider.dart";

void main() {
  group("CasesScreen", () {
    testWidgets("Returns one CasesView", (widgetTester) async {
      await widgetTester.pumpWidget(
        ChangeNotifierProvider<CaseProvider>(
          create: (_) => CaseProvider(HttpService()),
          child: const CasesScreen(),
        ),
      );
      final Finder casesViewFinder = find.byType(CasesView);
      expect(casesViewFinder, findsOneWidget);
    });
  });
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
