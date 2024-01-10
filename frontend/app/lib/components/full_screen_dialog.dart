import "package:flutter/material.dart";

class FullScreenDialog extends StatelessWidget {
  const FullScreenDialog({
    required this.title,
    required this.content,
    required this.onCancel,
    this.trailing,
    super.key,
  });
  final String title;
  final Widget content;
  final void Function() onCancel;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog.fullscreen(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  onPressed: onCancel,
                  icon: const Icon(Icons.close),
                ),
                Text(title, style: theme.textTheme.titleLarge),
                const Spacer(),
                if (trailing != null) trailing!,
                const SizedBox(width: 16),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: content,
            ),
          ],
        ),
      ),
    );
  }
}
