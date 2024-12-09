import "package:aw40_hub_frontend/data_sources/cases_data_table_source.dart";
import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/models/case_model.dart";
import "package:aw40_hub_frontend/providers/case_provider.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:aw40_hub_frontend/views/case_detail_view.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:provider/provider.dart";

class CasesView extends StatefulWidget {
  const CasesView({
    super.key,
  });

  @override
  State<CasesView> createState() => _CasesViewState();
}

class _CasesViewState extends State<CasesView> {
  final Logger _logger = Logger("CasesView");

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _logger.info("build _CasesViewState");
    final caseProvider = Provider.of<CaseProvider>(context);

    if (caseProvider.notifiedListenersAfterGettingEmptyCurrentCases) {
      _logger.info("notifiedListenersAfterGettingEmptyCurrentCases = true");
      caseProvider.notifiedListenersAfterGettingEmptyCurrentCases = false;
      return buildCasesTable([], caseProvider);
    }

    return FutureBuilder(
      // ignore: discarded_futures
      future: caseProvider.getCurrentCases(),
      builder: (BuildContext context, AsyncSnapshot<List<CaseModel>> snapshot) {
        _logger.info(
          // ignore: lines_longer_than_80_chars
          "FutureBuilder called - ConnectionState: ${snapshot.connectionState}, "
          "Has Data: ${snapshot.hasData}, "
          "Error: ${snapshot.error}, "
          "Data: ${snapshot.data}",
        );
        if (snapshot.connectionState != ConnectionState.done ||
            !snapshot.hasData) {
          _logger.info("Returning: Center with CircularProgressIndicator");
          return const Center(child: CircularProgressIndicator());
        }
        final List<CaseModel>? caseModels = snapshot.data;
        if (caseModels == null) {
          throw AppException(
            exceptionType: ExceptionType.notFound,
            exceptionMessage: "Received no case data.",
          );
        }
        return buildCasesTable(caseModels, caseProvider);
      },
    );
  }

  Row buildCasesTable(List<CaseModel> caseModels, CaseProvider caseProvider) {
    _logger.info("called buildCasesTable with data $caseModels");
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: CasesTable(
            selectedCaseIndexNotifier: caseProvider.selectedCaseIndexNotifier,
            caseModel: caseModels,
          ),
        ),

        // Show detail view if a case is selected.
        ValueListenableBuilder(
          valueListenable: caseProvider.selectedCaseIndexNotifier,
          builder: (context, value, child) {
            if (value == null) return const SizedBox.shrink();
            return Expanded(
              flex: 2,
              child: CaseDetailView(
                caseModel: caseModels[value],
                onClose: () =>
                    caseProvider.selectedCaseIndexNotifier.value = null,
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
