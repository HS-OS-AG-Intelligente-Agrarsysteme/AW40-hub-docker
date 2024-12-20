import "dart:async";

import "package:aw40_hub_frontend/dialogs/add_case_dialog.dart";
import "package:aw40_hub_frontend/dialogs/create_asset_dialog.dart";
import "package:aw40_hub_frontend/dialogs/filter_cases_dialog.dart";
import "package:aw40_hub_frontend/dtos/new_asset_dto.dart";
import "package:aw40_hub_frontend/dtos/new_case_dto.dart";
import "package:aw40_hub_frontend/models/logged_in_user_model.dart";
import "package:aw40_hub_frontend/models/navigation_item_model.dart";
import "package:aw40_hub_frontend/providers/asset_provider.dart";
import "package:aw40_hub_frontend/providers/auth_provider.dart";
import "package:aw40_hub_frontend/providers/case_provider.dart";
import "package:aw40_hub_frontend/scaffolds/desktop_scaffold.dart";
import "package:aw40_hub_frontend/utils/constants.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:provider/provider.dart";
import "package:routemaster/routemaster.dart";
import "package:url_launcher/url_launcher.dart";

class ScaffoldWrapper extends StatefulWidget {
  const ScaffoldWrapper({
    required this.child,
    this.currentIndex,
    super.key,
  });
  final Widget child;
  final int? currentIndex;
  @override
  State<ScaffoldWrapper> createState() => _ScaffoldWrapperState();
}

class _ScaffoldWrapperState extends State<ScaffoldWrapper> {
  // ignore: unused_field
  final Logger _logger = Logger("scaffold_wrapper");
  int currentIndex = 0;
  bool _switchState = true;
  bool _isFilterActive = false;

  @override
  Widget build(BuildContext context) {
    final caseProvider = Provider.of<CaseProvider>(context);
    _switchState = caseProvider.showSharedCases;
    _isFilterActive = caseProvider.isFilterActive();

    final LoggedInUserModel loggedInUserModel =
        Provider.of<AuthProvider>(context).loggedInUser;
    if (widget.currentIndex != null) currentIndex = widget.currentIndex!;

    final List<NavigationMenuItemModel> navigationItemModels =
        _getMenuItemModels();

    return DesktopScaffold(
      navItems: navigationItemModels,
      currentIndex: currentIndex,
      onNavItemTap: onItemTap,
      loggedInUserModel: loggedInUserModel,
      child: widget.child,
    );
  }

  Future<NewAssetDto?> _showCreateAssetDialog() async {
    final NewAssetDto? newCase = await showDialog<NewAssetDto>(
      context: context,
      builder: (BuildContext context) {
        return CreateAssetDialog();
      },
    );
    return newCase;
  }

  Future<NewCaseDto?> _showAddCaseDialog() async {
    final NewCaseDto? newCase = await showDialog<NewCaseDto>(
      context: context,
      builder: (BuildContext context) {
        return const AddCaseDialog();
      },
    );
    return newCase;
  }

  Future<void> _showFilterDiagnosesDialog() async {
    // TODO implement _showFilterDiagnosesDialog
    throw UnimplementedError();
  }

  Future<void> _showFilterCasesDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => FilterCasesDialog(),
    );
  }

  Future<void> onItemTap(final int index) async {
    final NavigationMenuItemModel menuItemModel = _getMenuItemModels()[index];
    if (menuItemModel.isExternal) {
      await _onExternalNavItemTap(menuItemModel, index);
    } else {
      _onInternalNavItemTap(menuItemModel, index);
    }
  }

  void _onInternalNavItemTap(NavigationMenuItemModel model, final int index) {
    final String route = model.destination;
    setState(() => currentIndex = index);
    Routemaster.of(context).push(route);
  }

  Future<void> _onExternalNavItemTap(
    NavigationMenuItemModel model,
    final int index,
  ) async {
    await launchUrl(
      Uri.parse(model.destination),
      mode: LaunchMode.externalApplication,
    );
  }

  List<NavigationMenuItemModel> _getMenuItemModels() {
    final caseProvider = Provider.of<CaseProvider>(context, listen: false);
    final assetProvider = Provider.of<AssetProvider>(context, listen: false);
    final List<NavigationMenuItemModel> navigationItemModels = [
      NavigationMenuItemModel(
        title: tr("cases.title"),
        icon: const Icon(Icons.cases_sharp),
        destination: kRouteCases,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Transform.scale(
              scale: 0.75,
              child: Tooltip(
                message: tr("cases.filterDialog.toggleShared"),
                child: Switch(
                  value: _switchState,
                  onChanged: (v) async {
                    setState(() {
                      _switchState = v;
                    });
                    await Provider.of<CaseProvider>(
                      context,
                      listen: false,
                    ).toggleShowSharedCases();
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: _isFilterActive &&
                      !caseProvider
                          .notifiedListenersAfterGettingEmptyCurrentCases
                  ? () async {
                      final NewAssetDto? newAsset =
                          await _showCreateAssetDialog();
                      if (newAsset == null) return;
                      await assetProvider.createAsset(newAsset);
                    }
                  : null,
              icon: const Icon(Icons.create_new_folder),
              tooltip: tr("cases.actions.createAsset"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () async {
                final NewCaseDto? newCase = await _showAddCaseDialog();
                if (newCase == null) return;
                await caseProvider.addCase(newCase);
              },
              icon: const Icon(Icons.add_circle),
              tooltip: tr("cases.actions.addCase"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.sort),
              tooltip: tr("cases.actions.sortCases"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _isFilterActive
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () async => _showFilterCasesDialog(),
                icon: const Icon(Icons.filter_list),
                color: _isFilterActive ? Colors.blue : null,
                tooltip: tr("cases.actions.filterCases"),
              ),
            ),
          )
        ],
      ),
      NavigationMenuItemModel(
        title: tr("diagnoses.title"),
        icon: const Icon(Icons.analytics),
        destination: kRouteDiagnosis,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.sort),
            tooltip: tr("diagnoses.actions.sortDiagnoses"),
          ),
          IconButton(
            onPressed: () async => _showFilterDiagnosesDialog(),
            icon: const Icon(Icons.filter_list),
            tooltip: tr("diagnoses.actions.filterDiagnoses"),
          ),
        ],
      ),
      NavigationMenuItemModel(
        title: tr("customers.title"),
        icon: const Icon(Icons.people),
        destination: kRouteCustomers,
      ),
      NavigationMenuItemModel(
        title: tr("vehicles.title"),
        icon: const Icon(Icons.car_repair),
        destination: kRouteVecicles,
      ),
      NavigationMenuItemModel(
        title: tr("assets.title"),
        icon: const Icon(Icons.storage),
        destination: kRouteAssets,
      ),
      NavigationMenuItemModel(
        title: tr("training.title"),
        icon: const Icon(Icons.school),
        // * Note: On Android, this will cause the emulator to crash. Other URLs
        // * work fine though, so this is in all probability not an issue with
        // * Flutter.
        destination: kExternalLinkMoodle,
        navigationType: NavigationType.external,
      ),
    ];
    return navigationItemModels;
  }
}
