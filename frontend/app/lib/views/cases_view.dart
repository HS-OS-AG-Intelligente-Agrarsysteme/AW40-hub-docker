import "package:aw40_hub_frontend/data_sources/cases_data_table_source.dart";
import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/models/case_model.dart";
import "package:aw40_hub_frontend/providers/case_provider.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:aw40_hub_frontend/views/case_detail_view.dart";
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
  ValueNotifier<int?> selectedCaseIndexNotifier = ValueNotifier<int?>(null);

  @override
  void dispose() {
    selectedCaseIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final caseProvider = Provider.of<CaseProvider>(context);

    if (caseProvider.notifiedListenersAfterGettingEmptyCurrentCases) {
      caseProvider.notifiedListenersAfterGettingEmptyCurrentCases = false;
      return buildCasesTable([]);
    }

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
        return buildCasesTable(caseModels);
      },
    );
  }

  Row buildCasesTable(List<CaseModel> caseModels) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: CasesTable(
            selectedCaseIndexNotifier: selectedCaseIndexNotifier,
            caseModel: caseModels,
          ),
        ),

        // Show detail view if a case is selected.
        ValueListenableBuilder(
          valueListenable: selectedCaseIndexNotifier,
          builder: (context, value, child) {
            if (value == null) return const SizedBox.shrink();
            return Expanded(
              flex: 2,
              child: CaseDetailView(
                caseModel: caseModels[value],
                onClose: () => selectedCaseIndexNotifier.value = null,
              ),
            );
          },
        )
      ],
    );
  }
}

class CasesTable extends StatelessWidget {
  const CasesTable({
    required this.caseModel,
    required this.selectedCaseIndexNotifier,
    super.key,
  });

  final List<CaseModel> caseModel;
  final ValueNotifier<int?> selectedCaseIndexNotifier;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PaginatedDataTable(
        source: CasesDataTableSource(
          themeData: Theme.of(context),
          selectedCaseIndexNotifier: selectedCaseIndexNotifier,
          caseModels: caseModel,
          onPressedRow: (int i) {
            selectedCaseIndexNotifier.value = i;
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
          DataColumn(label: Text(tr("general.vehicleVin"))),
          DataColumn(
            label: Text(tr("general.workshop")),
            numeric: true,
          ),
        ],
      ),
    );
  }
}
