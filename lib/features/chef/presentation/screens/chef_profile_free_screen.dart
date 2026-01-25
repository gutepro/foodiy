import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:foodiy/core/models/user_type.dart';
import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/features/chef/presentation/screens/chef_my_recipes_screen.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_upload_screen.dart';
import 'package:foodiy/shared/widgets/foodiy_app_bar.dart';
import 'package:foodiy/l10n/app_localizations.dart';

class ChefProfileFreeScreen extends StatelessWidget {
  const ChefProfileFreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userType = CurrentUserService.instance.currentUserType;
    final isChef =
        userType == UserType.freeChef || userType == UserType.premiumChef;
    final isPremiumChef = userType == UserType.premiumChef;
    final l10n = AppLocalizations.of(context)!;
    debugPrint(
      '[L10N] locale=${Localizations.localeOf(context)} screen=ChefProfileFree keys=profileChefToolsTitle,myRecipesTitle',
    );

    if (!isChef) {
      return Scaffold(
        appBar: FoodiyAppBar(title: Text(l10n.profileAccountTypeChef)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.chefNotEnabledTitle),
                const SizedBox(height: 8),
                Text(l10n.chefNotEnabledBody),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: FoodiyAppBar(title: Text(l10n.profileAccountTypeChef)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.restaurant_menu)),
              title: Text(
                user?.displayName ??
                    user?.email ??
                    l10n.homeChefPlaceholder,
              ),
            subtitle: Text(
              userType == UserType.freeChef
                  ? l10n.profileUserTypeFreeChef
                  : l10n.profileUserTypePremiumChef,
            ),
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.profileChefToolsTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.list),
            title: Text(l10n.myRecipesTitle),
            subtitle: Text(l10n.chefMyRecipesSubtitle),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChefMyRecipesScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.upload),
            title: Text(l10n.chefUploadNewRecipe),
            subtitle: Text(l10n.chefUploadNewRecipeSubtitle),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RecipeUploadScreen()),
              );
            },
          ),
          if (isPremiumChef) ...[
            const SizedBox(height: 8),
          ],
          if (userType == UserType.freeChef) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.workspace_premium),
                title: Text(l10n.chefPremiumFeaturesTitle),
                subtitle: Text(l10n.chefPremiumFeaturesBody),
                onTap: () {
                  // TODO: Navigate to package selection for upgrading to premium chef.
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
