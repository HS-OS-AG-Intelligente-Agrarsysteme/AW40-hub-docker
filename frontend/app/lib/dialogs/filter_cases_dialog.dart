import "package:aw40_hub_frontend/providers/case_provider.dart";
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
  bool _switchState = true;
  @override
  Widget build(BuildContext context) {
    _switchState = Provider.of<CaseProvider>(context).showSharedCases;
    return Row(
      children: [
        Text(tr("cases.filterDialog.toggleShared")),
        Switch(
          value: _switchState,
          onChanged: (v) async {
            setState(() {
              _switchState = v;
            });
            await Provider.of<CaseProvider>(context, listen: false)
                .toggleShowSharedCases();
          },
        ),
      ],
    );
  }
}
