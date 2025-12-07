import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/features/analytics/application/recipe_analytics_service.dart';
import 'package:foodiy/features/profile/presentation/screens/change_password_screen.dart';
import 'package:foodiy/features/profile/presentation/screens/delete_account_screen.dart';
import 'package:foodiy/features/profile/presentation/screens/edit_personal_details_screen.dart';
import 'package:foodiy/features/recipe/domain/recipe.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_details_screen.dart';
import 'package:foodiy/features/settings/application/settings_service.dart';
import 'package:foodiy/features/settings/presentation/screens/notification_settings_screen.dart';
import 'package:foodiy/features/settings/presentation/screens/language_units_settings_screen.dart';
import 'package:foodiy/features/settings/presentation/screens/privacy_settings_screen.dart';
import 'package:foodiy/features/settings/presentation/screens/terms_of_use_screen.dart';
import 'package:foodiy/features/settings/presentation/screens/about_screen.dart';
import 'package:foodiy/features/playlist/application/personal_playlist_service.dart';
import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/core/services/access_control_service.dart';
import 'package:foodiy/core/models/user_type.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final settings = SettingsService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _ChefDashboardSection(),
          const Divider(),
          SwitchListTile(
            title: const Text('Play sound when timer finishes'),
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
              'Notifications',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification settings'),
            subtitle: const Text(
              'Choose which notifications you want to receive',
            ),
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
              'Account',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit personal details'),
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
            title: const Text('Change password'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Delete account'),
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
              'App preferences',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language and units'),
            subtitle: const Text('Choose app language and measurement units'),
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
              'Legal',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy policy'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PrivacySettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of use'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TermsOfUseScreen(),
                ),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'About',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Foodiy'),
            subtitle: const Text('Learn more about this app'),
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

class _ChefDashboardSection extends StatelessWidget {
  const _ChefDashboardSection();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final profile = CurrentUserService.instance.currentProfile;
    final userType = profile?.userType ?? UserType.freeUser;
    final access = AccessControlService.instance;
    final isPremiumChef = userType == UserType.premiumChef;

    if (!isPremiumChef) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Chef dashboard is available only for Premium chef accounts.',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      );
    }

    final uid = user?.uid ?? '';
    final playlistService = PersonalPlaylistService.instance;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
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
              final recipeIds = recipes.map((r) => r.id);
              final analytics = RecipeAnalyticsService.instance;
              final totalViews = analytics.getTotalViewsForRecipes(recipeIds);
              final cookbooks = playlistService.getCurrentUserPlaylists();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? (user?.email ?? 'Chef'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _StatCard(
                        label: 'My recipes',
                        value: '$totalRecipes',
                        icon: Icons.restaurant_menu,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                _ChefRecipesListScreen(recipes: recipes),
                          ),
                        ),
                      ),
                      _StatCard(
                        label: 'My cookbooks',
                        value: '${cookbooks.length}',
                        icon: Icons.menu_book,
                        onTap: () => context.push(AppRoutes.myPlaylists),
                      ),
                      _StatCard(
                        label: 'Total views',
                        value: '$totalViews',
                        icon: Icons.visibility,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'My recipes',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(child: CircularProgressIndicator())
                  else if (recipes.isEmpty)
                    const Text('No recipes yet.')
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recipes.length > 3 ? 3 : recipes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return ListTile(
                          leading: const Icon(Icons.restaurant_menu),
                          title: Text(recipe.title),
                          subtitle: Text('${recipe.steps.length} steps'),
                          onTap: () {
                            final localeCode =
                                Localizations.localeOf(context).languageCode;
                            context.push(
                              AppRoutes.recipeDetails,
                              extra: RecipeDetailsArgs(
                                id: recipe.id,
                                title: recipe.title,
                                imageUrl: recipe.imageUrl,
                                time: '${recipe.steps.length} steps',
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
                ],
              );
            },
          ),
        ),
      ),
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
    return SizedBox(
      width: 160,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 24),
                const SizedBox(height: 8),
                Text(value, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(label, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ),
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
    return Scaffold(
      appBar: AppBar(title: const Text('My recipes')),
      body: recipes.isEmpty
          ? const Center(child: Text('No recipes yet.'))
          : ListView.separated(
              itemCount: recipes.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return ListTile(
                  leading: const Icon(Icons.restaurant_menu),
                  title: Text(recipe.title),
                  subtitle: Text('${recipe.steps.length} steps'),
                  onTap: () {
                    context.push(
                      AppRoutes.recipeDetails,
                      extra: RecipeDetailsArgs(
                        id: recipe.id,
                        title: recipe.title,
                        imageUrl: recipe.imageUrl,
                        time: '${recipe.steps.length} steps',
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
