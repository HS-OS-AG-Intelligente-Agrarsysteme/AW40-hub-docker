import "package:flutter/material.dart";

class BaseUploadForm extends StatelessWidget {
  const BaseUploadForm({
    required this.content,
    required this.onSubmit,
    super.key,
  });

  final Widget content;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        content,
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onSubmit,
          child: const Text("Submit"),
        ),
      ],
    );
  }
}
