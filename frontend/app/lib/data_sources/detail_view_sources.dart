import "package:aw40_hub_frontend/models/models.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

class CaseDetailDataTableSource extends DataTableSource {
  CaseDetailDataTableSource({
    required this.themeData,
    //required this.currentIndexNotifier,
    required this.caseModels,
    required this.dataType,
  });
  CaseModel caseModels;
  final ThemeData themeData;
  //final ValueNotifier<int?> currentIndexNotifier;
  final Map<CaseStatus, IconData> caseStatusIcons = {
    CaseStatus.open: Icons.cached,
    CaseStatus.closed: Icons.done,
  };
  final String dataType;

  @override
  DataRow? getRow(int index) {
    final caseModel = caseModels;
    final List<ObdDataModel> obdData = caseModel.obdData;
    //final ObdDataModel obdData = caseModel.obdData[index];
    final i = obdData.length;

    switch (dataType) {
      case "obd":
        return DataRow(
          color: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return themeData.colorScheme.primary.withOpacity(0.08);
            }
            return null; // Use the default value.
          }),
          cells: [
            DataCell(Text(caseModel.obdData.toString())),
            DataCell(Text(caseModel.obdData.toString())),
            DataCell(Text(dataType)),
          ],
        );
      case "symptoms":
        return DataRow(
          color: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return themeData.colorScheme.primary.withOpacity(0.08);
            }
            return null; // Use the default value.
          }),
          cells: [
            DataCell(Text(caseModel.symptoms.toString())),
            DataCell(Text(caseModel.symptoms.toString())),
            DataCell(Text(dataType)),
          ],
        );
      case "timeseriesData":
        return DataRow(
          color: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return themeData.colorScheme.primary.withOpacity(0.08);
            }
            return null; // Use the default value.
          }),
          cells: [
            DataCell(Text(caseModel.timeseriesData.toString())),
            DataCell(Text(caseModel.timeseriesData.toString())),
            DataCell(Text(dataType)),
          ],
        );
      default:
        return null;
    }

    return DataRow(
      //onSelectChanged: (_) => onPressedRow(index),
      //selected: currentIndexNotifier.value == index,
      color: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return themeData.colorScheme.primary.withOpacity(0.08);
        }
        return null; // Use the default value.
      }),
      cells: [
        DataCell(Text(caseModel.customerId)),
        DataCell(Text(caseModel.obdData.toString())),
        DataCell(Text(dataType)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount =>
      caseModels.obdData.length +
      caseModels.symptoms.length +
      caseModels.timeseriesData.length;

  @override
  int get selectedRowCount => 0;
}
