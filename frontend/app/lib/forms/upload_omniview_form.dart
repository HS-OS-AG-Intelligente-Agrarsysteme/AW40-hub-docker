import "package:flutter/material.dart";

class UploadOmniviewForm extends StatefulWidget {
  const UploadOmniviewForm({super.key});

  @override
  State<UploadOmniviewForm> createState() => _UploadOmniviewFormState();
}

class _UploadOmniviewFormState extends State<UploadOmniviewForm> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.onTertiaryContainer,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          "UploadOmniviewForm",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
