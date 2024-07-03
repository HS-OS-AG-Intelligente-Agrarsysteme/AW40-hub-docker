import "dart:typed_data";

import "package:aw40_hub_frontend/services/helper_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:collection/collection.dart";
import "package:cross_file/cross_file.dart";
import "package:desktop_drop/desktop_drop.dart";
import "package:dotted_border/dotted_border.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";

/// This widget provides an area where users can drag and drop files. It draws a
/// dotted border but has a transparent background. When the user drops a file,
/// the widget will cast it to a Uint8List and perform checks and validation as
/// necessary. If the cast fails, the widget will display a SnackBar with an
/// error message. If the cast is successful, the widget will display the file
/// name and call the onFileDrop callback with the file's bytes.
class FileUploadFormComponent extends StatefulWidget {
  const FileUploadFormComponent({required this.onFileDrop, super.key});

  final void Function(Uint8List, String) onFileDrop;

  @override
  State<FileUploadFormComponent> createState() =>
      _FileUploadFormComponentState();
}

class _FileUploadFormComponentState extends State<FileUploadFormComponent> {
  final Logger _logger = Logger("FileUploadFormComponent");
  String? fileName;

  @override
  Widget build(BuildContext context) {
    final onContainerColor = HelperService.getDiagnosisStatusOnContainerColor(
      Theme.of(context).colorScheme,
      DiagnosisStatus.action_required,
    );
    return DropTarget(
      onDragDone: (details) async => _onDragDone(details, context),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(style: BorderStyle.none),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: DottedBorder(
          color: onContainerColor,
          borderType: BorderType.RRect,
          dashPattern: const <double>[8, 4],
          radius: const Radius.circular(10),
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              fileName ?? tr("diagnoses.details.dragAndDrop"),
              style: TextStyle(color: onContainerColor),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onDragDone(
    DropDoneDetails details,
    BuildContext context,
  ) async {
    final XFile? file = details.files.firstOrNull;
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("diagnoses.details.dropFileError"))),
      );
      return;
    }
    Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } on Exception catch (e) {
      _logger.severe("Could not read file as bytes.", e);
      return;
    }
    setState(() => fileName = file.name);
    widget.onFileDrop(bytes, file.name);
  }
}
