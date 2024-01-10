import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

class PageNotFoundScreen extends StatelessWidget {
  const PageNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        tr("pageNotFound.title"),
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }
}
