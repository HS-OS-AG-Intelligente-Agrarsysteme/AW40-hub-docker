import "dart:async";

import "package:aw40_hub_frontend/dialogs/dialogs.dart";
import "package:aw40_hub_frontend/dtos/dtos.dart";
import "package:aw40_hub_frontend/models/models.dart";
import "package:aw40_hub_frontend/providers/providers.dart";
import "package:aw40_hub_frontend/scaffolds/scaffolds.dart";
import "package:aw40_hub_frontend/services/services.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
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
    // TODO implement in a later story
    _logger.warning("Unimplemented: _showFilterDiagnosesDialog()");
  }

  Future<void> _showFilterCasesDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => const FilterCasesDialog(),
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
    final List<NavigationMenuItemModel> navigationItemModels = [
      NavigationMenuItemModel(
        title: tr("cases.title"),
        icon: const Icon(Icons.cases_sharp),
        destination: kRouteCases,
        actions: [
          IconButton(
            onPressed: () async {
              final NewCaseDto? newCase = await _showAddCaseDialog();
              if (newCase == null) return;
              await caseProvider.addCase(newCase);
            },
            icon: const Icon(Icons.add),
            tooltip: tr("cases.actions.addCase"),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.sort),
            tooltip: tr("cases.actions.sortCases"),
          ),
          IconButton(
            onPressed: () async => _showFilterCasesDialog(),
            icon: const Icon(Icons.filter_list),
            tooltip: tr("cases.actions.filterCases"),
          ),
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

  @override
  Widget build(BuildContext context) {
    final LoggedInUserModel loggedInUserModel =
        Provider.of<AuthProvider>(context).loggedInUser;
    if (widget.currentIndex != null) currentIndex = widget.currentIndex!;

    final List<NavigationMenuItemModel> navigationItemModels =
        _getMenuItemModels();

    return EnvironmentService().isMobilePlatform
        ? MobileScaffold(
            navItems: navigationItemModels,
            currentIndex: currentIndex,
            onNavItemTap: onItemTap,
            loggedInUserModel: loggedInUserModel,
            child: widget.child,
          )
        : DesktopScaffold(
            navItems: navigationItemModels,
            currentIndex: currentIndex,
            onNavItemTap: onItemTap,
            loggedInUserModel: loggedInUserModel,
            child: widget.child,
          );
  }
}
