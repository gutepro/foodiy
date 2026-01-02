import 'package:flutter/material.dart';
import 'package:foodiy/l10n/app_localizations.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            l10n.privacyPlaceholder,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
