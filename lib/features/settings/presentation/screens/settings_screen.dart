import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/core/services/session_service.dart';
import 'package:foodiy/features/profile/presentation/screens/change_password_screen.dart';
import 'package:foodiy/features/profile/presentation/screens/delete_account_screen.dart';
import 'package:foodiy/features/profile/presentation/screens/edit_personal_details_screen.dart';
import 'package:foodiy/features/settings/application/settings_service.dart';
import 'package:foodiy/features/settings/presentation/screens/notification_settings_screen.dart';
import 'package:foodiy/features/settings/presentation/screens/language_units_settings_screen.dart';
import 'package:foodiy/features/settings/presentation/screens/privacy_settings_screen.dart';
import 'package:foodiy/features/settings/presentation/screens/terms_of_use_screen.dart';
import 'package:foodiy/features/settings/presentation/screens/about_screen.dart';
import 'package:foodiy/features/legal/presentation/screens/legal_document_screen.dart';
import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final settings = SettingsService.instance;
  bool _isSigningOut = false;

  Future<void> _handleLogout() async {
    if (_isSigningOut) return;
    setState(() => _isSigningOut = true);
    try {
      await SessionService.instance.signOut();
      if (!mounted) return;
      context.go(AppRoutes.login);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.settingsLogoutFail)),
      );
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l10n.settingsPlayTimerSound),
            value: settings.playTimerSound,
            onChanged: (value) {
              setState(() {
                settings.playTimerSound = value;
              });
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              l10n.settingsNotificationsSection,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(l10n.settingsNotificationSettings),
            subtitle: Text(l10n.settingsNotificationSettingsSubtitle),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              l10n.settingsAccountSection,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(l10n.settingsEditPersonalDetails),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EditPersonalDetailsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text(l10n.settingsChangePassword),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.settingsLogout),
            onTap: _isSigningOut ? null : _handleLogout,
            trailing: _isSigningOut
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: Text(l10n.settingsDeleteAccount),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DeleteAccountScreen()),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              l10n.settingsPreferencesSection,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.settingsLanguageUnits),
            subtitle: Text(l10n.settingsLanguageUnitsSubtitle),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LanguageAndUnitsSettingsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              l10n.settingsLegalSection,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(l10n.settingsTermsOfUse),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LegalDocumentScreen(
                    title: l10n.settingsTermsOfUse,
                    assetPath: 'assets/legal/terms_of_use_en.md',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: Text(l10n.settingsPrivacyPolicy),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LegalDocumentScreen(
                    title: l10n.settingsPrivacyPolicy,
                    assetPath: 'assets/legal/privacy_policy_en.md',
                  ),
                ),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              l10n.settingsAboutSection,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.settingsAboutApp),
            subtitle: Text(l10n.settingsAboutAppSubtitle),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AboutScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
