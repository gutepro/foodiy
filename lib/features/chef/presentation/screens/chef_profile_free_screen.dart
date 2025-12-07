import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:foodiy/core/models/user_type.dart';
import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/features/chef/presentation/screens/chef_my_recipes_screen.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_upload_screen.dart';

class ChefProfileFreeScreen extends StatelessWidget {
  const ChefProfileFreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userType = CurrentUserService.instance.currentUserType;
    final isChef =
        userType == UserType.freeChef || userType == UserType.premiumChef;
    final isPremiumChef = userType == UserType.premiumChef;

    if (!isChef) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chef profile'),
          leading: const BackButton(),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('You are not a chef yet.'),
                SizedBox(height: 8),
                Text('Upgrade to a chef account to create and manage recipes.'),
                SizedBox(height: 8),
                Text('TODO: Connect to upgrade flow.'),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chef profile'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.restaurant_menu)),
              title: Text(user?.displayName ?? user?.email ?? 'Chef'),
              subtitle: Text(
                userType == UserType.freeChef
                    ? 'Free chef plan'
                    : 'Premium chef plan',
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Chef tools', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('My recipes'),
            subtitle: const Text('View and manage your recipes'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChefMyRecipesScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Upload new recipe'),
            subtitle: const Text('Create a new recipe as a chef'),
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
                title: const Text('Premium chef features'),
                subtitle: const Text(
                  'Upgrade to see stats and create public cookbooks',
                ),
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
