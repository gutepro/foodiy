import 'package:flutter/material.dart';

import 'package:foodiy/features/settings/application/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final settings = SettingsService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Play sound when timer finishes'),
            value: settings.playTimerSound,
            onChanged: (value) {
              setState(() {
                settings.playTimerSound = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
