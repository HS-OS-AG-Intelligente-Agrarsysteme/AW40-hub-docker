import "package:aw40_hub_frontend/data_sources/data_sources.dart";
import "package:aw40_hub_frontend/exceptions/exceptions.dart";
import "package:aw40_hub_frontend/models/models.dart";
import "package:aw40_hub_frontend/providers/providers.dart";
import "package:aw40_hub_frontend/services/services.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
import "package:aw40_hub_frontend/views/views.dart";
import "package:collection/collection.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class CasesView extends StatelessWidget {
  const CasesView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final caseProvider = Provider.of<CaseProvider>(context);
    return FutureBuilder(
      // ignore: discarded_futures
      future: caseProvider.getCurrentCases(),
      builder: (BuildContext context, AsyncSnapshot<List<CaseModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final List<CaseModel>? caseModels = snapshot.data;
          if (caseModels == null) {
            throw AppException(
              exceptionType: ExceptionType.notFound,
              exceptionMessage: "Received no case data.",
            );
          }
          return EnvironmentService().isMobilePlatform
              ? MobileCasesView(caseModels: caseModels)
              : DesktopCasesView(caseModels: caseModels);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class DesktopCasesView extends StatefulWidget {
  const DesktopCasesView({required this.caseModels, super.key});
  final List<CaseModel> caseModels;

  @override
  State<DesktopCasesView> createState() => _DesktopCasesViewState();
}

class _DesktopCasesViewState extends State<DesktopCasesView> {
  int? currentCaseIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: PaginatedDataTable(
              source: CasesDataTableSource(
                themeData: Theme.of(context),
                currentIndex: currentCaseIndex,
                caseModels: widget.caseModels,
                onPressedRow: (int i) => setState(() => currentCaseIndex = i),
              ),
              showCheckboxColumn: false,
              rowsPerPage: 50,
              columns: [
                DataColumn(label: Text(tr("general.date")), numeric: true),
                DataColumn(label: Text(tr("general.status"))),
                DataColumn(label: Text(tr("general.customer"))),
                DataColumn(label: Text("${tr('general.vehicle')} VIN")),
                DataColumn(
                  label: Text(tr("general.workshop")),
                  numeric: true,
                ),
              ],
            ),
          ),
        ),
        if (currentCaseIndex != null)
          Expanded(
            flex: 2,
            child: CaseDetailView(
              caseModel: widget.caseModels[currentCaseIndex!],
              onClose: () => setState(() => currentCaseIndex = null),
            ),
          ),
      ],
    );
  }
}

class MobileCasesView extends StatelessWidget {
  const MobileCasesView({
    required this.caseModels,
    super.key,
  });

  final List<CaseModel> caseModels;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ExpansionPanelList.radio(
        children: caseModels.mapIndexed(
          (int index, CaseModel caseModel) {
            return ExpansionPanelRadio(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: Text(caseModel.customerId),
                  subtitle: Text(
                    caseModel.timestamp.toGermanDateString(),
                  ),
                );
              },
              body: CaseDetailView(
                caseModel: caseModel,
                onClose: () {},
              ),
              value: index,
            );
          },
        ).toList(),
      ),
    );
  }
}
