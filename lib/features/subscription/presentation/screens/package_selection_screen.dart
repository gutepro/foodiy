import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodiy/core/models/user_type.dart';
import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/core/services/subscription_service.dart';
import 'package:foodiy/features/profile/application/user_profile_service.dart';
import 'package:foodiy/features/subscription/presentation/screens/subscription_payment_screen.dart';
import 'package:foodiy/router/app_routes.dart';

enum PlanPickerEntrySource { onboarding, settings }

class PackageSelectionScreen extends StatefulWidget {
  const PackageSelectionScreen({super.key, required this.source});

  final PlanPickerEntrySource source;

  @override
  State<PackageSelectionScreen> createState() => _PackageSelectionScreenState();
}

class _PackageSelectionScreenState extends State<PackageSelectionScreen> {
  bool _saving = false;
  UserType? _selectedPlan;

  @override
  void initState() {
    super.initState();
    final profile = CurrentUserService.instance.currentProfile;
    _selectedPlan = profile?.userType;
    final hasPlan = (profile?.subscriptionPlanId.isNotEmpty ?? false) ||
        (profile?.onboardingComplete ?? false);
    debugPrint(
      '[PLAN_PICKER] source=${widget.source} hasPlan=$hasPlan selected=$_selectedPlan',
    );
    if (widget.source == PlanPickerEntrySource.onboarding && hasPlan) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go(AppRoutes.home);
      });
    }
  }

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
                    subtitle: 'Stay free',
                    price: 'Free',
                    enabled: !_saving,
                    selected: _selectedPlan == UserType.freeUser,
                    onTap: () => setState(() => _selectedPlan = UserType.freeUser),
                  ),
                  _PackageCard(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Premium user',
                    subtitle: 'No ads',
                    price: '\$4.99 / month',
                    enabled: !_saving,
                    selected: _selectedPlan == UserType.premiumUser,
                    onTap: () => setState(() => _selectedPlan = UserType.premiumUser),
                  ),
                  _PackageCard(
                    icon: Icons.restaurant_menu_outlined,
                    title: 'Free chef',
                    subtitle: 'Up to 10 uploads',
                    price: 'Free',
                    enabled: !_saving,
                    selected: _selectedPlan == UserType.freeChef,
                    onTap: () => setState(() => _selectedPlan = UserType.freeChef),
                  ),
                  _PackageCard(
                    icon: Icons.emoji_events_outlined,
                    title: 'Premium chef',
                    subtitle: 'Unlimited uploads',
                    price: '\$9.99 / month',
                    enabled: !_saving,
                    selected: _selectedPlan == UserType.premiumChef,
                    onTap: () => setState(() => _selectedPlan = UserType.premiumChef),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_selectedPlan == null || _saving) ? null : _persistSelection,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _persistSelection() async {
    final targetType = _selectedPlan;
    if (targetType == null || _saving) return;
    final currentUserService = CurrentUserService.instance;
    final profileService = UserProfileService.instance;
    final currentProfile = currentUserService.currentProfile;
    if (currentProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be signed in to change plan.')),
      );
      return;
    }

    setState(() => _saving = true);
    final isPaid = _isPaidPackage(targetType);
    debugPrint('[PLAN_PICKER_SAVE] start target=$targetType isPaid=$isPaid');
    try {
      if (isPaid) {
        if (kReleaseMode) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchases coming soon.')),
          );
          return;
        }
        final paymentResult = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => SubscriptionPaymentScreen(
              args: SubscriptionPaymentArgs(targetType: targetType),
            ),
          ),
        );

        if (paymentResult != true) {
          return;
        }

        currentUserService.updateUserType(targetType);
        await SubscriptionService.instance.simulateUpgrade(targetType);
        await _updateUserDoc(targetType);
        profileService.logActivity(
          'Changed plan to ${_titleForUserType(targetType)}',
        );
      } else {
        currentUserService.updateUserType(targetType);
        await _updateUserDoc(targetType);
        profileService.logActivity(
          'Changed plan to ${_titleForUserType(targetType)}',
        );
      }
      if (!mounted) return;
      debugPrint('[PLAN_PICKER_SAVE] ok target=$targetType');
      context.go(AppRoutes.home);
    } catch (e) {
      debugPrint('[PLAN_PICKER_SAVE] error=$e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save plan. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.onTap,
    this.enabled = true,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String price;
  final VoidCallback onTap;
  final bool enabled;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
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
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.25),
            ),
            const SizedBox(height: 10),
            Text(
              price,
              textAlign: TextAlign.center,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
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
  final priceLabel = _priceForUserType(targetType);

  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text('$description\n$priceLabel'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              isPaid
                  ? (targetType == UserType.premiumChef
                      ? 'Upgrade to Premium Chef - $priceLabel'
                      : 'Upgrade to Premium - $priceLabel')
                  : 'Confirm and change',
            ),
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
    if (kReleaseMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchases coming soon.')),
      );
      return;
    }
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
    await SubscriptionService.instance.simulateUpgrade(targetType);
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

String _priceForUserType(UserType type) {
  switch (type) {
    case UserType.premiumUser:
      return '\$4.99/month';
    case UserType.premiumChef:
      return '\$9.99/month';
    default:
      return 'Free';
  }
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

Future<void> _updateUserDoc(UserType targetType) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;
  final userTypeString = _userTypeString(targetType);
  final isChef = targetType == UserType.freeChef || targetType == UserType.premiumChef;
  final tier = _tierString(targetType);
  final planId = targetType == UserType.premiumChef
      ? 'premium_chef'
      : targetType == UserType.premiumUser
          ? 'premium_user'
          : '';
  final status = planId.isNotEmpty ? 'active' : 'inactive';
  await FirebaseFirestore.instance.collection('users').doc(uid).update({
    'userType': userTypeString,
    'tier': tier,
    'isChef': isChef,
    'subscriptionPlanId': planId,
    'subscriptionStatus': status,
    'onboardingComplete': true,
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

String _tierString(UserType type) {
  switch (type) {
    case UserType.freeUser:
      return 'freeUser';
    case UserType.premiumUser:
      return 'premiumUser';
    case UserType.freeChef:
      return 'freeChef';
    case UserType.premiumChef:
      return 'premiumChef';
  }
}
