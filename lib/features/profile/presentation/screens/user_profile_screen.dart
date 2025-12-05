import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/core/models/user_type.dart';
import 'package:foodiy/core/services/access_control_service.dart';
import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/features/chef/presentation/screens/chef_profile_free_screen.dart';
import 'package:foodiy/features/profile/application/user_profile_service.dart';
import 'package:foodiy/features/profile/domain/user_profile_models.dart';
import 'package:foodiy/features/settings/presentation/screens/settings_screen.dart';
import 'package:foodiy/features/subscription/presentation/screens/subscription_overview_screen.dart';
import 'package:foodiy/features/user/presentation/screens/edit_profile_screen.dart';
import 'package:foodiy/router/app_routes.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final profileService = CurrentUserService.instance;
    final userType = profileService.currentUserType;
    final profile = profileService.currentProfile;
    final access = AccessControlService.instance;
    final userProfileService = UserProfileService.instance;
    final activity = userProfileService.activity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                ),
              );
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                radius: 22,
                backgroundImage: (profile?.photoUrl ?? '').isNotEmpty
                    ? NetworkImage(profile!.photoUrl!)
                    : null,
                child: (profile?.photoUrl ?? '').isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(
                _displayName(profile) ??
                    firebaseUser?.displayName ??
                    'Anonymous user',
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(firebaseUser?.email ?? 'No email'),
                  if ((profile?.chefBio ?? '').isNotEmpty)
                    Text(profile!.chefBio!),
                  if ((profile?.websiteUrl ?? '').isNotEmpty &&
                      access.isChef(userType))
                    Text(profile!.websiteUrl!),
                ],
              ),
              trailing: Text(
                firebaseUser?.uid.substring(0, 6) ?? '',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user),
              title: Text(_labelForUserType(userType)),
              subtitle: Text(
                access.isChef(userType)
                    ? 'Chef account'
                    : 'Regular user account',
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Plan and billing',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: const Text('View my subscription'),
            subtitle: const Text('See your current plan and upgrade options'),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SubscriptionOverviewScreen(),
                ),
              );
              if (mounted) {
                setState(() {});
              }
            },
          ),
          if (userType == UserType.freeChef ||
              userType == UserType.premiumChef) ...[
            const SizedBox(height: 24),
            Text('Chef tools', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Chef profile'),
              subtitle: const Text('View and manage your chef recipes'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ChefProfileFreeScreen(),
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent activity',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () {
                  context.push(AppRoutes.userActivity);
                },
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (activity.isEmpty)
            const Text('No recent activity yet')
          else
            ...activity
                .take(3)
                .map(
                  (item) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.history, size: 20),
                    title: Text(item.description),
                    subtitle: Text(item.timestamp.toLocal().toString()),
                  ),
                )
                .toList(),
          const SizedBox(height: 24),
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Open settings'),
            subtitle: const Text('Account, preferences and more'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
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

String? _displayName(AppUserProfile? profile) {
  if (profile == null) return null;
  final first = (profile.firstName ?? '').trim();
  final last = (profile.lastName ?? '').trim();
  if (first.isEmpty && last.isEmpty) return null;
  return [first, last].where((s) => s.isNotEmpty).join(' ');
}
