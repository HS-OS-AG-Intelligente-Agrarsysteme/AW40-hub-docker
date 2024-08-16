import "package:aw40_hub_frontend/models/vehicle_model.dart";
import "package:flutter/material.dart";

class VehiclesDataTableSource extends DataTableSource {
  VehiclesDataTableSource({
    required this.themeData,
    required this.currentIndexNotifier,
    required this.vehicleModels,
    required this.onPressedRow,
  });
  List<VehicleModel> vehicleModels;
  final void Function(int) onPressedRow;
  final ThemeData themeData;
  final ValueNotifier<int?> currentIndexNotifier;

  @override
  DataRow? getRow(int index) {
    final vehicleModel = vehicleModels[index];
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
        DataCell(Text(vehicleModel.vin ?? "")),
        DataCell(Text(vehicleModel.tsn ?? "")),
        DataCell(
          Text(vehicleModel.yearBuild?.toString() ?? ""),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => vehicleModels.length;

  @override
  int get selectedRowCount => 0;
}
