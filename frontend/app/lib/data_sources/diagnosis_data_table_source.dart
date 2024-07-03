import "package:aw40_hub_frontend/models/diagnosis_model.dart";
import "package:aw40_hub_frontend/services/helper_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:aw40_hub_frontend/utils/extensions.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

class DiagnosisDataTableSource extends DataTableSource {
  DiagnosisDataTableSource({
    required this.themeData,
    required this.currentIndex,
    required this.diagnosisModels,
    required this.onPressedRow,
  });
  List<DiagnosisModel> diagnosisModels;
  final void Function(int) onPressedRow;
  final ThemeData themeData;
  int? currentIndex;

  Tooltip _getStatusIcon(DiagnosisStatus? diagnosisStatus) {
    return (diagnosisStatus == null)
        ? Tooltip(
            message: tr("general.unnamed"),
            child: const Icon(Icons.question_mark),
          )
        : Tooltip(
            message: tr("diagnoses.status.${diagnosisStatus.name}"),
            child: Icon(
              HelperService.getDiagnosisStatusIconData(diagnosisStatus),
              color: HelperService.getDiagnosisStatusContainerColor(
                themeData.colorScheme,
                diagnosisStatus,
              ),
            ),
          );
  }

  @override
  DataRow? getRow(int index) {
    final diagnosisModel = diagnosisModels[index];
    return DataRow(
      onSelectChanged: (_) => onPressedRow(index),
      selected: currentIndex == index,
      color: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return themeData.colorScheme.primary.withOpacity(0.08);
        }
        return null; // Use the default value.
      }),
      cells: [
        DataCell(Text(diagnosisModel.id)),
        DataCell(_getStatusIcon(diagnosisModel.status)),
        DataCell(Text(diagnosisModel.caseId)),
        DataCell(
          Text(
            diagnosisModel.timestamp.toGermanDateString(),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => diagnosisModels.length;

  @override
  int get selectedRowCount => 0;
}
