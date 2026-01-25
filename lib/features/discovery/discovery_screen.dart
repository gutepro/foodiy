import 'package:flutter/material.dart';

import 'package:foodiy/features/discovery/discovery_feed.dart';
import 'package:foodiy/shared/widgets/foodiy_app_bar.dart';
import 'package:foodiy/l10n/app_localizations.dart';

class DiscoveryScreen extends StatelessWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    debugPrint(
      '[L10N] locale=${Localizations.localeOf(context)} screen=Discovery keys=navDiscover',
    );
    return Scaffold(
      appBar: FoodiyAppBar(title: Text(l10n.navDiscover)),
      body: const DiscoveryFeed(),
    );
  }
}
