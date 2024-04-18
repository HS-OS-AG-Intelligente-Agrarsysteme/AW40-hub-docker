import "package:aw40_hub_frontend/data_sources/data_sources.dart";
import "package:aw40_hub_frontend/exceptions/exceptions.dart";
import "package:aw40_hub_frontend/models/models.dart";
import "package:aw40_hub_frontend/providers/providers.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
import "package:aw40_hub_frontend/views/views.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class CasesView extends StatefulWidget {
  const CasesView({
    super.key,
  });

  @override
  State<CasesView> createState() => _CasesViewState();
}

class _CasesViewState extends State<CasesView> {
  ValueNotifier<int?> currentCaseIndexNotifier = ValueNotifier<int?>(null);

  @override
  void dispose() {
    currentCaseIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final caseProvider = Provider.of<CaseProvider>(context);
    return FutureBuilder(
      // ignore: discarded_futures
      future: caseProvider.getCurrentCases(),
      builder: (BuildContext context, AsyncSnapshot<List<CaseModel>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<CaseModel>? caseModels = snapshot.data;
        if (caseModels == null) {
          throw AppException(
            exceptionType: ExceptionType.notFound,
            exceptionMessage: "Received no case data.",
          );
        }
        return Row(
          children: [
            Expanded(
              flex: 3,
              child: CasesTable(
                caseIndexNotifier: currentCaseIndexNotifier,
                caseModel: caseModels,
              ),
            ),

            // Show detail view if a case is selected.
            ValueListenableBuilder(
              valueListenable: currentCaseIndexNotifier,
              builder: (context, value, child) {
                if (value == null) return const SizedBox.shrink();
                return Expanded(
                  flex: 2,
                  child: CaseDetailView(
                    caseModel: caseModels[value],
                    onClose: () => currentCaseIndexNotifier.value = null,
                  ),
                );
              },
            )
          ],
        );
      },
    );
  }
}

class CasesTable extends StatelessWidget {
  const CasesTable({
    required this.caseModel,
    required this.caseIndexNotifier,
    super.key,
  });

  final List<CaseModel> caseModel;
  final ValueNotifier<int?> caseIndexNotifier;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PaginatedDataTable(
        source: CasesDataTableSource(
          themeData: Theme.of(context),
          currentIndexNotifier: caseIndexNotifier,
          caseModels: caseModel,
          onPressedRow: (int i) {
            caseIndexNotifier.value = i;
          },
        ),
        showCheckboxColumn: false,
        rowsPerPage: 50,
        columns: [
          DataColumn(
            label: Text(tr("general.date")),
            numeric: true,
          ),
          DataColumn(label: Text(tr("general.status"))),
          DataColumn(label: Text(tr("general.customer"))),
          DataColumn(label: Text("${tr('general.vehicle')} VIN")),
          DataColumn(
            label: Text(tr("general.workshop")),
            numeric: true,
          ),
        ],
      ),
    );
  }
}
