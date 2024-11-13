import "dart:async";

import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/providers/case_provider.dart";
import "package:aw40_hub_frontend/providers/knowledge_provider.dart";
import "package:aw40_hub_frontend/text_input_formatters/upper_case_text_input_formatter.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:aw40_hub_frontend/utils/filter_criteria.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:routemaster/routemaster.dart";

class FilterCasesDialog extends StatelessWidget {
  FilterCasesDialog({super.key});

  final TextEditingController _obdDataDtcController = TextEditingController();
  final TextEditingController _vinController = TextEditingController();
  final TextEditingController _timeseriesDataComponentController =
      TextEditingController();

  late final CaseProvider _caseProvider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _caseProvider = Provider.of<CaseProvider>(context, listen: false);

    final FilterCriteria? currentFilterCriteria = _caseProvider.filterCriteria;
    _obdDataDtcController.text = currentFilterCriteria?.obdDataDtc ?? "";
    _vinController.text = currentFilterCriteria?.vin ?? "";
    _timeseriesDataComponentController.text =
        currentFilterCriteria?.timeseriesDataComponent ?? "";

    return AlertDialog(
      title: Text(tr("cases.filterDialog.title")),
      content: FilterCasesDialogContent(
        obdDataDtcController: _obdDataDtcController,
        vinController: _vinController,
        timeseriesDataComponentController: _timeseriesDataComponentController,
      ),
      actions: [
        TextButton(
          onPressed: () async => _onCancel(context),
          child: Text(
            tr("general.cancel"),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
        TextButton(
          onPressed: () async => _resetFilterCriteria(context),
          child: Text(
            tr("cases.filterDialog.resetFilterCriteria"),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
        TextButton(
          onPressed: () async => _applyFilterForCases(context),
          child: Text(tr("general.apply")),
        ),
      ],
    );
  }

  Future<void> _resetFilterCriteria(BuildContext context) async {
    _caseProvider.resetFilterCriteria();
    await Routemaster.of(context).pop();
  }

  Future<void> _onCancel(BuildContext context) async {
    await Routemaster.of(context).pop();
  }

  Future<void> _applyFilterForCases(BuildContext context) async {
    final obdDataDtc = _obdDataDtcController.text;
    final vin = _vinController.text;
    final timeseriesDataComponent = _timeseriesDataComponentController.text;
    final filterCriteria = FilterCriteria(
      obdDataDtc: obdDataDtc.isEmpty ? null : obdDataDtc,
      vin: vin.isEmpty ? null : vin,
      timeseriesDataComponent:
          timeseriesDataComponent.isEmpty ? null : timeseriesDataComponent,
    );

    _caseProvider.setFilterCriteria(filterCriteria);

    // ignore: use_build_context_synchronously
    await Routemaster.of(context).pop();
  }
}

class FilterCasesDialogContent extends StatefulWidget {
  const FilterCasesDialogContent({
    required this.obdDataDtcController,
    required this.vinController,
    required this.timeseriesDataComponentController,
    super.key,
  });

  final TextEditingController obdDataDtcController;
  final TextEditingController vinController;
  final TextEditingController timeseriesDataComponentController;

  @override
  State<FilterCasesDialogContent> createState() =>
      _FilterCasesDialogContentState();
}

class _FilterCasesDialogContentState extends State<FilterCasesDialogContent> {
  @override
  Widget build(BuildContext context) {
    final knowledgeProvider =
        Provider.of<KnowledgeProvider>(context, listen: false);

    return FutureBuilder(
      // ignore: discarded_futures
      future: knowledgeProvider.getVehicleComponents(),
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            !snapshot.hasData) {
          return const SizedBox(
            height: 250,
            width: 350,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final List<String>? vehicleComponents = snapshot.data;
        if (vehicleComponents == null) {
          throw AppException(
            exceptionType: ExceptionType.notFound,
            exceptionMessage: "Received no vehicle components data.",
          );
        }
        return SizedBox(
          height: 250,
          width: 350,
          child: Column(
            children: [
              SizedBox(
                width: 320,
                height: 66,
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  inputFormatters: [UpperCaseTextInputFormatter()],
                  decoration: InputDecoration(
                    labelText: tr("cases.filterDialog.error"),
                    border: const OutlineInputBorder(),
                    errorStyle: const TextStyle(height: 0.1),
                  ),
                  controller: widget.obdDataDtcController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: SizedBox(
                  width: 320,
                  height: 66,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    inputFormatters: [UpperCaseTextInputFormatter()],
                    decoration: InputDecoration(
                      labelText: tr("cases.filterDialog.vin"),
                      border: const OutlineInputBorder(),
                      errorStyle: const TextStyle(height: 0.1),
                    ),
                    controller: widget.vinController,
                    validator: (String? value) {
                      if ((value?.length ?? 0) > 6) {
                        return tr("cases.filterDialog.vinLengthInvalid");
                      }
                      if (value != null && value.contains(RegExp("[IOQ]"))) {
                        return tr(
                          "cases.addCaseDialog.vinCharactersInvalid",
                        );
                      }

                      return null;
                    },
                  ),
                ),
              ),
              Tooltip(
                message: tr("cases.filterDialog.tooltip"),
                child: DropdownMenu<String>(
                  controller: widget.timeseriesDataComponentController,
                  label: Text(tr("general.component")),
                  hintText: tr("forms.optional"),
                  enableFilter: true,
                  width: 320,
                  menuStyle: const MenuStyle(alignment: Alignment.bottomLeft),
                  dropdownMenuEntries:
                      vehicleComponents.map<DropdownMenuEntry<String>>(
                    (String vehicleComponent) {
                      return DropdownMenuEntry<String>(
                        value: vehicleComponent,
                        label: vehicleComponent,
                      );
                    },
                  ).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
