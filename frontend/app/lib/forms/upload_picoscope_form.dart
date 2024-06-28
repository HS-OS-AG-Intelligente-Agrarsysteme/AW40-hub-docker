import "package:flutter/material.dart";

class UploadPicoscopeForm extends StatefulWidget {
  const UploadPicoscopeForm({super.key});

  @override
  State<UploadPicoscopeForm> createState() => _UploadPicoscopeFormState();
}

class _UploadPicoscopeFormState extends State<UploadPicoscopeForm> {
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
          "UploadPicoscopeForm",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
