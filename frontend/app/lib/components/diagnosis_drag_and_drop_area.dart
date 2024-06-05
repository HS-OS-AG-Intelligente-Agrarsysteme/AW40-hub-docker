import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/services/helper_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:desktop_drop/desktop_drop.dart";
import "package:dotted_border/dotted_border.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:http/http.dart";

class DiagnosisDragAndDropArea extends StatefulWidget {
  const DiagnosisDragAndDropArea({
    required this.onDragDone,
    required this.onUploadFile,
    required this.fileName,
    required this.dataType,
    super.key,
  });
  final String? fileName;
  final void Function(DropDoneDetails) onDragDone;
  final void Function() onUploadFile;
  final String dataType;

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
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          buildAddArea(diagnosisStatusOnContainerColor),

          /*AlertDialog(
            title: Text("Add Data"),
            content: buildAddArea(diagnosisStatusOnContainerColor),
            actions: [
              TextButton(
                onPressed: widget.onUploadFile,
                child: Text(tr("general.save")),
              ),
            ],
            backgroundColor: diagnosisStatusOnContainerColor,
          ),*/
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget buildAddArea(Color diagnosisStatusOnContainerColor) {
    switch (widget.dataType) {
      case "obd":
      //return ;
      case "oscillogram":
      //return;
      case "symptom":
        return builldDropTarget(diagnosisStatusOnContainerColor);
      case "omniview":
        final TextEditingController componentController =
            TextEditingController();
        final TextEditingController samplingRateController =
            TextEditingController();
        final TextEditingController durationController1 =
            TextEditingController();
        return Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                builldDropTarget(diagnosisStatusOnContainerColor),
                const SizedBox(height: 10),
                buildDecoratedBox(
                  diagnosisStatusOnContainerColor,
                  "Component",
                  componentController,
                ),
                const SizedBox(height: 10),
                buildDecoratedBox(
                  diagnosisStatusOnContainerColor,
                  "Sampling Rate",
                  samplingRateController,
                ),
                const SizedBox(height: 10),
                buildDecoratedBox(
                  diagnosisStatusOnContainerColor,
                  "Duration",
                  durationController1,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.upload),
                  style: IconButton.styleFrom(
                    foregroundColor: diagnosisStatusOnContainerColor,
                  ),
                  onPressed: widget.onUploadFile,
                  tooltip: tr("diagnoses.details.uploadFileTooltip"),
                ),
              ],
            ),
          ],
        );
      default:
        throw Exception("Unknown data Type: ${widget.dataType}");
    }
  }

  Widget builldDropTarget(Color diagnosisStatusOnContainerColor) {
    return DropTarget(
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
              tr("diagnoses.details.dragAndDrop.${widget.dataType}"),
              style: TextStyle(
                color: diagnosisStatusOnContainerColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDecoratedBox(
    Color diagnosisStatusOnContainerColor,
    String description,
    TextEditingController fieldController,
  ) {
    return /*DecoratedBox(
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
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Center(
            child:*/
        TextFormField(
      decoration: InputDecoration(
        labelText: ("general.$description"),
        labelStyle: TextStyle(
          color: diagnosisStatusOnContainerColor,
        ),
        floatingLabelStyle: TextStyle(
          color: diagnosisStatusOnContainerColor,
        ),
        border: InputBorder.none,
      ),
      controller: fieldController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return tr("general.obligatoryField");
        }
        return null;
      },
      onSaved: (description) {
        if (description == null) {
          throw AppException(
            exceptionType: ExceptionType.unexpectedNullValue,
            exceptionMessage: "$description was null, validation failed.",
          );
        }
        if (description.isEmpty) {
          throw AppException(
            exceptionType: ExceptionType.unexpectedNullValue,
            exceptionMessage: "$description was empty, validation failed.",
          );
        }
      },
    );
  }
  /*       )),
      ),
    );
  }
}*/
}
