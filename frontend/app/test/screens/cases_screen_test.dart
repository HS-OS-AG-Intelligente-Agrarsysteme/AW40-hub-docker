import "package:aw40_hub_frontend/providers/case_provider.dart";
import "package:aw40_hub_frontend/screens/cases_screen.dart";
import "package:aw40_hub_frontend/services/http_service.dart";
import "package:aw40_hub_frontend/views/cases_view.dart";
import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:provider/provider.dart";

void main() {
  group("CasesScreen", () {
    testWidgets("Returns one CasesView", (widgetTester) async {
      await widgetTester.pumpWidget(
        ChangeNotifierProvider<CaseProvider>(
          create: (_) => CaseProvider(HttpService(http.Client())),
          child: const CasesScreen(),
        ),
      );
      final Finder casesViewFinder = find.byType(CasesView);
      expect(casesViewFinder, findsOneWidget);
    });
  });
}
