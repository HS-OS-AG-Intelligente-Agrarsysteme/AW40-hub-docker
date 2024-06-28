import "package:flutter/material.dart";

class UploadTimeseriesForm extends StatefulWidget {
  const UploadTimeseriesForm({super.key});

  @override
  State<UploadTimeseriesForm> createState() => _UploadTimeseriesFormState();
}

class _UploadTimeseriesFormState extends State<UploadTimeseriesForm> {
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
          "UploadTimeseriesForm",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
