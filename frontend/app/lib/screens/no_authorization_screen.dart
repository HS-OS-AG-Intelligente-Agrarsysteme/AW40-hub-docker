import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

class NoAuthorizationScreen extends StatelessWidget {
  const NoAuthorizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        tr("noAuthorizations.title"),
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }
}
