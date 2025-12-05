import 'package:flutter/material.dart';

import 'package:foodiy/features/settings/application/settings_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final settings = SettingsService.instance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Notification preferences',
              style: theme.textTheme.titleMedium,
            ),
          ),
          SwitchListTile(
            title: const Text('New recipes from chefs'),
            subtitle: const Text('Get notified when chefs publish new recipes'),
            value: settings.notifyNewChefRecipes,
            onChanged: (value) {
              setState(() {
                settings.notifyNewChefRecipes = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Playlist suggestions'),
            subtitle: const Text(
              'Get suggestions for playlists you might like',
            ),
            value: settings.notifyPlaylistSuggestions,
            onChanged: (value) {
              setState(() {
                settings.notifyPlaylistSuggestions = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('App tips and updates'),
            value: settings.notifyAppTips,
            onChanged: (value) {
              setState(() {
                settings.notifyAppTips = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
