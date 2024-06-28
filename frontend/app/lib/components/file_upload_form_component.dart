import "dart:typed_data";

import "package:collection/collection.dart";
import "package:cross_file/cross_file.dart";
import "package:desktop_drop/desktop_drop.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";

class FileUploadFormComponent extends StatelessWidget {
  FileUploadFormComponent({required this.onFileDrop, super.key});

  final Logger _logger = Logger("FileUploadFormComponent");
  final void Function(Uint8List) onFileDrop;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (details) async => _onDragDone(details, context),
      child: Container(
        alignment: Alignment.center,
        color: Colors.grey[200],
        height: 100,
        width: 200,
        child: const Text("Drop file here"),
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
    onFileDrop(bytes);
  }
}
