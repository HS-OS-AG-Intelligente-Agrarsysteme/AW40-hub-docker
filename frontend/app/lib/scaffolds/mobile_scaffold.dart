import "package:aw40_hub_frontend/components/components.dart";
import "package:aw40_hub_frontend/models/models.dart";
import "package:aw40_hub_frontend/utils/constants.dart";
import "package:flutter/material.dart";
import "package:routemaster/routemaster.dart";

class MobileScaffold extends StatelessWidget {
  const MobileScaffold({
    required this.navItems,
    required this.currentIndex,
    required this.onNavItemTap,
    required this.loggedInUserModel,
    required this.child,
    super.key,
  });

  final List<NavigationMenuItemModel> navItems;
  final int currentIndex;
  final void Function(int) onNavItemTap;
  final LoggedInUserModel loggedInUserModel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final NavigationMenuItemModel navItem = navItems[currentIndex];
    return Scaffold(
      appBar: AppBar(
        actions: navItem.actions,
        title: Text(navItem.title),
        backgroundColor: kPrimaryColor,
      ),
      body: child,
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                top: 40,
                right: 16,
                bottom: 8,
              ),
              child: Image.asset(kAssetAwLogoKleinDarkTheme, height: 40),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: navItems.length,
                padding: EdgeInsets.zero,
                itemBuilder: (BuildContext context, int i) {
                  final NavigationMenuItemModel item = navItems[i];
                  return ListTile(
                    leading: item.icon,
                    title: item.isExternal
                        ? Row(
                            children: [
                              Text(item.title),
                              const SizedBox(width: 8),
                              const Icon(Icons.open_in_new)
                            ],
                          )
                        : Text(item.title),
                    selected: i == currentIndex,
                    onTap: () async {
                      onNavItemTap(i);
                      await Routemaster.of(context).pop();
                    },
                    selectedColor: Theme.of(context).colorScheme.secondary,
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const CompanyAvatar(),
              title: Text(loggedInUserModel.fullName),
              trailing: const UserSettingsPopupButton(),
            ),
          ],
        ),
      ),
    );
  }
}
