import "dart:typed_data";

import "package:aw40_hub_frontend/components/file_upload_form_component.dart";
import "package:aw40_hub_frontend/forms/base_upload_form.dart";
import "package:aw40_hub_frontend/providers/case_provider.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class UploadVcdsForm extends StatefulWidget {
  const UploadVcdsForm({required this.caseId, super.key});

  final String caseId;

  @override
  State<UploadVcdsForm> createState() => _UploadVcdsFormState();
}

class _UploadVcdsFormState extends State<UploadVcdsForm> {
  Uint8List? _file;
  String? _filename;

  @override
  Widget build(BuildContext context) {
    return BaseUploadForm(
      content: FileUploadFormComponent(
        onFileDrop: (Uint8List file, String name) {
          _file = file;
          _filename = name;
        },
      ),
      onSubmit: _onSubmit,
    );
  }

  Future<void> _onSubmit() async {
    final provider = Provider.of<CaseProvider>(context, listen: false);
    final messengerState = ScaffoldMessenger.of(context);
    final Uint8List? file = _file;
    if (file == null) {
      messengerState.showSnackBar(
        SnackBar(
          content: Text(tr("diagnoses.details.uploadDragAndDropfailed")),
        ),
      );
      return;
    }

    final String? filename = _filename;
    if (filename == null) return;

    final bool result = await provider.uploadVcdsData(
      widget.caseId,
      file,
      filename,
    );

    final String snackBarText = result
        ? tr("diagnoses.details.uploadDataSuccessMessage")
        : tr("diagnoses.details.uploadDataErrorMessage");
    messengerState.showSnackBar(SnackBar(content: Text(snackBarText)));
    _closeForm();
  }

  void _closeForm() {
    Navigator.of(context).pop();
  }
}
