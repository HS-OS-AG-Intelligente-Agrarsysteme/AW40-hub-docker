import "package:desktop_drop/desktop_drop.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

class DiagnosisDragAndDropArea extends StatefulWidget {
  const DiagnosisDragAndDropArea({
    required this.onDragDone,
    required this.fileName,
    super.key,
  });
  final String? fileName;
  final void Function(DropDoneDetails) onDragDone;

  @override
  State<DiagnosisDragAndDropArea> createState() =>
      _DiagnosisDragAndDropAreaState();
}

class _DiagnosisDragAndDropAreaState extends State<DiagnosisDragAndDropArea> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.fileName == null)
          Text(
            tr("diagnoses.details.uploadFile"),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary,
            ),
          )
        else
          Text(
            widget.fileName!,
            style: const TextStyle(color: Colors.blue),
          ),
        const SizedBox(height: 16),
        DropTarget(
          onDragDone: (details) => widget.onDragDone(details),
          onDragEntered: (_) => setState(() => _dragging = true),
          onDragExited: (_) => setState(() => _dragging = false),
          child: Container(
            height: 125,
            width: 300,
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: _dragging ? Colors.blue.withOpacity(0.4) : Colors.black26,
            ),
            child: Center(
              child: Center(
                child: Text(
                  tr("diagnoses.details.dragAndDrop"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
