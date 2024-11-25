import "package:aw40_hub_frontend/dialogs/offer_assets_dialog.dart";
import "package:aw40_hub_frontend/dtos/asset_dto.dart";
import "package:aw40_hub_frontend/dtos/nautilus_private_key_dto.dart";
import "package:aw40_hub_frontend/models/asset_model.dart";
import "package:aw40_hub_frontend/providers/asset_provider.dart";
import "package:aw40_hub_frontend/services/ui_service.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class AssetsDetailView extends StatelessWidget {
  const AssetsDetailView({
    required this.assetModel,
    required this.onClose,
    super.key,
  });

  final AssetModel assetModel;
  final void Function() onClose;

  @override
  Widget build(BuildContext context) {
    return DesktopAssetsDetailView(
      assetModel: assetModel,
      onClose: onClose,
      onDelete: () {},
    );
  }
}

class DesktopAssetsDetailView extends StatefulWidget {
  const DesktopAssetsDetailView({
    required this.assetModel,
    required this.onClose,
    required this.onDelete,
    super.key,
  });

  final AssetModel assetModel;
  final void Function() onClose;
  final void Function() onDelete;

  @override
  State<DesktopAssetsDetailView> createState() =>
      _DesktopAssetsDetailViewState();
}

class _DesktopAssetsDetailViewState extends State<DesktopAssetsDetailView> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final assetProvider = Provider.of<AssetProvider>(context, listen: false);

    final List<String> attributesCase = [
      tr("assets.headlines.timeOfGeneration"),
      tr("assets.headlines.name"),
      tr("assets.headlines.filter")
    ];
    final List<String> valuesCase = [
      widget.assetModel.timestamp.toString(),
      widget.assetModel.name,
      widget.assetModel.definition.toJsonWithoutNullValues().toString(),
    ];

    return SizedBox.expand(
      child: SingleChildScrollView(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_double_arrow_right),
                      iconSize: 28,
                      onPressed: widget.onClose,
                      style: IconButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                      ),
                    ),
                    Text(
                      tr("general.details"),
                      style: textTheme.displaySmall,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_forever),
                      iconSize: 28,
                      style: IconButton.styleFrom(
                        foregroundColor: colorScheme.error,
                      ),
                      onPressed: () async => _onDeleteButtonPress(
                        context,
                        widget.assetModel.id!,
                        assetProvider,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Table(
                  columnWidths: const {0: IntrinsicColumnWidth()},
                  children: List.generate(
                    attributesCase.length,
                    (i) => TableRow(
                      children: [
                        const SizedBox(height: 32),
                        Text(attributesCase[i]),
                        Text(valuesCase[i]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.drive_folder_upload_outlined),
                      label: Text(tr("assets.upload.offer")),
                      onPressed: () async {
                        await _showOfferAssetsDialog();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onDeleteButtonPress(
    BuildContext context,
    String diagnosisModelCaseId,
    AssetProvider assetProvider,
  ) async {
    await _showConfirmRemoveDialog(context).then((String? privateKey) async {
      final ScaffoldMessengerState scaffoldMessengerState =
          ScaffoldMessenger.of(context);
      if (privateKey == null) return;

      final bool deletionResult = await assetProvider.deleteAsset(
        diagnosisModelCaseId,
        NautilusPrivateKeyDto(privateKey),
      );
      final String message = deletionResult
          ? tr("assets.details.deleteAssetSuccessMessage")
          : tr("assets.details.deleteAssetErrorMessage");
      UIService.showMessage(message, scaffoldMessengerState);
    });
  }

  Future<AssetDto?> _showOfferAssetsDialog() async {
    return showDialog<AssetDto>(
      context: context,
      builder: (BuildContext context) {
        return OfferAssetsDialog(assetModelId: widget.assetModel.id!);
      },
    );
  }

  Future<String?> _showConfirmRemoveDialog(BuildContext context) async {
    final TextEditingController privateKeyController = TextEditingController();

    return showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(tr("assets.remove.title")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tr("assets.remove.description")),
              const SizedBox(height: 16),
              TextFormField(
                controller: privateKeyController,
                decoration: InputDecoration(
                  labelText: tr("assets.upload.privateKey"),
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(
                tr("general.cancel"),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                privateKeyController.text,
              ),
              child: Text(tr("general.confirm")),
            ),
          ],
        );
      },
    );
  }
}
