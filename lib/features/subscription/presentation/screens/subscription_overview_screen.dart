import 'package:flutter/material.dart';

import 'package:foodiy/core/models/user_type.dart';
import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/features/subscription/presentation/screens/package_selection_screen.dart';

class SubscriptionOverviewScreen extends StatelessWidget {
  const SubscriptionOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserService = CurrentUserService.instance;
    final profile = currentUserService.currentProfile;
    final userType = profile?.userType ?? UserType.freeUser;
    final subscriptionPlan = profile?.subscriptionPlan ?? SubscriptionPlan.none;
    final theme = Theme.of(context);

    final currentPlanLabel = _labelForUserType(userType);
    final currentPlanDescription = _descriptionForUserType(userType);
    final isFree = userType == UserType.freeUser || userType == UserType.freeChef;
    final planBillingLabel = _billingLabelForPlan(subscriptionPlan);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My subscription'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current plan', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.workspace_premium),
                title: Text(currentPlanLabel),
                subtitle: Text('$currentPlanDescription\n$planBillingLabel'),
              ),
            ),
            const SizedBox(height: 24),
            Text('Available plans', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            const _PlanRow(
              title: 'Free user',
              description: 'View recipes with ads and basic features.',
            ),
            const _PlanRow(
              title: 'Premium user',
              description: 'No ads, personal playlists and advanced player.',
            ),
            const _PlanRow(
              title: 'Free chef',
              description: 'Upload limited recipes, basic chef tools.',
            ),
            const _PlanRow(
              title: 'Premium chef',
              description: 'Unlimited uploads, public playlists, stats and promotion.',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PackageSelectionScreen(),
                    ),
                  );
                },
                child: const Text('Change plan'),
              ),
            ),
            if (isFree) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PackageSelectionScreen(),
                      ),
                    );
                  },
                  child: const Text('Upgrade now'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        title: Text(title, style: theme.textTheme.bodyMedium),
        subtitle: Text(description),
      ),
    );
  }
}

String _labelForUserType(UserType type) {
  switch (type) {
    case UserType.freeUser:
      return 'Free user';
    case UserType.premiumUser:
      return 'Premium user';
    case UserType.freeChef:
      return 'Free chef';
    case UserType.premiumChef:
      return 'Premium chef';
  }
}

String _descriptionForUserType(UserType type) {
  switch (type) {
    case UserType.freeUser:
      return 'Basic user plan with ads and limited features.';
    case UserType.premiumUser:
      return 'No ads, personal playlists and better experience.';
    case UserType.freeChef:
      return 'Chef plan with upload limit and basic tools.';
    case UserType.premiumChef:
      return 'Full chef plan with unlimited uploads, public playlists and stats.';
  }
}

String _billingLabelForPlan(SubscriptionPlan plan) {
  switch (plan) {
    case SubscriptionPlan.none:
      return 'No active subscription';
    case SubscriptionPlan.userMonthly:
      return 'Monthly user plan';
    case SubscriptionPlan.userYearly:
      return 'Yearly user plan';
    case SubscriptionPlan.chefMonthly:
      return 'Monthly chef plan';
    case SubscriptionPlan.chefYearly:
      return 'Yearly chef plan';
  }
}
