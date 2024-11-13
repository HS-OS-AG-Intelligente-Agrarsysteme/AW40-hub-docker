import "package:aw40_hub_frontend/data_sources/vehicles_data_table_source.dart";
import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/models/vehicle_model.dart";
import "package:aw40_hub_frontend/providers/vehicle_provider.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:aw40_hub_frontend/views/vehicle_detail_view.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:provider/provider.dart";

class VehiclesView extends StatefulWidget {
  const VehiclesView({
    super.key,
  });

  @override
  State<VehiclesView> createState() => _VehiclesViewState();
}

class _VehiclesViewState extends State<VehiclesView> {
  final currentVehicleIndexNotifier = ValueNotifier<int?>(null);
  final Logger _logger = Logger("VehicleViewLogger");

  @override
  void dispose() {
    currentVehicleIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = Provider.of<VehicleProvider>(context);
    return FutureBuilder(
      // ignore: discarded_futures
      future: vehicleProvider.getSharedVehicles(),
      builder:
          (BuildContext context, AsyncSnapshot<List<VehicleModel>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            !snapshot.hasData) {
          _logger.shout(snapshot.error);
          _logger.shout(snapshot.data);
          return const Center(child: CircularProgressIndicator());
        }
        final List<VehicleModel>? vehicleModels = snapshot.data;
        if (vehicleModels == null) {
          throw AppException(
            exceptionType: ExceptionType.notFound,
            exceptionMessage: "Received no vehicles.",
          );
        }
        return DesktopVehiclesView(
          vehicleModel: vehicleModels,
        );
      },
    );
  }
}

class DesktopVehiclesView extends StatefulWidget {
  const DesktopVehiclesView({
    required this.vehicleModel,
    super.key,
  });

  final List<VehicleModel> vehicleModel;

  @override
  State<DesktopVehiclesView> createState() => DesktopVehiclesViewState();
}

class DesktopVehiclesViewState extends State<DesktopVehiclesView> {
  ValueNotifier<int?> currentVehiclesIndexNotifier = ValueNotifier<int?>(null);

  @override
  void dispose() {
    currentVehiclesIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.vehicleModel.isEmpty) {
      return Center(
        child: Text(
          tr("general.noVehicles"),
          style: Theme.of(context).textTheme.displaySmall,
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: PaginatedDataTable(
              source: VehiclesDataTableSource(
                themeData: Theme.of(context),
                currentIndexNotifier: currentVehiclesIndexNotifier,
                vehicleModels: widget.vehicleModel,
                onPressedRow: (int i) =>
                    setState(() => currentVehiclesIndexNotifier.value = i),
              ),
              showCheckboxColumn: false,
              rowsPerPage: 50,
              columns: [
                DataColumn(
                  label: Text(tr("general.vin")),
                ),
                DataColumn(label: Text(tr("general.tsn"))),
                DataColumn(label: Text(tr("general.yearBuild"))),
              ],
            ),
          ),
        ),

        // Show detail view if a vehicle is selected.
        ValueListenableBuilder(
          valueListenable: currentVehiclesIndexNotifier,
          builder: (context, value, child) {
            if (value == null) return const SizedBox.shrink();
            return Expanded(
              flex: 2,
              child: VehicleDetailView(
                vehicleModel: widget.vehicleModel[value],
                onClose: () => currentVehiclesIndexNotifier.value = null,
              ),
            );
          },
        )
      ],
    );
  }
}
