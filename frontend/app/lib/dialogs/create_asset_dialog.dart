import "dart:async";

import "package:aw40_hub_frontend/dtos/asset_definition_dto.dart";
import "package:aw40_hub_frontend/dtos/new_asset_dto.dart";
import "package:aw40_hub_frontend/providers/asset_provider.dart";
import "package:aw40_hub_frontend/providers/case_provider.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:routemaster/routemaster.dart";

class CreateAssetDialog extends StatelessWidget {
  CreateAssetDialog({super.key});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();

  late final AssetProvider _assetProvider;
  late final CaseProvider _caseProvider;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _assetProvider = Provider.of<AssetProvider>(context, listen: false);
    _caseProvider = Provider.of<CaseProvider>(context, listen: false);

    return AlertDialog(
      title: Text(tr("cases.createAssetDialog.title")),
      content: CreateAssetDialogContent(
        nameController: _nameController,
        descriptionController: _descriptionController,
        authorController: _authorController,
        formKey: _formKey,
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
          onPressed: () async => _createAsset(context, _formKey),
          child: Text(tr("general.create")),
        ),
      ],
    );
  }

  Future<void> _onCancel(BuildContext context) async {
    await Routemaster.of(context).pop();
  }

  Future<void> _createAsset(
    BuildContext context,
    final GlobalKey<FormState> formKey,
  ) async {
    final messengerState = ScaffoldMessenger.of(context);
    final FormState? currentFormKeyState = _formKey.currentState;

    if (currentFormKeyState != null && currentFormKeyState.validate()) {
      currentFormKeyState.save();

      final name = _nameController.text;
      final description = _descriptionController.text;
      final author = _authorController.text;

      final fitlerCriteria = _caseProvider.filterCriteria;
      final definition = AssetDefinitionDto(
        fitlerCriteria?.vin,
        fitlerCriteria?.obdDataDtc,
        fitlerCriteria?.timeseriesDataComponent,
      );

      final newAsset = NewAssetDto(
        name,
        definition,
        description,
        author,
      );

      final result = await _assetProvider.createAsset(newAsset);
      final String snackBarText = result != null
          ? tr("cases.createAssetDialog.successMessage")
          : tr("cases.createAssetDialog.errorMessage");
      messengerState.showSnackBar(SnackBar(content: Text(snackBarText)));

      // ignore: use_build_context_synchronously
      await Routemaster.of(context).pop();
    }
  }
}

class CreateAssetDialogContent extends StatefulWidget {
  const CreateAssetDialogContent({
    required this.nameController,
    required this.descriptionController,
    required this.authorController,
    required this.formKey,
    super.key,
  });

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController authorController;
  final GlobalKey<FormState> formKey;

  @override
  State<CreateAssetDialogContent> createState() =>
      _CreateAssetDialogContentState();
}

class _CreateAssetDialogContentState extends State<CreateAssetDialogContent> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SizedBox(
        height: 250,
        width: 350,
        child: Column(
          children: [
            SizedBox(
              width: 320,
              height: 66,
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: tr("cases.createAssetDialog.name"),
                  border: const OutlineInputBorder(),
                  errorStyle: const TextStyle(height: 0.1),
                ),
                controller: widget.nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr("general.obligatoryField");
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: SizedBox(
                width: 320,
                height: 66,
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: tr("cases.createAssetDialog.description"),
                    border: const OutlineInputBorder(),
                    errorStyle: const TextStyle(height: 0.1),
                  ),
                  controller: widget.descriptionController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr("general.obligatoryField");
                    }
                    return null;
                  },
                ),
              ),
            ),
            SizedBox(
              width: 320,
              height: 66,
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: tr("cases.createAssetDialog.author"),
                  border: const OutlineInputBorder(),
                  errorStyle: const TextStyle(height: 0.1),
                ),
                controller: widget.authorController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr("general.obligatoryField");
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
