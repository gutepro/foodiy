import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:foodiy/core/models/user_type.dart';
import 'package:foodiy/core/services/access_control_service.dart';
import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/features/chef/presentation/screens/chef_my_recipes_screen.dart';
import 'package:foodiy/features/profile/application/user_profile_service.dart';
import 'package:foodiy/features/profile/domain/user_profile_models.dart';
import 'package:foodiy/features/settings/presentation/screens/settings_screen.dart';
import 'package:foodiy/features/subscription/presentation/screens/subscription_overview_screen.dart';
import 'package:foodiy/features/subscription/presentation/screens/package_selection_screen.dart';
import 'package:foodiy/features/user/presentation/screens/edit_profile_screen.dart';
import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/features/recipe/domain/recipe.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_details_screen.dart';
import 'package:foodiy/features/analytics/application/recipe_analytics_service.dart';
import 'package:foodiy/features/playlist/application/personal_playlist_service.dart';
import 'package:foodiy/features/chef/application/chef_recipes_service.dart';
import 'package:foodiy/l10n/app_localizations.dart';

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
    final isChef = access.isChef(userType);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
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
                onBackgroundImageError:
                    (profile?.photoUrl ?? '').isNotEmpty ? (_, __) {} : null,
              ),
              title: Text(
                _displayName(profile) ??
                    firebaseUser?.displayName ??
                    l10n.profileAnonymousUser,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(firebaseUser?.email ?? l10n.profileNoEmail),
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
          if (isChef)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.restaurant),
                label: Text(l10n.profileEditChefProfile),
                onPressed: () {
                  final uid = firebaseUser?.uid ?? '';
                  if (uid.isEmpty) return;
                  debugPrint('[EDIT_PROFILE_NAV] uid=$uid');
                  context.push(AppRoutes.editChefProfile, extra: uid).then(
                    (result) {
                      if (result == true && mounted) {
                        setState(() {});
                      }
                    },
                  );
                },
              ),
            ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user),
              title: Text(_labelForUserType(userType, l10n)),
              subtitle: Text(
                access.isChef(userType)
                    ? l10n.profileAccountTypeChef
                    : l10n.profileAccountTypeUser,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.profilePlanBillingTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: Text(l10n.profileSubscriptionTitle),
            subtitle: Text(l10n.profileSubscriptionSubtitle),
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
            Text(
              l10n.profileChefToolsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const _ChefDashboardSection(),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.profileRecentActivityTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () {
                  context.push(AppRoutes.userActivity);
                },
                child: Text(l10n.profileSeeAll),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (activity.isEmpty)
            Text(l10n.profileNoRecentActivity)
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
            l10n.profileSettingsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.profileOpenSettings),
            subtitle: Text(l10n.profileOpenSettingsSubtitle),
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

String _labelForUserType(UserType type, AppLocalizations l10n) {
  switch (type) {
    case UserType.freeUser:
      return l10n.profileUserTypeFreeUser;
    case UserType.premiumUser:
      return l10n.profileUserTypePremiumUser;
    case UserType.freeChef:
      return l10n.profileUserTypeFreeChef;
    case UserType.premiumChef:
      return l10n.profileUserTypePremiumChef;
  }
}

class _ChefDashboardSection extends StatelessWidget {
  const _ChefDashboardSection();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final profile = CurrentUserService.instance.currentProfile;
    final userType = profile?.userType ?? UserType.freeUser;
    final access = AccessControlService.instance;
    final isChef = access.isChef(userType);
    final isFreeChef = userType == UserType.freeChef;
    final l10n = AppLocalizations.of(context)!;

    if (!isChef) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          l10n.profileChefDashboardUnavailable,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );
    }

    final uid = user?.uid ?? '';
    final playlistService = PersonalPlaylistService.instance;
    final userDocStream = uid.isEmpty
        ? Stream<DocumentSnapshot<Map<String, dynamic>>>.empty()
        : FirebaseFirestore.instance.collection('users').doc(uid).snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userDocStream,
      builder: (context, userSnapshot) {
        final followersCount = userSnapshot.data?.data()?['followersCount']
                as int? ??
            profile?.followersCount ??
            0;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<List<Recipe>>(
              stream: FirebaseFirestore.instance
                  .collection('recipes')
                  .where('chefId', isEqualTo: uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots()
                  .map((snapshot) => snapshot.docs.map((doc) {
                        final data = doc.data();
                        data['id'] = doc.id;
                        return Recipe.fromJson(data, docId: doc.id);
                      }).toList()),
              builder: (context, snapshot) {
                final recipes = snapshot.data ?? const <Recipe>[];
                final totalRecipes = recipes.length;
                final cookbooks = playlistService.getCurrentUserPlaylists();
                final recipeLimit = ChefRecipesService.kFreeChefRecipeLimit;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profileChefDashboardTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.profileChefDashboardSubtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Theme.of(context).hintColor),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => context.push(AppRoutes.recipeCreate),
                          icon: const Icon(Icons.cloud_upload_outlined),
                          label: Text(l10n.profileUploadRecipe),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.push(AppRoutes.myPlaylists),
                          icon: const Icon(Icons.menu_book_outlined),
                          label: Text(l10n.profileCreateCookbook),
                        ),
                        TextButton.icon(
                          onPressed: () => _showInsights(
                            context,
                            recipes: totalRecipes,
                            cookbooks: cookbooks.length,
                            followers: followersCount,
                            isFreeChef: isFreeChef,
                          ),
                          icon: const Icon(Icons.assessment_outlined),
                          label: Text(l10n.profileChefInsights),
                        ),
                      ],
                    ),
                    if (isFreeChef) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.profileFreeChefLimitMessage(
                                  recipeLimit,
                                  totalRecipes,
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.push(
                                AppRoutes.selectPackage,
                                extra: PlanPickerEntrySource.settings,
                              ),
                              child: Text(l10n.profileUpgradeToPremiumChef),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.1,
                      children: [
                        _StatCard(
                          label: l10n.profileStatMyRecipes,
                          value: '$totalRecipes',
                          icon: Icons.restaurant_menu,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ChefMyRecipesScreen(),
                            ),
                          ),
                        ),
                        _StatCard(
                          label: l10n.profileStatMyCookbooks,
                          value: '${cookbooks.length}',
                          icon: Icons.menu_book,
                          onTap: () => context.push(AppRoutes.myPlaylists),
                        ),
                        _StatCard(
                          label: l10n.profileStatFollowers,
                          value: followersCount > 0 ? '$followersCount' : '-',
                          icon: Icons.group_outlined,
                        ),
                        _StatCard(
                          label: l10n.profileStatChefInsights,
                          value: '',
                          icon: Icons.assessment_outlined,
                          onTap: () => _showInsights(
                            context,
                            recipes: totalRecipes,
                            cookbooks: cookbooks.length,
                            followers: followersCount,
                            isFreeChef: isFreeChef,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 22),
              const SizedBox(height: 6),
              Text(
                value,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showInsights(
  BuildContext context, {
  required int recipes,
  required int cookbooks,
  required int followers,
  required bool isFreeChef,
}) {
  showDialog<void>(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final l10n = AppLocalizations.of(ctx)!;
      return AlertDialog(
        title: Text(l10n.profileChefInsights),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.profileInsightsDescription,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            _InsightRow(label: l10n.profileInsightsRecipes, value: '$recipes'),
            _InsightRow(
              label: l10n.profileInsightsCookbooks,
              value: '$cookbooks',
            ),
            _InsightRow(
              label: l10n.profileInsightsFollowers,
              value: followers > 0 ? '$followers' : '-',
            ),
            if (isFreeChef) ...[
              const SizedBox(height: 12),
              Text(
                l10n.profileInsightsPremiumNote,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
        actions: [
          if (isFreeChef)
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.push(
                  AppRoutes.selectPackage,
                  extra: PlanPickerEntrySource.settings,
                );
              },
              child: Text(l10n.profileUpgradeToPremiumChef),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.profileInsightsClose),
          ),
        ],
      );
    },
  );
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChefRecipesListScreen extends StatelessWidget {
  const _ChefRecipesListScreen({required this.recipes});

  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myRecipesTitle)),
      body: recipes.isEmpty
          ? Center(child: Text(l10n.noRecipesYet))
          : ListView.separated(
              itemCount: recipes.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return ListTile(
                  leading: const Icon(Icons.restaurant_menu),
                  title: Text(recipe.title),
                  subtitle: Text(
                    l10n.profileStepsCount(recipe.steps.length),
                  ),
                  onTap: () {
                    context.push(
                      AppRoutes.recipeDetails,
                      extra: RecipeDetailsArgs(
                        id: recipe.id,
                        title: recipe.title,
                        imageUrl:
                            recipe.coverImageUrl ?? recipe.imageUrl ?? '',
                        time: l10n.profileStepsCount(recipe.steps.length),
                        difficulty: '-',
                        originalLanguageCode: localeCode,
                        ingredients: recipe.ingredients,
                        steps: recipe.steps,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

String? _displayName(AppUserProfile? profile) {
  if (profile == null) return null;
  if (profile.displayName != null && profile.displayName!.trim().isNotEmpty) {
    return profile.displayName;
  }
  final first = (profile.firstName ?? '').trim();
  final last = (profile.lastName ?? '').trim();
  if (first.isEmpty && last.isEmpty) return null;
  return [first, last].where((s) => s.isNotEmpty).join(' ');
}
