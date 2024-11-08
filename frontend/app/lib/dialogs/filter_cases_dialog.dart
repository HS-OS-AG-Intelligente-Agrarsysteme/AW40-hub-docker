import "package:aw40_hub_frontend/text_input_formatters/upper_case_text_input_formatter.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
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
  final TextEditingController _errorCodeController = TextEditingController();
  final TextEditingController _vinController = TextEditingController();
  // TODO Dropdown
  final TextEditingController _oscillogramController = TextEditingController();

  final List<String> mockDataEntries = ["Test1", "Test2", "Test3"];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: 350,
      child: Column(
        children: [
          SizedBox(
            width: 300,
            height: 66,
            child: TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: [UpperCaseTextInputFormatter()],
              decoration: const InputDecoration(
                labelText: "Error code",
                border: OutlineInputBorder(),
                errorStyle: TextStyle(height: 0.1),
              ),
              controller: _errorCodeController,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 300,
            height: 66,
            child: TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: [UpperCaseTextInputFormatter()],
              decoration: InputDecoration(
                labelText: "first 6 numbers of vehicle vin",
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
            // TODO adjust (and translate) or remove
            message: "Please select",
            child: DropdownMenu<String>(
              controller: _oscillogramController,
              label: Text(tr("general.component")),
              hintText: tr("forms.optional"),
              enableFilter: true,
              width: 300,
              //onSelected: (value) async => _onCustomerSelection(context, value),
              menuStyle: const MenuStyle(alignment: Alignment.bottomLeft),
              dropdownMenuEntries:
                  mockDataEntries.map<DropdownMenuEntry<String>>(
                (String mockDataEntry) {
                  return DropdownMenuEntry<String>(
                    value: mockDataEntry,
                    label: mockDataEntry,
                  );
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
