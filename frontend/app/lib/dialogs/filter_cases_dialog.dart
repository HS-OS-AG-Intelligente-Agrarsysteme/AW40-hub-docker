import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/providers/knowledge_provider.dart";
import "package:aw40_hub_frontend/text_input_formatters/upper_case_text_input_formatter.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:routemaster/routemaster.dart";

class FilterCasesDialog extends StatelessWidget {
  const FilterCasesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(tr("cases.filterDialog.title")),
      content: const FilterCasesDialogContent(),
      actions: [
        TextButton(
          child: Text(tr("general.close")),
          onPressed: () async => _onCancel(context),
        ),
      ],
    );
  }

  Future<void> _onCancel(BuildContext context) async {
    await Routemaster.of(context).pop();
  }
}

class FilterCasesDialogContent extends StatefulWidget {
  const FilterCasesDialogContent({
    super.key,
  });

  @override
  State<FilterCasesDialogContent> createState() =>
      _FilterCasesDialogContentState();
}

class _FilterCasesDialogContentState extends State<FilterCasesDialogContent> {
  // TODO rename?
  final TextEditingController _errorCodeController = TextEditingController();
  final TextEditingController _vinController = TextEditingController();
  // TODO rename?
  final TextEditingController _oscillogramController = TextEditingController();

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
          return const Center(child: CircularProgressIndicator());
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
                  controller: _errorCodeController,
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
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
                  controller: _vinController,
                  validator: (String? value) {
                    if ((value?.length ?? 0) > 6) {
                      return tr("cases.addCaseDialog.vinLengthInvalid");
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
              const SizedBox(width: 16),
              Tooltip(
                message: tr("cases.filterDialog.tooltip"),
                child: DropdownMenu<String>(
                  controller: _oscillogramController,
                  label: Text(tr("general.component")),
                  hintText: tr("forms.optional"),
                  enableFilter: true,
                  width: 320,
                  //onSelected: (value) async => _onCustomerSelection(context, value),
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
