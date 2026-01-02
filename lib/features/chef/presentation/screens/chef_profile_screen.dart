import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:foodiy/features/playlist/domain/public_chef_playlist_models.dart';
import 'package:foodiy/features/playlist/presentation/screens/playlist_details_screen.dart';
import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/features/chef/application/chef_follow_service.dart';

class ChefProfileScreen extends StatelessWidget {
  const ChefProfileScreen({super.key, required this.chefId});

  final String chefId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isSelf = currentUid.isNotEmpty && currentUid == chefId;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chef'),
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.discovery);
            }
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(chefId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(child: Text('Chef not found'));
          }
          final data = snapshot.data!.data() ?? {};
          final name = data['displayName'] as String? ?? 'Chef';
          final photoUrl = (data['chefAvatarUrl'] as String?)?.isNotEmpty == true
              ? data['chefAvatarUrl'] as String
              : (data['photoUrl'] as String? ?? '');
          final bio = (data['chefBio'] as String?)?.trim() ?? '';
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                      backgroundColor: Colors.grey.shade200,
                      child: photoUrl.isEmpty
                          ? Icon(Icons.person, color: Colors.grey.shade500)
                          : null,
                      onBackgroundImageError: (_, __) {},
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (bio.isNotEmpty)
                            Text(
                              bio,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (isSelf)
                      OutlinedButton.icon(
                        onPressed: () {
                          context.push(AppRoutes.editChefProfile, extra: chefId);
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit profile'),
                      )
                    else
                      _FollowButton(
                        chefId: chefId,
                        chefName: name,
                        chefAvatarUrl: photoUrl,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Cookbooks',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _ChefPlaylistsList(
                chefId: chefId,
                chefName: name,
                isSelf: isSelf,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FollowButton extends StatefulWidget {
  const _FollowButton({
    required this.chefId,
    required this.chefName,
    required this.chefAvatarUrl,
  });

  final String chefId;
  final String chefName;
  final String chefAvatarUrl;

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  bool _isFollowing = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUid.isEmpty) return;
    final isFollowing = await ChefFollowService.instance.isFollowing(
      currentUid: currentUid,
      chefId: widget.chefId,
    );
    if (!mounted) return;
    setState(() {
      _isFollowing = isFollowing;
    });
  }

  Future<void> _toggle() async {
    if (_loading) return;
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUid.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in to follow chefs.')),
        );
      }
      return;
    }
    final targetState = !_isFollowing;
    setState(() {
      _loading = true;
      _isFollowing = targetState;
    });
    try {
      final profile = CurrentUserService.instance.currentProfile;
      if (targetState) {
        await ChefFollowService.instance.followChef(
          currentUid: currentUid,
          chefId: widget.chefId,
          chefName: widget.chefName,
          chefAvatarUrl: widget.chefAvatarUrl,
          userName: profile?.displayName ?? profile?.email ?? '',
          userAvatarUrl: profile?.photoUrl ?? '',
        );
      } else {
        await ChefFollowService.instance.unfollowChef(
          currentUid: currentUid,
          chefId: widget.chefId,
        );
      }
    } catch (e) {
      debugPrint('[CHEF_FOLLOW_BUTTON] toggle failed: $e');
      if (mounted) {
        setState(() {
          _isFollowing = !targetState;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update follow: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: _loading ? null : _toggle,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: _loading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              )
            : Text(_isFollowing ? 'Following' : 'Follow'),
      ),
    );
  }
}

class _ChefPlaylistsList extends StatelessWidget {
  const _ChefPlaylistsList({
    required this.chefId,
    required this.chefName,
    required this.isSelf,
  });

  final String chefId;
  final String chefName;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
      future: _fetchCookbooks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Failed to load cookbooks');
        }
        final publicDocs = snapshot.data ?? const [];
        if (publicDocs.isEmpty) {
          return const Text('This chef hasn’t published any cookbooks yet.');
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: publicDocs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = publicDocs[index];
            final data = doc.data();
            final title =
                data['title'] ?? data['name'] ?? 'Untitled cookbook';
            final description = data['description'] ?? '';
            final isPublic = (data['isPublic'] as bool?) ?? true;
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: _CookbookRowCard(
                title: title.toString(),
                description: description.toString(),
                doc: doc,
                chefName: chefName,
                isPublic: isPublic,
              ),
            );
          },
        );
      },
    );
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _fetchCookbooks() async {
    debugPrint('[CHEF_COOKBOOKS_QUERY] chefUid=$chefId START');
    try {
      final q = FirebaseFirestore.instance
          .collection('cookbooks')
          .where('ownerId', isEqualTo: chefId)
          .where('isPublic', isEqualTo: true);

      final snap = await q.limit(50).get();
      final docs = snap.docs;
      final firstIds = docs.take(3).map((d) => d.id).toList();
      debugPrint(
        '[CHEF_COOKBOOKS_QUERY] chefUid=$chefId count=${docs.length} ids=${firstIds.join(',')}',
      );
      if (docs.isNotEmpty) {
        try {
          final orderedSnap = await q
              .orderBy('updatedAt', descending: true)
              .limit(50)
              .get();
          return orderedSnap.docs;
        } on FirebaseException catch (e) {
          debugPrint(
            '[CHEF_COOKBOOKS_QUERY_ERROR] code=${e.code} message=${e.message}',
          );
          return docs;
        }
      }
      return docs;
    } on FirebaseException catch (e) {
      debugPrint(
        '[CHEF_COOKBOOKS_QUERY_ERROR] code=${e.code} message=${e.message}',
      );
      rethrow;
    }
  }
}

class _CookbookRowCard extends StatelessWidget {
  const _CookbookRowCard({
    required this.title,
    required this.description,
    required this.doc,
    required this.chefName,
    required this.isPublic,
  });

  final String title;
  final String description;
  final QueryDocumentSnapshot<Map<String, dynamic>>? doc;
  final String chefName;
  final bool isPublic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = doc?.data() ?? {};
    final imageUrl =
        (data['coverImageUrl'] ?? data['imageUrl'] ?? '') as String? ?? '';
    return InkWell(
      onTap: doc == null
          ? null
          : () async {
              final entriesSnap = await doc!.reference
                  .collection('entries')
                  .get();
              final entries = entriesSnap.docs
                  .map((e) => PublicChefPlaylistEntry.fromJson(e.data()))
                  .toList();
              final imageUrl = entries.isNotEmpty ? entries.first.imageUrl : '';
              final args = PlaylistDetailsArgs(
                title: title,
                imageUrl: imageUrl,
                description: description,
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
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                image: imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl.isEmpty
                  ? const Icon(Icons.menu_book_outlined)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPublic ? 'Public cookbook' : 'Private cookbook',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isPublic
                          ? theme.colorScheme.primary
                          : theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By $chefName',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }
}
