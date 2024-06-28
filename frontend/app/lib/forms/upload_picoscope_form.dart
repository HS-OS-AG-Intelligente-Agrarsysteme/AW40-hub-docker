import "package:flutter/material.dart";

class UploadPicoscopeForm extends StatefulWidget {
  const UploadPicoscopeForm({super.key});

  @override
  State<UploadPicoscopeForm> createState() => _UploadPicoscopeFormState();
}

class _UploadPicoscopeFormState extends State<UploadPicoscopeForm> {
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
