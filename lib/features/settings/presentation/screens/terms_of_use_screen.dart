import 'package:flutter/material.dart';
import 'package:foodiy/l10n/app_localizations.dart';
import 'package:foodiy/shared/widgets/foodiy_app_bar.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: FoodiyAppBar(
        title: Text(l10n.termsTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            l10n.termsPlaceholder,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
