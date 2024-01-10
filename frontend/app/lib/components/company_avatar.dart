import "package:aw40_hub_frontend/providers/providers.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class CompanyAvatar extends StatelessWidget {
  const CompanyAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final String fullName =
        Provider.of<AuthProvider>(context).loggedInUser.fullName;
    final String initials =
        fullName.split(" ").map((e) => e[0].toUpperCase()).join();
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      width: 40,
      height: 40,
      child: Center(child: Text(initials)),
    );
  }
}
