import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/core/widgets/recipe_image.dart';
import 'package:foodiy/features/playlist/domain/public_chef_playlist_models.dart';
import 'package:foodiy/features/playlist/presentation/screens/playlist_details_screen.dart';
import 'package:foodiy/router/app_routes.dart';

class ChefProfileScreen extends StatelessWidget {
  const ChefProfileScreen({super.key, required this.chefId});

  final String chefId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chef Profile')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream:
            FirebaseFirestore.instance.collection('users').doc(chefId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Chef not found'));
          }
          final data = snapshot.data!.data() ?? {};
          final name = data['displayName'] as String? ?? 'Chef';
          final photoUrl = data['photoUrl'] as String? ?? '';
          final bio = data['chefBio'] as String? ?? '';
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      backgroundColor: Colors.grey.shade300,
                      child: photoUrl.isEmpty
                          ? Icon(Icons.person, color: Colors.grey.shade600)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            bio.isNotEmpty ? bio : 'No bio provided',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
              'Public cookbooks',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _ChefPlaylistsList(
                chefId: chefId,
                chefName: name,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChefPlaylistsList extends StatelessWidget {
  const _ChefPlaylistsList({required this.chefId, required this.chefName});

  final String chefId;
  final String chefName;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('public_chef_playlists')
          .where('chefId', isEqualTo: chefId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Failed to load cookbooks');
        }
        final docs = snapshot.data?.docs ?? const [];
        if (docs.isEmpty) {
          return const Text('This chef has no public cookbooks yet.');
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final title = data['title'] as String? ?? 'Untitled cookbook';
            final description = data['description'] as String? ?? '';
            final playlistId = doc.id;
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.menu_book),
                title: Text(title),
                subtitle: Text(
                  description.isNotEmpty ? description : 'Chef cookbook',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () async {
                  final entriesSnap =
                      await doc.reference.collection('entries').get();
                  final entries = entriesSnap.docs
                      .map(
                        (e) => PublicChefPlaylistEntry.fromJson(e.data()),
                      )
                      .toList();
                  final imageUrl =
                      entries.isNotEmpty ? entries.first.imageUrl : '';
                  final args = PlaylistDetailsArgs(
                    title: title,
                    imageUrl: imageUrl,
                    description: description.isNotEmpty
                        ? description
                        : 'Cookbook by $chefName',
                    totalTime: '',
                    recipes: entries
                        .map(
                          (e) => PlaylistRecipeItem(
                            title: e.title,
                            imageUrl: e.imageUrl,
                            time: e.time,
                          ),
                        )
                        .toList(),
                  );
                  if (!context.mounted) return;
                  context.push(AppRoutes.playlistDetails, extra: args);
                },
              ),
            );
          },
        );
      },
    );
  }
}
