import "package:aw40_hub_frontend/models/models.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

class CaseDetailDataTableSource extends DataTableSource {
  CaseDetailDataTableSource({
    required this.themeData,
    required this.caseModel,
  });
  CaseModel caseModel;
  final ThemeData themeData;

  @override
  DataRow? getRow(int index) {
    int position = 0;
    if (caseModel.obdData.isNotEmpty) {
      return _buildDataRow(
        caseModel.obdData[index],
        tr("cases.details.dataType.obd"),
      );
    }
    position += caseModel.obdData.length;

    if (index < position + caseModel.symptoms.length) {
      return _buildDataRow(
        caseModel.symptoms[index - position],
        tr("cases.details.dataType.symptom"),
      );
    }
    position += caseModel.symptoms.length;

    if (index < position + caseModel.timeseriesData.length) {
      return _buildDataRow(
        caseModel.timeseriesData[index - position],
        tr("cases.details.dataType.timeseriesData"),
      );
    }
    position += caseModel.timeseriesData.length;
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return themeData.colorScheme.primary.withOpacity(0.08);
        }
        return null;
      }),
      cells: [
        DataCell(Text(tr("general.no.data"))),
        const DataCell(Text("")),
        const DataCell(Text("")),
      ],
    );
  }

  DataRow _buildDataRow(data, String label) {
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return themeData.colorScheme.primary.withOpacity(0.08);
        }
        return null;
      }),
      cells: [
        DataCell(Text(data.toString())),
        DataCell(Text(data.toString())),
        DataCell(Text(label)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => (caseModel.obdData.isNotEmpty ||
          caseModel.symptoms.isNotEmpty ||
          caseModel.timeseriesData.isNotEmpty)
      ? caseModel.obdData.length +
          caseModel.symptoms.length +
          caseModel.timeseriesData.length
      : 1;

  @override
  int get selectedRowCount => 0;
}
