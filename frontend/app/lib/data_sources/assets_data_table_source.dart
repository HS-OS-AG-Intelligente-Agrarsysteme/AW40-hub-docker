import "package:aw40_hub_frontend/models/assets_model.dart";
import "package:flutter/material.dart";

class AssetsDataTableSource extends DataTableSource {
  AssetsDataTableSource({
    required this.themeData,
    required this.currentIndexNotifier,
    required this.assetsModels,
    required this.onPressedRow,
  });
  List<AssetsModel> assetsModels;
  final void Function(int) onPressedRow;
  final ThemeData themeData;
  final ValueNotifier<int?> currentIndexNotifier;

  @override
  DataRow? getRow(int index) {
    final assetsModel = assetsModels[index];
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
        DataCell(Text(assetsModel.timeOfGeneration)),
        DataCell(Text(assetsModel.filter.toString())),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => assetsModels.length;

  @override
  int get selectedRowCount => 0;
}
