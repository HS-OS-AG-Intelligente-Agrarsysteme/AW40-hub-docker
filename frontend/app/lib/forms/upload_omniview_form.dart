import "package:flutter/material.dart";

class UploadOmniviewForm extends StatefulWidget {
  const UploadOmniviewForm({super.key});

  @override
  State<UploadOmniviewForm> createState() => _UploadOmniviewFormState();
}

class _UploadOmniviewFormState extends State<UploadOmniviewForm> {
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
