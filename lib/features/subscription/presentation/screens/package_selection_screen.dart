import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodiy/core/models/user_type.dart';
import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/features/profile/application/user_profile_service.dart';
import 'package:foodiy/features/subscription/presentation/screens/subscription_payment_screen.dart';

class PackageSelectionScreen extends StatelessWidget {
  const PackageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose your plan'),
        leading: const BackButton(),
        // TODO: Decide if back button is allowed on first time flow.
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose how you want to use foodiy',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Select the package that fits you best. You can change it later.',
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _PackageCard(
                    icon: Icons.person_outline,
                    title: 'Free user',
                    onTap: () => _showPackageDetailsDialog(
                      context,
                      targetType: UserType.freeUser,
                    ),
                  ),
                  _PackageCard(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Premium user',
                    onTap: () => _showPackageDetailsDialog(
                      context,
                      targetType: UserType.premiumUser,
                    ),
                  ),
                  _PackageCard(
                    icon: Icons.restaurant_menu_outlined,
                    title: 'Free chef',
                    onTap: () => _showPackageDetailsDialog(
                      context,
                      targetType: UserType.freeChef,
                    ),
                  ),
                  _PackageCard(
                    icon: Icons.emoji_events_outlined,
                    title: 'Premium chef',
                    onTap: () => _showPackageDetailsDialog(
                      context,
                      targetType: UserType.premiumChef,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showPackageDetailsDialog(
  BuildContext context, {
  required UserType targetType,
}) async {
  final title = _titleForUserType(targetType);
  final description = _descriptionForUserType(targetType);
  final isPaid = _isPaidPackage(targetType);
  final plan = _planForUserType(targetType);

  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm and change'),
          ),
        ],
      );
    },
  );

  if (result != true) return;

  final currentUserService = CurrentUserService.instance;
  final profileService = UserProfileService.instance;
  final currentProfile = currentUserService.currentProfile;
  if (currentProfile == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You need to be signed in to change plan.')),
    );
    return;
  }

  if (isPaid) {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SubscriptionPaymentScreen(
          args: SubscriptionPaymentArgs(targetType: targetType),
        ),
      ),
    );

    if (result != true) {
      return;
    }

    currentUserService.updateUserType(targetType);
    await _updateUserDoc(targetType);
    profileService.logActivity(
      'Changed plan to ${_titleForUserType(targetType)}',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Plan changed to ${_titleForUserType(targetType)}'),
      ),
    );
    if (context.mounted) {
      Navigator.of(context).maybePop();
    }
  } else {
    currentUserService.updateUserType(targetType);
    await _updateUserDoc(targetType);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Plan changed to ${_titleForUserType(targetType)}'),
      ),
    );
    profileService.logActivity(
      'Changed plan to ${_titleForUserType(targetType)}',
    );
    if (context.mounted) {
      Navigator.of(context).maybePop();
    }
  }
}

String _titleForUserType(UserType type) {
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

bool _isPaidPackage(UserType type) {
  return type == UserType.premiumUser || type == UserType.premiumChef;
}

String _descriptionForUserType(UserType type) {
  switch (type) {
    case UserType.freeUser:
      return 'Free user plan.\nIncludes access to recipes with ads and basic features.';
    case UserType.premiumUser:
      return 'Premium user plan.\nNo ads, personal playlists and advanced player features.';
    case UserType.freeChef:
      return 'Free chef plan.\nUpload a limited number of recipes and basic chef profile.';
    case UserType.premiumChef:
      return 'Premium chef plan.\nUnlimited uploads, public playlists, stats and boosted exposure.';
  }
}

SubscriptionPlan _planForUserType(UserType type) {
  switch (type) {
    case UserType.freeUser:
      return SubscriptionPlan.none;
    case UserType.premiumUser:
      return SubscriptionPlan.userMonthly;
    case UserType.freeChef:
      return SubscriptionPlan.none;
    case UserType.premiumChef:
      return SubscriptionPlan.chefMonthly;
  }
}

Future<void> _updateUserDoc(UserType targetType) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;
  final userTypeString = _userTypeString(targetType);
  final isChef = targetType == UserType.freeChef || targetType == UserType.premiumChef;
  await FirebaseFirestore.instance.collection('users').doc(uid).update({
    'userType': userTypeString,
    'isChef': isChef,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

String _userTypeString(UserType type) {
  switch (type) {
    case UserType.freeUser:
      return 'homeCook';
    case UserType.premiumUser:
      return 'homeCook';
    case UserType.freeChef:
      return 'chef';
    case UserType.premiumChef:
      return 'premiumChef';
  }
}
