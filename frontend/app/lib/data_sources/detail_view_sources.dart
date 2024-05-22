import "package:aw40_hub_frontend/models/models.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

class CaseDetailDataTableSource extends DataTableSource {
  CaseDetailDataTableSource({
    required this.themeData,
    required this.caseModels,
    required this.dataType,
  });
  CaseModel caseModels;
  final ThemeData themeData;
  final List<String> dataType;

  final Map<CaseStatus, IconData> caseStatusIcons = {
    CaseStatus.open: Icons.cached,
    CaseStatus.closed: Icons.done,
  };

  @override
  DataRow? getRow(int index) {
    if (caseModels.obdData.isNotEmpty) {
      return _buildDataRow(caseModels.obdData, "obd");
    } else if (caseModels.symptoms.isNotEmpty) {
      return _buildDataRow(caseModels.symptoms, "symptoms");
    } else if (caseModels.timeseriesData.isNotEmpty) {
      return _buildDataRow(caseModels.timeseriesData, "timeseriesData");
    }
    return null;
  }

  DataRow _buildDataRow(List<dynamic> dataList, String label) {
    final int lastIndex = dataList.length - 1;
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return themeData.colorScheme.primary.withOpacity(0.08);
        }
        return null;
      }),
      cells: [
        DataCell(Text(dataList[lastIndex].toString())),
        DataCell(Text(dataList[lastIndex].toString())),
        DataCell(Text(label)),
      ],
    );
  }

/*
  @override
  DataRow? getRow(int index) {
    final caseModel = caseModels;
    final List<ObdDataModel> obdData = caseModel.obdData;
    //final ObdDataModel obdData = caseModel.obdData[index];
    //final i = obdData.length;

    if (caseModel.obdData.isNotEmpty) {
      final int i = caseModel.obdData.length-1;
      return DataRow(
        color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return themeData.colorScheme.primary.withOpacity(0.08);
          }
          return null; // Use the default value.
        }),
        cells: [
          DataCell(Text(caseModel.obdData[i].toString())),
          DataCell(Text(caseModel.obdData[i].toString())),
          const DataCell(Text("obd")),
        ],
      );
    } else if (caseModel.symptoms.isNotEmpty) {
      final int i = caseModel.symptoms.length-1;
      return DataRow(
        color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return themeData.colorScheme.primary.withOpacity(0.08);
          }
          return null; // Use the default value.
        }),
        cells: [
          DataCell(Text(caseModel.symptoms[i].toString())),
          DataCell(Text(caseModel.symptoms[i].toString())),
          const DataCell(Text("symptoms")),
        ],
      );
    } else if (caseModel.timeseriesData.isNotEmpty) {
      final int i = caseModel.timeseriesData.length-1;
      return DataRow(
        color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return themeData.colorScheme.primary.withOpacity(0.08);
          }
          return null; // Use the default value.
        }),
        cells: [
          DataCell(Text(caseModel.timeseriesData[i].toString())),
          DataCell(Text(caseModel.timeseriesData[i].toString())),
          const DataCell(Text("timeseriesData")),
        ],
      );
    } else {}
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
  }*/

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
