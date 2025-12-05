import 'package:flutter/material.dart';

import 'package:foodiy/core/models/user_type.dart';

class SubscriptionPaymentArgs {
  final UserType targetType;

  const SubscriptionPaymentArgs({required this.targetType});
}

class SubscriptionPaymentScreen extends StatelessWidget {
  const SubscriptionPaymentScreen({super.key, required this.args});

  final SubscriptionPaymentArgs args;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _labelForUserType(args.targetType);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confirm your plan', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'You are about to subscribe to:\n$title',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'In a real app this screen would integrate Apple/Google in app purchases.',
              style: theme.textTheme.bodySmall,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Integrate real payment flow.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Simulated payment success for $title'),
                    ),
                  );
                  Navigator.of(context).pop(true);
                },
                child: const Text('Simulate payment success'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
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
