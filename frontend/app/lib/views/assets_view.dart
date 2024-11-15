import "package:aw40_hub_frontend/data_sources/assets_data_table_source.dart";
import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/models/asset_model.dart";
import "package:aw40_hub_frontend/providers/assets_provider.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:aw40_hub_frontend/views/assets_detail_view.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:provider/provider.dart";

class AssetsView extends StatefulWidget {
  const AssetsView({
    super.key,
  });

  @override
  State<AssetsView> createState() => _AssetsView();
}

class _AssetsView extends State<AssetsView> {
  final Logger _logger = Logger("AssetsViewLogger");
  ValueNotifier<int?> currentCaseIndexNotifier = ValueNotifier<int?>(null);

  @override
  void dispose() {
    currentCaseIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assetProvider = Provider.of<AssetProvider>(context);

    return FutureBuilder(
      // ignore: discarded_futures
      future: assetProvider.getAssets(),
      builder:
          (BuildContext context, AsyncSnapshot<List<AssetModel>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            !snapshot.hasData) {
          _logger.shout(snapshot.error);
          _logger.shout(snapshot.data);
          return const Center(child: CircularProgressIndicator());
        }
        final List<AssetModel>? vehicleModels = snapshot.data;
        if (vehicleModels == null) {
          throw AppException(
            exceptionType: ExceptionType.notFound,
            exceptionMessage: "Received no assets.",
          );
        }
        return AssetsTable(
          assetsModels: vehicleModels,
          caseIndexNotifier: currentCaseIndexNotifier,
        );
      },
    );
  }
}

class AssetsTable extends StatefulWidget {
  const AssetsTable({
    required this.assetsModels,
    required this.caseIndexNotifier,
    super.key,
  });

  final List<AssetModel> assetsModels;
  final ValueNotifier<int?> caseIndexNotifier;

  @override
  State<StatefulWidget> createState() => AssetsTableState();
}

class AssetsTableState extends State<AssetsTable> {
  ValueNotifier<int?> currentAssetsIndexNotifier = ValueNotifier<int?>(null);

  @override
  void dispose() {
    currentAssetsIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assetsModels.isEmpty) {
      return Center(
        child: Text(
          tr("assets.noAssets"),
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
              source: AssetsDataTableSource(
                themeData: Theme.of(context),
                currentIndexNotifier: currentAssetsIndexNotifier,
                assetModels: widget.assetsModels,
                onPressedRow: (int i) =>
                    setState(() => currentAssetsIndexNotifier.value = i),
              ),
              showCheckboxColumn: false,
              rowsPerPage: 50,
              columns: [
                DataColumn(
                  label: Text(tr("assets.headlines.timeOfGeneration")),
                ),
                DataColumn(label: Text(tr("assets.headlines.name"))),
                DataColumn(label: Text(tr("assets.headlines.filter"))),
              ],
            ),
          ),
        ),

        // Show detail view if a assets is selected.
        ValueListenableBuilder(
          valueListenable: currentAssetsIndexNotifier,
          builder: (context, value, child) {
            if (value == null) return const SizedBox.shrink();
            return Expanded(
              flex: 2,
              child: AssetsDetailView(
                assetsModel: widget.assetsModels[value],
                onClose: () => currentAssetsIndexNotifier.value = null,
              ),
            );
          },
        )
      ],
    );
  }
}
