import "package:aw40_hub_frontend/configs/configs.dart";
import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/providers/providers.dart";
import "package:aw40_hub_frontend/services/services.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class UserSettingsPopupButton extends StatelessWidget {
  const UserSettingsPopupButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PopupMenuItem>(
      itemBuilder: (context) => [
        const PopupMenuItem(child: LanguageChooser()),
        PopupMenuItem(
          child: const Text("Logout"),
          onTap: () async => Provider.of<AuthProvider>(
            context,
            listen: false,
          ).logout(),
        ),
      ],
    );
  }
}

class LanguageChooser extends StatefulWidget {
  const LanguageChooser({
    super.key,
  });

  @override
  State<LanguageChooser> createState() => _LanguageChooserState();
}

class _LanguageChooserState extends State<LanguageChooser> {
  String selectedLocale = LocalizationService().currentLocale.languageCode;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(tr("general.language")),
        SegmentedButton(
          segments: kSupportedLocales.values.map((locale) {
            final String cc = locale.languageCode;
            return ButtonSegment(
              value: cc,
              label: Text(cc.toUpperCase()),
            );
          }).toList(),
          selected: <String>{selectedLocale},
          onSelectionChanged: (p0) async {
            final Locale? newLocale = kSupportedLocales[p0.first];
            if (newLocale == null) {
              throw AppException(
                exceptionType: ExceptionType.unexpectedNullValue,
                exceptionMessage:
                    "Locale returned from onSelectionChanged() was null.",
              );
            }
            await LocalizationService().changeUserLocale(
              buildContext: context,
              changedLocale: newLocale,
            );
            setState(() => selectedLocale = p0.first);
          },
        ),
      ],
    );
  }
}