import "package:aw40_hub_frontend/models/asset_model.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

class AssetsDetailView extends StatelessWidget {
  const AssetsDetailView({
    required this.assetsModel,
    required this.onClose,
    super.key,
  });

  final AssetModel assetsModel;
  final void Function() onClose;

  @override
  Widget build(BuildContext context) {
    return DesktopAssetsDetailView(
      assetsModel: assetsModel,
      onClose: onClose,
      onDelete: () {},
    );
  }
}

class DesktopAssetsDetailView extends StatefulWidget {
  const DesktopAssetsDetailView({
    required this.assetsModel,
    required this.onClose,
    required this.onDelete,
    super.key,
  });

  final AssetModel assetsModel;
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

    final List<String> attributesCase = [
      tr("assets.headlines.timeOfGeneration"),
      tr("assets.headlines.name"),
      tr("assets.headlines.filter")
    ];
    final List<String> valuesCase = [
      widget.assetsModel.timestamp.toString(),
      widget.assetsModel.name,
      widget.assetsModel.definition.toString(),
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
                    // const SizedBox(width: 16),
                    Text(
                      tr("cases.details.headline"),
                      style: textTheme.displaySmall,
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
                      label: Text(tr("assets.upload")),
                      onPressed: () {},
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

  /*Future<AssetsUpdateDto?> _showUpdateAssetsDialog(
    AssetsModel assetsModel,
  ) async {
    return showDialog<AssetsUpdateDto>(
      context: context,
      builder: (BuildContext context) {
        return UpdateAssetsDialog(assetsModel: assetsModel);
      },
    );
  }*/
}
