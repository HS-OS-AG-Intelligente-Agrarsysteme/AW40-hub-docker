import "package:collection/collection.dart";
import "package:cross_file/cross_file.dart";
import "package:desktop_drop/desktop_drop.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

class FileUploadFormComponent extends StatelessWidget {
  const FileUploadFormComponent({required this.onFileDrop, super.key});

  final void Function(XFile) onFileDrop;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (DropDoneDetails details) {
        final XFile? file = details.files.firstOrNull;
        if (file == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tr("diagnoses.details.dropFileError")),
            ),
          );
          return;
        }
        onFileDrop(file);
      },
      child: Container(
        alignment: Alignment.center,
        color: Colors.grey[200],
        height: 100,
        width: 200,
        child: const Text("Drop file here"),
      ),
    );
  }
}
