import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/core/widgets/recipe_image.dart';
import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_details_screen.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Popular chefs', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          const _PopularChefsSection(),
          const SizedBox(height: 24),
          Text('Popular recipes', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          const _PopularRecipesSection(),
        ],
      ),
    );
  }
}

class _PopularChefsSection extends StatelessWidget {
  const _PopularChefsSection();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return SizedBox(
      height: 110,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('isChef', isEqualTo: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load chefs'));
          }
          final docs = snapshot.data?.docs ?? const [];
          final filteredDocs = uid == null
              ? docs
              : docs.where((doc) => doc.id != uid).toList();
          if (filteredDocs.isEmpty) {
            return const Center(child: Text('No chefs yet'));
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filteredDocs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final data = filteredDocs[index].data();
              final name = data['displayName'] as String? ?? 'Chef';
              final photoUrl = data['photoUrl'] as String? ?? '';
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage:
                        photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                    backgroundColor: Colors.grey.shade300,
                    child: photoUrl.isEmpty
                        ? Icon(Icons.person, color: Colors.grey.shade600)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 80,
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push(AppRoutes.chefProfile,
                          extra: filteredDocs[index].id);
                    },
                    child: const Text('View'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _PopularRecipesSection extends StatelessWidget {
  const _PopularRecipesSection();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('recipes')
          .orderBy('views', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Failed to load recipes');
        }
        final docs = snapshot.data?.docs ?? const [];
        final filteredDocs = uid == null
            ? docs
            : docs
                .where((doc) {
                  final data = doc.data();
                  final chefId = data['chefId'] as String?;
                  return chefId == null || chefId != uid;
                })
                .toList();
        if (docs.isEmpty) {
          return const Text('No recipes yet.');
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data();
            final id = doc.id;
            final title = data['title'] as String? ?? 'Untitled';
            final imageUrl = data['imageUrl'] as String? ?? '';
            final stepsList = data['steps'] as List<dynamic>? ?? const [];
            final stepsCount = stepsList.length;
            return _RecipeCard(
              id: id,
              title: title,
              imageUrl: imageUrl,
              stepsCount: stepsCount,
            );
          },
        );
      },
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.stepsCount,
  });

  final String id;
  final String title;
  final String imageUrl;
  final int stepsCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          final localeCode = Localizations.localeOf(context).languageCode;
          context.push(
            AppRoutes.recipeDetails,
            extra: RecipeDetailsArgs(
              id: id,
              title: title,
              imageUrl: imageUrl,
              time: '$stepsCount steps',
              difficulty: '-',
              originalLanguageCode: localeCode,
              ingredients: const [],
              steps: const [],
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecipeImage(
              imageUrl: imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
