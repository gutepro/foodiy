import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import 'package:foodiy/features/playlist/application/personal_playlist_service.dart';
import 'package:foodiy/features/playlist/application/personal_playlist_share_helper.dart';
import 'package:foodiy/features/playlist/domain/personal_playlist_models.dart';
import 'package:foodiy/features/playlist/presentation/screens/personal_playlist_details_screen.dart';
import 'package:foodiy/router/app_routes.dart';

class MyPlaylistsScreen extends StatefulWidget {
  const MyPlaylistsScreen({super.key});

  @override
  State<MyPlaylistsScreen> createState() => _MyPlaylistsScreenState();
}

class _MyPlaylistsScreenState extends State<MyPlaylistsScreen> {
  final _service = PersonalPlaylistService.instance;
  final _picker = ImagePicker();
  final _random = Random();
  final List<String> _placeholderImages = const [
    'https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    final playlists = _service.getCurrentUserPlaylists();

    return Scaffold(
      appBar: AppBar(title: const Text('My cookbooks')),
      body: playlists.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.menu_book, size: 64),
                    SizedBox(height: 12),
                    Text('You do not have any cookbooks yet'),
                    SizedBox(height: 4),
                    Text('Create your first personal cookbook'),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: playlists.length,
                      itemBuilder: (context, index) {
                        final pl = playlists[index];
                        final title = (pl.name).trim().isNotEmpty
                            ? pl.name
                            : 'Untitled playlist';
                        final entries = _service.getEntries(pl.id);
                        final isPublic = pl.isPublic;
                        final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
                        final isFavorite = pl.ownerId == currentUid &&
                            pl.name.toLowerCase() == 'favorite recipes';
                        final cardColor =
                            isFavorite ? null : (isPublic ? Colors.green.shade50 : Colors.white);
                        final borderColor = isFavorite
                            ? Colors.transparent
                            : (isPublic ? Colors.green.shade300 : Colors.grey.shade300);
                        final statusChip = Chip(
                          avatar: Icon(
                            isPublic ? Icons.public : Icons.lock,
                            size: 16,
                            color: isPublic ? Colors.green.shade800 : Colors.grey.shade700,
                          ),
                          label: Text(isPublic ? 'Public' : 'Private'),
                          backgroundColor:
                              isPublic ? Colors.green.shade100 : Colors.grey.shade200,
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                          visualDensity: VisualDensity.compact,
                        );
                        return Card(
                          color: cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: borderColor),
                          ),
                          child: Container(
                            decoration: isFavorite
                                ? BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.purple.shade100,
                                        Colors.blue.shade100,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  )
                                : null,
                            child: ListTile(
                              leading: isFavorite
                                  ? Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: Colors.pink.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.favorite,
                                        color: Colors.pink,
                                        size: 28,
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: pl.imageUrl.isNotEmpty
                                          ? Image.network(
                                              pl.imageUrl,
                                              width: 56,
                                              height: 56,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stack) {
                                                return Container(
                                                  width: 56,
                                                  height: 56,
                                                  color: Colors.grey.shade200,
                                                  alignment: Alignment.center,
                                                  child: const Icon(Icons.menu_book),
                                                );
                                              },
                                            )
                                          : Container(
                                              width: 56,
                                              height: 56,
                                              color: Colors.grey.shade200,
                                              alignment: Alignment.center,
                                              child: const Icon(Icons.menu_book),
                                            ),
                                    ),
                              title: Text(title),
                              subtitle: Text(
                                pl.isChefPlaylist
                                    ? '${entries.length} recipes • Chef cookbook'
                                    : '${entries.length} recipes',
                              ),
                              trailing: isFavorite
                                  ? null
                                  : Wrap(
                                      spacing: 8,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        statusChip,
                                        PopupMenuButton<_PlaylistAction>(
                                          onSelected: (action) {
                                            switch (action) {
                                              case _PlaylistAction.rename:
                                                _onRenamePlaylist(pl);
                                                break;
                                              case _PlaylistAction.delete:
                                                _onDeletePlaylist(pl);
                                                break;
                                              case _PlaylistAction.share:
                                                _onSharePlaylist(pl);
                                                break;
                                            }
                                          },
                                          itemBuilder: (context) {
                                            final items =
                                                <PopupMenuEntry<_PlaylistAction>>[];
                                            items.add(
                                              const PopupMenuItem(
                                                value: _PlaylistAction.rename,
                                                child: Text('Rename'),
                                              ),
                                            );
                                            items.add(
                                              const PopupMenuItem(
                                                value: _PlaylistAction.share,
                                                child: Text('Share'),
                                              ),
                                            );
                                            items.add(
                                              const PopupMenuItem(
                                                value: _PlaylistAction.delete,
                                                child: Text('Delete'),
                                              ),
                                            );
                                            return items;
                                          },
                                        ),
                                      ],
                                    ),
                              onTap: () async {
                                final exists =
                                    _service.playlists.any((p) => p.id == pl.id);
                                if (!exists) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('This cookbook no longer exists'),
                                    ),
                                  );
                                  setState(() {});
                                  return;
                                }
                                await context.push(
                                  AppRoutes.myPlaylistsDetails,
                                  extra: PersonalPlaylistDetailsArgs(
                                    playlistId: pl.id,
                                  ),
                                );
                                setState(() {});
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreatePlaylistPressed,
        child: const Icon(Icons.add),
        heroTag: 'playlists-fab',
      ),
    );
  }

  Future<void> _onCreatePlaylistPressed() async {
    final nameController = TextEditingController();
    bool isPublic = true;
    String? pickedImage;

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickImage() async {
              final picked =
                  await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
              if (picked != null) {
                setSheetState(() {
                  pickedImage = picked.path;
                });
              }
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Create cookbook',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Cookbook name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: pickedImage != null
                              ? Image.file(
                                  File(pickedImage!),
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 72,
                                  height: 72,
                                  color: Colors.grey.shade200,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.image_outlined),
                                ),
                        ),
                        const SizedBox(width: 12),
                        TextButton.icon(
                          onPressed: pickImage,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Choose image'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Public'),
                      subtitle: const Text('Public cookbooks are visible to others'),
                      value: isPublic,
                      onChanged: (value) {
                        setSheetState(() {
                          isPublic = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a name')),
                            );
                            return;
                          }
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Create'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (created != true) return;

    final name = nameController.text.trim();
    final fallbackImage = _placeholderImages[_random.nextInt(_placeholderImages.length)];
    final imageUrl =
        (pickedImage ?? '').isNotEmpty ? pickedImage! : fallbackImage;

    _service.createPlaylist(
      name,
      isPublic: isPublic,
      imageUrl: imageUrl,
    );
    setState(() {});
  }

  Future<void> _onRenamePlaylist(PersonalPlaylist playlist) async {
    final controller = TextEditingController(text: playlist.name);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename cookbook'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'New name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a name')),
                  );
                  return;
                }
                Navigator.of(context).pop(true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _service.renamePlaylist(playlist.id, controller.text.trim());
      setState(() {});
    }
  }

  Future<void> _onDeletePlaylist(PersonalPlaylist playlist) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete cookbook'),
          content: Text('Delete "${playlist.name}"?'),
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

    if (confirm == true) {
      _service.removePlaylist(playlist.id);
      setState(() {});
    }
  }

  void _onSharePlaylist(PersonalPlaylist playlist) {
    final text = PersonalPlaylistShareHelper.formatPlaylist(playlist, _service);
    Share.share(text, subject: 'Cookbook: ${playlist.name}');
  }
}

enum _PlaylistAction { rename, delete, share }
