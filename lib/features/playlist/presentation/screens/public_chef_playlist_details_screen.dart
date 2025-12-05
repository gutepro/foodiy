import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodiy/features/playlist/application/public_chef_playlist_service.dart';
import 'package:foodiy/features/playlist/domain/public_chef_playlist_models.dart';

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
    final playlist = service.playlists.firstWhere(
      (p) => p.id == args.playlistId,
    );

    final theme = Theme.of(context);
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = currentUid != null && playlist.chefId == currentUid;

    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.title),
        leading: const BackButton(),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Delete playlist?'),
                      content: const Text(
                          'Delete this cookbook? This cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );
                if (confirmed != true) return;
                await service.deletePlaylist(playlist.id);
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
                  Text(
                    playlist.title,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By ${playlist.chefName}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    playlist.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement "Play all" (public playlist player).
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Play all is not implemented yet'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play all'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${playlist.entries.length} recipes',
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: playlist.entries.length,
              itemBuilder: (context, index) {
                final entry = playlist.entries[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: SizedBox(
                      width: 56,
                      height: 56,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          entry.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              alignment: Alignment.center,
                              child: const Icon(Icons.restaurant, size: 32),
                            );
                          },
                        ),
                      ),
                    ),
                    title: Text(entry.title),
                    subtitle: Text('${entry.time} • ${entry.difficulty}'),
                    onTap: () {
                      // TODO: Wire to real RecipeDetailsScreen route.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Open recipe \"${entry.title}\" is not wired yet',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
