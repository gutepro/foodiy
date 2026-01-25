import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/features/playlist/application/public_chef_playlist_service.dart';
import 'package:foodiy/features/playlist/domain/public_chef_playlist_models.dart';
import 'package:foodiy/features/recipe/application/recipe_firestore_service.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_details_screen.dart';
import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/shared/widgets/foodiy_app_bar.dart';
import 'package:foodiy/l10n/app_localizations.dart';

class PublicChefPlaylistDetailsArgs {
  final String playlistId;

  const PublicChefPlaylistDetailsArgs({required this.playlistId});
}

class PublicChefPlaylistDetailsScreen extends StatelessWidget {
  const PublicChefPlaylistDetailsScreen({super.key, required this.args});

  final PublicChefPlaylistDetailsArgs args;

  @override
  Widget build(BuildContext context) {
    final service = PublicChefPlaylistService.instance;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final l10n = AppLocalizations.of(context)!;
    debugPrint(
      '[L10N] locale=${Localizations.localeOf(context)} screen=public_chef_playlist_details',
    );

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('chef_playlists')
          .doc(args.playlistId)
          .snapshots(),
      builder: (context, playlistSnapshot) {
        if (playlistSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!playlistSnapshot.hasData || !playlistSnapshot.data!.exists) {
          return Scaffold(
            appBar: FoodiyAppBar(title: Text(l10n.cookbooksUntitled)),
            body: _ErrorState(onRetry: () => Navigator.of(context).maybePop()),
          );
        }

        final data = playlistSnapshot.data!.data() ?? {};
        final playlistId = playlistSnapshot.data!.id;
        final title =
            data['name'] as String? ??
            data['title'] as String? ??
            l10n.cookbooksUntitled;
        final chefName =
            data['ownerName'] as String? ??
            data['chefName'] as String? ??
            l10n.homeChefPlaceholder;
        final description = data['description'] as String? ?? '';
        final ownerId = data['ownerId'] as String? ?? '';
        final isOwner = currentUid != null && ownerId == currentUid;

        final theme = Theme.of(context);

        return Scaffold(
          appBar: FoodiyAppBar(
            title: Text(title),
            actions: [
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(l10n.cookbooksDeleteTitle),
                          content: Text(l10n.cookbooksDeleteWarning),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(l10n.homeCancel),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(l10n.cookbooksActionDelete),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirmed != true) return;
                    await service.deletePlaylist(playlistId);
                    if (context.mounted) {
                      Navigator.of(context).maybePop();
                    }
                  },
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text(
                        l10n.chefByLine(chefName),
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(description, style: theme.textTheme.bodyMedium),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.playlistPlayAllNotImplemented,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: Text(l10n.playlistPlayAll),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.recipesLabel,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('chef_playlists')
                      .doc(playlistId)
                      .collection('entries')
                      .snapshots(),
                  builder: (context, entriesSnapshot) {
                    if (entriesSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (entriesSnapshot.hasError) {
                      return Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(l10n.cookbooksLoadRecipesFailedSimple),
                      );
                    }
                    final entries = entriesSnapshot.data?.docs ?? const [];
                    if (entries.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.cookbooksNoRecipesYet),
                            if (isOwner) ...[
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.of(context).maybePop();
                                },
                                icon: const Icon(Icons.add),
                                label: Text(l10n.cookbooksAddRecipes),
                              ),
                            ],
                          ],
                        ),
                      );
                    }
                    return FutureBuilder<
                        List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                      future: _filterEntriesWithExistingRecipes(entries),
                      builder: (context, filteredSnapshot) {
                        if (filteredSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (filteredSnapshot.hasError) {
                          return Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(l10n.cookbooksLoadRecipesFailedSimple),
                          );
                        }
                        final filtered = filteredSnapshot.data ?? const [];
                        if (filtered.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.cookbooksNoRecipesAvailable),
                                if (isOwner) ...[
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).maybePop();
                                    },
                                    icon: const Icon(Icons.add),
                                    label: Text(l10n.cookbooksAddRecipes),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final entry = filtered[index].data();
                            final recipeId = entry['recipeId'] as String? ?? '';
                            final entryTitle =
                                entry['title'] as String? ??
                                l10n.untitledRecipe;
                            final imageUrl = entry['imageUrl'] as String? ?? '';
                            final time = entry['time'] as String? ?? '';
                            final difficulty =
                                entry['difficulty'] as String? ?? '';
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    color: Colors.grey.shade200,
                                                    alignment: Alignment.center,
                                                    child: const Icon(
                                                      Icons.restaurant,
                                                      size: 32,
                                                    ),
                                                  );
                                                },
                                          )
                                        : Container(
                                            color: Colors.grey.shade200,
                                            alignment: Alignment.center,
                                            child: const Icon(
                                              Icons.restaurant,
                                              size: 32,
                                            ),
                                          ),
                                  ),
                                ),
                                title: Text(entryTitle),
                                subtitle: Text(
                                  [
                                    time,
                                    difficulty,
                                  ].where((v) => v.isNotEmpty).join(' • '),
                                ),
                                onTap: () {
                                  if (recipeId.isEmpty) return;
                                  context.push(
                                    AppRoutes.recipeDetails,
                                    extra: RecipeDetailsArgs(
                                      id: recipeId,
                                      title: entryTitle,
                                      imageUrl: imageUrl,
                                      time: time,
                                      difficulty: difficulty,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            Text(
              l10n.homeLoadErrorHeadline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(l10n.cookbooksBack),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
          ],
        ),
      ),
    );
  }
}

Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
    _filterEntriesWithExistingRecipes(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> entries,
) async {
  final ids = entries
      .map((doc) => doc.data()['recipeId'] as String? ?? '')
      .where((id) => id.isNotEmpty)
      .toSet();
  if (ids.isEmpty) {
    return <QueryDocumentSnapshot<Map<String, dynamic>>>[];
  }
  final existing =
      await RecipeFirestoreService.instance.getExistingRecipeIds(ids);
  final filtered =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[];
  for (final doc in entries) {
    final recipeId = doc.data()['recipeId'] as String? ?? '';
    if (recipeId.isEmpty) continue;
    if (existing.contains(recipeId)) {
      filtered.add(doc);
    } else {
      unawaited(doc.reference.delete());
    }
  }
  return filtered;
}
