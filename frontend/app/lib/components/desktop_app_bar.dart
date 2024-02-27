import "package:flutter/material.dart";

class DesktopAppBar extends StatelessWidget {
  const DesktopAppBar({
    required this.title,
    required this.actions,
    super.key,
  });
  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Card(
        // 4 pixels is the default, but if we ever change this then we need a
        // more sophisticated approach here.
        margin: const EdgeInsets.fromLTRB(4, 0, 0, 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(8),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.displayMedium),
              const Spacer(),
              if (actions != null) Row(children: actions!),
            ],
          ),
        ),
      ),
    );
  }
}
