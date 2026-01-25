import 'package:flutter/material.dart';

import 'package:foodiy/features/settings/application/settings_service.dart';
import 'package:foodiy/l10n/app_localizations.dart';
import 'package:foodiy/shared/widgets/foodiy_app_bar.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: FoodiyAppBar(title: Text(l10n.notificationTitle)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.notificationPreferencesTitle,
              style: theme.textTheme.titleMedium,
            ),
          ),
          SwitchListTile(
            title: Text(l10n.notificationNewChefRecipesTitle),
            subtitle: Text(l10n.notificationNewChefRecipesSubtitle),
            value: settings.notifyNewChefRecipes,
            onChanged: (value) {
              setState(() {
                settings.notifyNewChefRecipes = value;
              });
            },
          ),
          SwitchListTile(
            title: Text(l10n.notificationPlaylistSuggestionsTitle),
            subtitle: Text(l10n.notificationPlaylistSuggestionsSubtitle),
            value: settings.notifyPlaylistSuggestions,
            onChanged: (value) {
              setState(() {
                settings.notifyPlaylistSuggestions = value;
              });
            },
          ),
          SwitchListTile(
            title: Text(l10n.notificationAppTipsTitle),
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
