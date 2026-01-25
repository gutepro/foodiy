import 'package:flutter/material.dart';

import 'package:foodiy/features/settings/application/settings_service.dart';
import 'package:foodiy/l10n/app_localizations.dart';
import 'package:foodiy/shared/widgets/foodiy_app_bar.dart';

class LanguageAndUnitsSettingsScreen extends StatefulWidget {
  const LanguageAndUnitsSettingsScreen({super.key});

  @override
  State<LanguageAndUnitsSettingsScreen> createState() =>
      _LanguageAndUnitsSettingsScreenState();
}

class _LanguageAndUnitsSettingsScreenState
    extends State<LanguageAndUnitsSettingsScreen> {
  final settings = SettingsService.instance;

  late String _units;

  @override
  void initState() {
    super.initState();
    _units = settings.preferredUnits;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final languageOptions = <String?, String>{
      null: l10n.languageSystemDefault,
      'en': l10n.languageEnglish,
      'he': l10n.languageHebrew,
      'es': l10n.languageSpanish,
      'fr': l10n.languageFrench,
      'ar': l10n.languageArabic,
      'zh': l10n.languageChinese,
      'ja': l10n.languageJapanese,
      'it': l10n.languageItalian,
    };

    return Scaffold(
      appBar: FoodiyAppBar(
        title: Text(l10n.languageUnitsTitle),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.languageSectionTitle,
              style: theme.textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ValueListenableBuilder<String?>(
              valueListenable: settings.localeListenable,
              builder: (context, localeCode, _) {
                return DropdownButtonFormField<String?>(
                  value: localeCode,
                  decoration: InputDecoration(
                    labelText: l10n.languagePickerLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: languageOptions.entries
                      .map(
                        (entry) => DropdownMenuItem<String?>(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    settings.setSelectedLocaleCode(value);
                  },
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.unitsSectionTitle,
              style: theme.textTheme.titleMedium,
            ),
          ),
          RadioListTile<String>(
            title: Text(l10n.unitsMetric),
            value: 'metric',
            groupValue: _units,
            onChanged: (value) {
              setState(() {
                _units = value!;
                settings.preferredUnits = _units;
              });
            },
          ),
          RadioListTile<String>(
            title: Text(l10n.unitsImperial),
            value: 'imperial',
            groupValue: _units,
            onChanged: (value) {
              setState(() {
                _units = value!;
                settings.preferredUnits = _units;
              });
            },
          ),
        ],
      ),
    );
  }
}
