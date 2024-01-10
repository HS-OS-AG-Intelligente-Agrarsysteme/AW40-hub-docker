import "package:aw40_hub_frontend/services/helper_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:desktop_drop/desktop_drop.dart";
import "package:dotted_border/dotted_border.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

class DiagnosisDragAndDropArea extends StatefulWidget {
  const DiagnosisDragAndDropArea({
    required this.onDragDone,
    required this.onUploadFile,
    required this.fileName,
    super.key,
  });
  final String? fileName;
  final void Function(DropDoneDetails) onDragDone;
  final void Function() onUploadFile;

  @override
  State<DiagnosisDragAndDropArea> createState() =>
      _DiagnosisDragAndDropAreaState();
}

class _DiagnosisDragAndDropAreaState extends State<DiagnosisDragAndDropArea> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final diagnosisStatusOnContainerColor =
        HelperService.getDiagnosisStatusOnContainerColor(
      colorScheme,
      DiagnosisStatus.action_required,
    );
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (widget.fileName != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.fileName!,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: diagnosisStatusOnContainerColor,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.upload_file),
                  style: IconButton.styleFrom(
                    foregroundColor: diagnosisStatusOnContainerColor,
                  ),
                  onPressed: widget.onUploadFile,
                  tooltip: tr("diagnoses.details.uploadFileTooltip"),
                )
              ],
            ),
            const SizedBox(height: 16),
          ],
          DropTarget(
            onDragDone: (details) => widget.onDragDone(details),
            onDragEntered: (_) => setState(() => _dragging = true),
            onDragExited: (_) => setState(() => _dragging = false),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(style: BorderStyle.none),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: _dragging
                    ? diagnosisStatusOnContainerColor.withOpacity(0.3)
                    : diagnosisStatusOnContainerColor.withOpacity(0.2),
              ),
              child: DottedBorder(
                borderType: BorderType.RRect,
                dashPattern: const <double>[8, 4],
                radius: const Radius.circular(10),
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    tr("diagnoses.details.dragAndDrop"),
                    style: TextStyle(
                      color: diagnosisStatusOnContainerColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
