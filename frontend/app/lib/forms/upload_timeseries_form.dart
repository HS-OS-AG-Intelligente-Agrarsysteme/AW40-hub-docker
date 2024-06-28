import "package:flutter/material.dart";

class UploadTimeseriesForm extends StatefulWidget {
  const UploadTimeseriesForm({super.key});

  @override
  State<UploadTimeseriesForm> createState() => _UploadTimeseriesFormState();
}

class _UploadTimeseriesFormState extends State<UploadTimeseriesForm> {
  bool _isChecked = false;

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              // ignore: no_runtimeType_tostring
              runtimeType.toString(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Checkbox(
              value: _isChecked,
              onChanged: (v) {
                if (v == null) return;
                setState(() => _isChecked = v);
              },
            ),
          ],
        ),
      ),
    );
  }
}
