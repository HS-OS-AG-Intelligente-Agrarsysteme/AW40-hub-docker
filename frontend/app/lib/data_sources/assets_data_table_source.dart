import "package:aw40_hub_frontend/models/asset_model.dart";
import "package:aw40_hub_frontend/utils/extensions.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

class AssetsDataTableSource extends DataTableSource {
  AssetsDataTableSource({
    required this.themeData,
    required this.currentIndexNotifier,
    required this.assetModels,
    required this.onPressedRow,
  });
  List<AssetModel> assetModels;
  final void Function(int) onPressedRow;
  final ThemeData themeData;
  final ValueNotifier<int?> currentIndexNotifier;

  @override
  DataRow? getRow(int index) {
    final assetModel = assetModels[index];

    final String? formattedDateTime =
        assetModel.timestamp?.toGermanDateString();

    return DataRow(
      onSelectChanged: (_) => onPressedRow(index),
      selected: currentIndexNotifier.value == index,
      color: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return themeData.colorScheme.primary.withOpacity(0.08);
        }
        return null; // Use the default value.
      }),
      cells: [
        DataCell(Text(assetModel.name)),
        DataCell(
          Text(assetModel.definition.toJsonWithoutNullValues().toString()),
        ),
        DataCell(Text(formattedDateTime ?? tr("general.unknownDateTime"))),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => assetModels.length;

  @override
  int get selectedRowCount => 0;
}
