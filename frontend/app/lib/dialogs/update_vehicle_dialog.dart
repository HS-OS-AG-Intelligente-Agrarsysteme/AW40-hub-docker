import "dart:async";

import "package:aw40_hub_frontend/dtos/vehicle_update_dto.dart";
import "package:aw40_hub_frontend/models/vehicle_model.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:routemaster/routemaster.dart";

class UpdateVehicleDialog extends StatefulWidget {
  const UpdateVehicleDialog({
    required this.vehicleModel,
    super.key,
  });

  final VehicleModel vehicleModel;

  @override
  State<UpdateVehicleDialog> createState() => _UpdateVehicleDialogState();
}

class _UpdateVehicleDialogState extends State<UpdateVehicleDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tsnController = TextEditingController();
  final TextEditingController _yearBuildController = TextEditingController();
  final title = tr("vehicles.actions.updateVehicle");

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    _tsnController.text = widget.vehicleModel.tsn ?? "";
    _yearBuildController.text = widget.vehicleModel.yearBuild == null
        ? ""
        : widget.vehicleModel.yearBuild.toString();

    return AlertDialog(
      title: Text(title),
      content: UpdateDialogForm(
        formKey: _formKey,
        tsnController: _tsnController,
        yearBuildController: _yearBuildController,
        vehicleModel: widget.vehicleModel,
      ),
      actions: [
        TextButton(
          onPressed: () async => _onCancel(context),
          child: Text(
            tr("general.cancel"),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
        TextButton(
          onPressed: _submitUpdateVehicleForm,
          child: Text(tr("general.save")),
        ),
      ],
    );
  }

  void _submitUpdateVehicleForm() {
    final FormState? currentFormKeyState = _formKey.currentState;
    if (currentFormKeyState != null && currentFormKeyState.validate()) {
      currentFormKeyState.save();

      final String? tsn =
          _tsnController.text.isEmpty ? null : _tsnController.text;
      final int? yearBuild = int.tryParse(_yearBuildController.text);

      final VehicleUpdateDto vehicleUpdateDto =
          VehicleUpdateDto(tsn, yearBuild);
      unawaited(
        Routemaster.of(context).pop<VehicleUpdateDto>(vehicleUpdateDto),
      );
    }
  }

  Future<void> _onCancel(BuildContext context) async {
    await Routemaster.of(context).pop();
  }

  @override
  void dispose() {
    _tsnController.dispose();
    _yearBuildController.dispose();
    super.dispose();
  }
}

class UpdateDialogForm extends StatelessWidget {
  const UpdateDialogForm({
    required this.formKey,
    required this.tsnController,
    required this.yearBuildController,
    required this.vehicleModel,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController tsnController;
  final TextEditingController yearBuildController;
  final VehicleModel vehicleModel;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: tr("general.tsn"),
              border: const OutlineInputBorder(),
            ),
            controller: tsnController,
          ),
          const SizedBox(height: 16),
          TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: yearBuildController,
            decoration: InputDecoration(
              labelText: tr("general.yearBuild"),
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
