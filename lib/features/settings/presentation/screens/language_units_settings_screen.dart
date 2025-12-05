import 'package:flutter/material.dart';

import 'package:foodiy/features/settings/application/settings_service.dart';

class LanguageAndUnitsSettingsScreen extends StatefulWidget {
  const LanguageAndUnitsSettingsScreen({super.key});

  @override
  State<LanguageAndUnitsSettingsScreen> createState() =>
      _LanguageAndUnitsSettingsScreenState();
}

class _LanguageAndUnitsSettingsScreenState
    extends State<LanguageAndUnitsSettingsScreen> {
  final settings = SettingsService.instance;

  late String _languageCode;
  late String _units;

  @override
  void initState() {
    super.initState();
    _languageCode = settings.preferredLanguageCode;
    _units = settings.preferredUnits;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Language and units'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Language',
              style: theme.textTheme.titleMedium,
            ),
          ),
          RadioListTile<String>(
            title: const Text('Use device language (auto)'),
            value: 'auto',
            groupValue: _languageCode,
            onChanged: (value) {
              setState(() {
                _languageCode = value!;
                settings.preferredLanguageCode = _languageCode;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Hebrew'),
            value: 'he',
            groupValue: _languageCode,
            onChanged: (value) {
              setState(() {
                _languageCode = value!;
                settings.preferredLanguageCode = _languageCode;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: _languageCode,
            onChanged: (value) {
              setState(() {
                _languageCode = value!;
                settings.preferredLanguageCode = _languageCode;
              });
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Units',
              style: theme.textTheme.titleMedium,
            ),
          ),
          RadioListTile<String>(
            title: const Text('Metric (grams, Celsius)'),
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
            title: const Text('Imperial (cups, Fahrenheit)'),
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
