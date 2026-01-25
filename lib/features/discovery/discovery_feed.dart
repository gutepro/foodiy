import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:foodiy/core/widgets/recipe_image.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_details_screen.dart';
import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/shared/constants/categories.dart';
import 'package:foodiy/shared/widgets/foodiy_app_bar.dart';
import 'package:foodiy/l10n/app_localizations.dart';

class DiscoveryRepository {
  DiscoveryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<DiscoveryCookbook>> watchPublicCookbooksByCategory(
    String categoryKey, {
    int limit = 10,
  }) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    debugPrint('[DISCOVER_QUERY] category=$categoryKey uid=$uid START');
    final base = _firestore
        .collection('cookbooks')
        .where('isPublic', isEqualTo: true)
        .where('categories', arrayContains: categoryKey)
        .orderBy('updatedAt', descending: true)
        .limit(limit);

    return base
        .snapshots()
        .map((snapshot) {
          try {
            final cookbooks = snapshot.docs.map(_mapCookbook).toList(growable: false);
            final before = cookbooks.length;
            final after = cookbooks.length;
            final first = cookbooks.isNotEmpty ? cookbooks.first : null;
            debugPrint(
              '[DISCOVER_QUERY] category=$categoryKey uid=$uid SUCCESS count=$after firstId=${first?.id ?? '-'} firstOwner=${first?.ownerId ?? '-'}',
            );
            if (before != after) {
              debugPrint(
                '[DISCOVER_FILTER] category=$categoryKey uid=$uid before=$before after=$after reason=none',
              );
            }
            return cookbooks;
          } catch (e, st) {
            debugPrint('[DISCOVER_QUERY] ERROR category=$categoryKey uid=$uid $e');
            debugPrint('$st');
            rethrow;
          }
        })
        .handleError((e, st) {
          debugPrint('[DISCOVER_STREAM_ERROR] category=$categoryKey error=$e');
          debugPrint('$st');
          return <DiscoveryCookbook>[];
        });
  }

  Future<List<DiscoveryCookbook>> searchPublicCookbooks(String query) async {
    final q = _normalizeForSearch(query);
    if (q.isEmpty) return const [];
    try {
      await _ensureBackfillOnce();
      final col = _firestore.collection('cookbooks');
      if (kDebugMode) {
        debugPrint(
          '[DISCOVER_SEARCH_QUERY] collection=cookbooks where=isPublic==true orderBy=nameLower startAt=$q endAt=${q}~ limit=20',
        );
        debugPrint(
          '[DISCOVER_SEARCH_RANGE] start="$q" (${q.codeUnits}) end="${q + '\uf8ff'}" (${(q + '\uf8ff').codeUnits})',
        );
      }
      final snap = await col
          .where('isPublic', isEqualTo: true)
          .orderBy('nameLower')
          .startAt([q])
          .endAt(['$q\uf8ff'])
          .limit(20)
          .get();
      final cookbooks = snap.docs.map(_mapCookbook).toList(growable: false);
      if (kDebugMode) {
        final preview = cookbooks
            .take(3)
            .map((c) => '${c.title} (${c.coverImageUrl})')
            .join(' | ');
        debugPrint(
          '[DISCOVER_SEARCH] query="$q" results=${cookbooks.length} first=${preview.isEmpty ? 'none' : preview}',
        );
      }
      return cookbooks;
    } on FirebaseException catch (e, st) {
      debugPrint('[DISCOVER_SEARCH_ERROR] $e');
      debugPrint('$st');
      rethrow;
    }
  }

  String _normalizeForSearch(String input) =>
      input.trim().toLowerCase().replaceAll(RegExp(r'\\s+'), ' ');

  /// Debug-only helper to backfill missing/empty nameLower values.
  bool _backfillScheduled = false;
  Future<void> _ensureBackfillOnce() async {
    if (!kDebugMode) return;
    if (_backfillScheduled) return;
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('cookbooks_nameLower_backfilled') ?? false;
    if (done) {
      _backfillScheduled = true;
      return;
    }
    _backfillScheduled = true;
    await backfillNameLowerIfMissing();
    await prefs.setBool('cookbooks_nameLower_backfilled', true);
  }

  Future<void> backfillNameLowerIfMissing() async {
    if (!kDebugMode) return;
    try {
      final snap = await _firestore.collection('cookbooks').get();
      var updated = 0;
      for (final doc in snap.docs) {
        final data = doc.data();
        final name = (data['title'] ?? data['name'] ?? '').toString();
        final currentLower = (data['nameLower'] ?? '').toString();
        final normalized = _normalizeForSearch(name);
        if (normalized.isNotEmpty && normalized != currentLower) {
          await doc.reference.set({
            'nameLower': normalized,
          }, SetOptions(merge: true));
          updated++;
        }
      }
      debugPrint(
        '[DISCOVER_BACKFILL] nameLower updated for $updated cookbooks',
      );
    } catch (e, st) {
      debugPrint('[DISCOVER_BACKFILL_ERROR] $e');
      debugPrint('$st');
    }
  }

  Future<List<DiscoveryCategoryRow>> loadCategoryRows() async {
    final rows = <DiscoveryCategoryRow>[];
    for (final category in kRecipeCategoryOptions) {
      final result = await _loadPublicCookbooksForCategory(category.key);
      rows.add(
        DiscoveryCategoryRow(
          category: category.key,
          cookbooks: result.cookbooks,
          debugCookbookIds: result.cookbookIds,
          debugQueryError: result.error,
          debugUsedFallback: result.usedFallback,
        ),
      );
    }

    if (kDebugMode) {
      debugPrint(
        'DiscoveryRepository: built ${rows.length} category rows '
        '(publicCookbooksByCategory)',
      );
    }
    return rows;
  }

  DiscoveryCookbook _mapCookbook(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final categories = _asStringList(
      data['categories'] ?? data['category'],
    ).map(categoryKeyFromInput).toList();
    final viewsValue = data['viewsCount'] ?? data['views'];
    final cover = (data['coverImageUrl'] ?? data['cover_image_url'] ?? '').toString();
    final image = (data['imageUrl'] ?? data['image_url'] ?? '').toString();
    final chosen = cover.isNotEmpty ? cover : (image.isNotEmpty ? image : '');
    return DiscoveryCookbook(
      id: doc.id,
      ownerId: (data['ownerId'] ?? '').toString(),
      title: (data['title'] ?? data['name'] ?? '').toString(),
      categories: categories,
      imageUrl: image,
      coverImageUrl: chosen,
      ownerName: (data['ownerName'] ?? data['chefName'] ?? '').toString(),
      views: _toInt(viewsValue),
    );
  }

  List<String> _asStringList(dynamic raw) {
    if (raw is Iterable) {
      return raw
          .map((e) => (e as String?)?.trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (raw is String) return [raw];
    return const [];
  }

  Future<_PublicCookbooksQueryResult> _loadPublicCookbooksForCategory(
    String categoryKey,
  ) async {
    try {
      final base = _firestore
          .collection('cookbooks')
          .where('isPublic', isEqualTo: true)
          .where('categories', arrayContains: categoryKey);

      try {
        final ordered = await base
            .orderBy('updatedAt', descending: true)
            .limit(10)
            .get();
        if (kDebugMode) {
          debugPrint(
            '[DISCOVER] cookbooks category=$categoryKey count=${ordered.size} (ordered updatedAt)',
          );
        }
        final docs = ordered.docs;
        return _PublicCookbooksQueryResult(
          cookbooks: docs.map(_mapCookbook).toList(growable: false),
          cookbookIds: docs.map((d) => d.id).take(5).toList(growable: false),
          usedFallback: false,
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            '[DISCOVER] cookbooks category=$categoryKey orderBy(updatedAt) failed: $e',
          );
        }
        // Try fallback ordering by createdAt.
        try {
          final created = await base
              .orderBy('createdAt', descending: true)
              .limit(10)
              .get();
          if (kDebugMode) {
            debugPrint(
              '[DISCOVER] cookbooks category=$categoryKey count=${created.size} (ordered createdAt)',
            );
          }
          final docs = created.docs;
          return _PublicCookbooksQueryResult(
            cookbooks: docs.map(_mapCookbook).toList(growable: false),
            cookbookIds: docs.map((d) => d.id).take(5).toList(growable: false),
            usedFallback: true,
            error: e.toString(),
          );
        } catch (e2) {
          if (kDebugMode) {
            debugPrint(
              '[DISCOVER] cookbooks category=$categoryKey orderBy(createdAt) failed: $e2',
            );
          }
        }

        // Final fallback: no order.
        final snap = await base.limit(10).get();
        if (kDebugMode) {
          debugPrint(
            '[DISCOVER] cookbooks category=$categoryKey count=${snap.size} (fallback no order)',
          );
        }
        final docs = snap.docs;
        final cookbooks = docs.map(_mapCookbook).toList(growable: false);
        cookbooks.sort((a, b) => b.views.compareTo(a.views));
        return _PublicCookbooksQueryResult(
          cookbooks: cookbooks,
          cookbookIds: docs.map((d) => d.id).take(5).toList(growable: false),
          usedFallback: true,
          error: e.toString(),
        );
      }
    } catch (e, s) {
      debugPrint(
        '[DISCOVER_QUERY_ERROR] cookbooks by category=$categoryKey: $e',
      );
      debugPrint('$s');
      debugPrint(
        'DISCOVER auth uid: ${FirebaseAuth.instance.currentUser?.uid}',
      );
      return _PublicCookbooksQueryResult(
        cookbooks: const [],
        cookbookIds: const [],
        usedFallback: false,
        error: e.toString(),
      );
    }
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}

class DiscoveryRecipePreview {
  DiscoveryRecipePreview({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.categories,
    required this.stepsCount,
    this.createdAt,
    this.views = 0,
  });

  final String id;
  final String title;
  final String imageUrl;
  final List<String> categories;
  final int stepsCount;
  final DateTime? createdAt;
  final int views;
}

class DiscoveryCookbook {
  const DiscoveryCookbook({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.categories,
    required this.imageUrl,
    required this.coverImageUrl,
    required this.ownerName,
    this.views = 0,
  });

  final String id;
  final String ownerId;
  final String title;
  final List<String> categories;
  final String imageUrl;
  final String coverImageUrl;
  final String ownerName;
  final int views;
}

class DiscoveryCategoryRow {
  const DiscoveryCategoryRow({
    required this.category,
    required this.cookbooks,
    this.debugCookbookIds = const [],
    this.debugQueryError,
    this.debugUsedFallback = false,
  });

  final String category;
  final List<DiscoveryCookbook> cookbooks;
  final List<String> debugCookbookIds;
  final String? debugQueryError;
  final bool debugUsedFallback;
}

class DiscoveryFeed extends StatefulWidget {
  const DiscoveryFeed({super.key, this.repository});

  final DiscoveryRepository? repository;

  @override
  State<DiscoveryFeed> createState() => _DiscoveryFeedState();
}

class _DiscoveryFeedState extends State<DiscoveryFeed> {
  late Future<List<DiscoveryCategoryRow>> _future;

  DiscoveryRepository get _repo => widget.repository ?? DiscoveryRepository();

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DiscoveryCategoryRow>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('DISCOVER ERROR: ${snapshot.error}');
          debugPrint('${snapshot.stackTrace}');
          debugPrint(
            'DISCOVER auth uid: ${FirebaseAuth.instance.currentUser?.uid}',
          );
        }
        final showDebugHeader = kDebugMode;
        final categories = kRecipeCategoryOptions;
        final rows = snapshot.data ?? const <DiscoveryCategoryRow>[];
        final rowsByKey = <String, DiscoveryCategoryRow>{
          for (final row in rows) row.category: row,
        };

        final categoriesCount = categories.length;
        final builtSectionsCount = categoriesCount;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;

        return RefreshIndicator(
          onRefresh: () async {
            setState(() => _future = _load());
            await _future;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (kDebugMode)
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'DISCOVERY FEED START',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              if (kDebugMode)
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
              if (showDebugHeader)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _DiscoverDebugHeader(
                      categoriesCount: categoriesCount,
                      builtSectionsCount: builtSectionsCount,
                      isLoading: isLoading,
                      hasError: hasError,
                      firstCategories: categories
                          .take(3)
                          .map((c) => c.key)
                          .toList(),
                      queryCountsByCategoryKey: {
                        for (final category in categories.take(3))
                          category.key:
                              rowsByKey[category.key]?.cookbooks.length ?? 0,
                      },
                      firstIdsByCategoryKey: {
                        for (final category in categories.take(3))
                          category.key:
                              rowsByKey[category.key]?.debugCookbookIds ??
                              const [],
                      },
                      queryErrorsByCategoryKey: {
                        for (final category in categories.take(3))
                          category.key:
                              rowsByKey[category.key]?.debugQueryError,
                      },
                      queryFallbackByCategoryKey: {
                        for (final category in categories.take(3))
                          category.key:
                              rowsByKey[category.key]?.debugUsedFallback ??
                              false,
                      },
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(child: _FeaturedCookbooksSection()),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final category = categories[index];
                  final row = rowsByKey[category.key];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _CategoryCarouselRow(
                          row: DiscoveryCategoryRow(
                            category: category.key,
                            cookbooks: row?.cookbooks ?? const [],
                            debugCookbookIds: row?.debugCookbookIds ?? const [],
                            debugQueryError: row?.debugQueryError,
                            debugUsedFallback: row?.debugUsedFallback ?? false,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                }, childCount: builtSectionsCount),
              ),
              if (kDebugMode)
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'DISCOVERY FEED END',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          ),
        );
      },
    );
  }

  Future<List<DiscoveryCategoryRow>> _load() async {
    try {
      return await _repo.loadCategoryRows();
    } catch (e, s) {
      debugPrint('DISCOVER ERROR: $e');
      debugPrint('$s');
      debugPrint(
        'DISCOVER auth uid: ${FirebaseAuth.instance.currentUser?.uid}',
      );
      return const [];
    }
  }
}

class _FeaturedCookbooksSection extends StatelessWidget {
  const _FeaturedCookbooksSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = FirebaseFirestore.instance
        .collection('cookbooks')
        .where('isPublic', isEqualTo: true)
        .orderBy('viewsCount', descending: true)
        .limit(10);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          debugPrint('DISCOVER ERROR: ${snapshot.error}');
          debugPrintStack(stackTrace: StackTrace.current);
          debugPrint(
            'DISCOVER auth uid: ${FirebaseAuth.instance.currentUser?.uid}',
          );
          return _EmptyState(message: l10n.discoverNoCookbooks);
        }
        final docs = snapshot.data?.docs ?? const [];
        if (docs.isEmpty) {
          return _EmptyState(message: l10n.discoverNoCookbooks);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.discoverFeaturedCookbooks,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  final cookbook = DiscoveryCookbook(
                    id: docs[index].id,
                    ownerId: (data['ownerId'] ?? '').toString(),
                    title: (data['title'] ?? data['name'] ?? '').toString(),
                    categories: const [],
                    imageUrl: (data['imageUrl'] ?? data['coverImageUrl'] ?? '')
                        .toString(),
                    coverImageUrl:
                        (data['coverImageUrl'] ?? data['imageUrl'] ?? '')
                            .toString(),
                    ownerName: (data['chefName'] ?? data['ownerName'] ?? '')
                        .toString(),
                    views: _safeInt(data['viewsCount'] ?? data['views']),
                  );
                  return _CookbookCard(
                    cookbook: cookbook,
                    category: l10n.discoverFeaturedCookbooks,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryCarouselRow extends StatelessWidget {
  const _CategoryCarouselRow({required this.row});

  final DiscoveryCategoryRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final title = kCategoryTitleByKey[row.category] ?? row.category;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (kDebugMode)
          Text(
            'SECTION: ${row.category} count=${row.cookbooks.length}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.deepPurple,
              fontWeight: FontWeight.w700,
            ),
          ),
        if (kDebugMode) const SizedBox(height: 6),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        if (row.cookbooks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.discoverNoCookbooks,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
          )
        else
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: row.cookbooks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final cookbook = row.cookbooks[index];
                return _CookbookCard(
                  cookbook: cookbook,
                  category: row.category,
                );
              },
            ),
          ),
      ],
    );
  }
}

class _DiscoverDebugHeader extends StatelessWidget {
  const _DiscoverDebugHeader({
    required this.categoriesCount,
    required this.builtSectionsCount,
    required this.isLoading,
    required this.hasError,
    required this.firstCategories,
    required this.queryCountsByCategoryKey,
    required this.firstIdsByCategoryKey,
    required this.queryErrorsByCategoryKey,
    required this.queryFallbackByCategoryKey,
  });

  final int categoriesCount;
  final int builtSectionsCount;
  final bool isLoading;
  final bool hasError;
  final List<String> firstCategories;
  final Map<String, int> queryCountsByCategoryKey;
  final Map<String, List<String>> firstIdsByCategoryKey;
  final Map<String, String?> queryErrorsByCategoryKey;
  final Map<String, bool> queryFallbackByCategoryKey;

  @override
  Widget build(BuildContext context) {
    final projectId = FirebaseFirestore.instance.app.options.projectId;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodySmall!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Discover debug'),
              Text('projectId: $projectId'),
              Text(
                'categoriesCount: $categoriesCount  builtSectionsCount: $builtSectionsCount',
              ),
              Text('loading: $isLoading  error: $hasError'),
              const SizedBox(height: 8),
              for (final key in firstCategories)
                Text(
                  'categoryKey: $key  cookbooks: ${queryCountsByCategoryKey[key] ?? 0}  ids: ${(firstIdsByCategoryKey[key] ?? const []).take(3).join(', ')}${queryFallbackByCategoryKey[key] == true ? ' (fallback)' : ''}${(queryErrorsByCategoryKey[key] ?? '').isNotEmpty ? ' err=${queryErrorsByCategoryKey[key]}' : ''}',
                ),
              const SizedBox(height: 12),
              const _CookbookDocDebugLoader(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CookbookDocDebugLoader extends StatefulWidget {
  const _CookbookDocDebugLoader();

  @override
  State<_CookbookDocDebugLoader> createState() =>
      _CookbookDocDebugLoaderState();
}

class _CookbookDocDebugLoaderState extends State<_CookbookDocDebugLoader> {
  final _controller = TextEditingController();
  bool _loading = false;
  String _output = 'Paste a cookbookId to inspect /cookbooks/{id}.';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final cookbookId = _controller.text.trim();
    if (cookbookId.isEmpty) return;
    setState(() {
      _loading = true;
      _output = 'Loading...';
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('cookbooks')
          .doc(cookbookId)
          .get();
      if (!doc.exists) {
        debugPrint('[DISCOVER_COOKBOOK_DEBUG] id=$cookbookId exists=false');
        setState(() {
          _output = 'exists=false';
          _loading = false;
        });
        return;
      }
      final data = doc.data() ?? const <String, dynamic>{};
      final title = data['title'] ?? data['name'];
      final coverImageUrl = data['coverImageUrl'] ?? data['imageUrl'];
      final isPublic = data['isPublic'];
      final categories = data['categories'];
      final viewsCount = data['viewsCount'];
      debugPrint(
        '[DISCOVER_COOKBOOK_DEBUG] id=$cookbookId exists=true '
        'title=$title(${title.runtimeType}) '
        'coverImageUrl=$coverImageUrl(${coverImageUrl.runtimeType}) '
        'isPublic=$isPublic(${isPublic.runtimeType}) '
        'categories=$categories(${categories.runtimeType}) '
        'viewsCount=$viewsCount(${viewsCount.runtimeType})',
      );
      setState(() {
        _output =
            'exists=true\n'
            'title=$title (${title.runtimeType})\n'
            'coverImageUrl=$coverImageUrl (${coverImageUrl.runtimeType})\n'
            'isPublic=$isPublic (${isPublic.runtimeType})\n'
            'categories=$categories (${categories.runtimeType})\n'
            'viewsCount=$viewsCount (${viewsCount.runtimeType})';
        _loading = false;
      });
    } catch (e) {
      debugPrint('[DISCOVER_COOKBOOK_DEBUG] id=$cookbookId error=$e');
      setState(() {
        _output = 'error=$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Debug cookbookId (paste)',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _loading ? null : _load,
              child: Text(_loading ? 'Loading' : 'Load'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(_output),
      ],
    );
  }
}

class _PublicCookbooksQueryResult {
  const _PublicCookbooksQueryResult({
    required this.cookbooks,
    required this.cookbookIds,
    required this.usedFallback,
    this.error,
  });

  final List<DiscoveryCookbook> cookbooks;
  final List<String> cookbookIds;
  final bool usedFallback;
  final String? error;
}

class _CookbookCard extends StatelessWidget {
  const _CookbookCard({required this.cookbook, required this.category});

  final DiscoveryCookbook cookbook;
  final String category;
  static bool _loggedAndroid = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final width = min(MediaQuery.sizeOf(context).width * 0.55, 170.0);
    final chosenImage =
        cookbook.coverImageUrl.isNotEmpty ? cookbook.coverImageUrl : cookbook.imageUrl;
    if (kDebugMode && !_loggedAndroid && defaultTargetPlatform == TargetPlatform.android) {
      debugPrint(
        '[ANDROID_IMG_DEBUG] id=${cookbook.id} url=$chosenImage cover=${cookbook.coverImageUrl} image=${cookbook.imageUrl}',
      );
      _loggedAndroid = true;
    }
    return SizedBox(
      width: width,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _open(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  if (chosenImage.isNotEmpty)
                    Image.network(
                      chosenImage,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) {
                        debugPrint('[ANDROID_IMG_ERROR] id=${cookbook.id} url=$chosenImage err=$error');
                        return Container(
                          height: 130,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Icon(Icons.menu_book, size: 32, color: Colors.grey),
                        );
                      },
                    )
                  else
                    Container(
                      height: 130,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(Icons.menu_book, size: 32, color: Colors.grey),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cookbook.title.isNotEmpty
                          ? cookbook.title
                          : l10n.cookbooksUntitled,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.chefByLine(
                        cookbook.ownerName.isNotEmpty
                            ? cookbook.ownerName
                            : l10n.homeChefPlaceholder,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    debugPrint(
      '[COOKBOOK_DETAIL] open public cookbook id=${cookbook.id} title=${cookbook.title} categories=${cookbook.categories}',
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PublicCookbookScreen(
          cookbookId: cookbook.id,
          title: cookbook.title,
          ownerId: cookbook.ownerId,
        ),
      ),
    );
  }
}

class PublicCookbookScreen extends StatelessWidget {
  const PublicCookbookScreen({
    super.key,
    required this.cookbookId,
    required this.title,
    required this.ownerId,
  });

  final String cookbookId;
  final String title;
  final String ownerId;

  Future<List<RecipeDetailsArgs>> _loadRecipesByIds(
    AppLocalizations l10n,
    List<String> ids,
  ) async {
    if (ids.isEmpty) return const [];

    const chunkSize = 10;
    final firestore = FirebaseFirestore.instance;
    final byId = <String, RecipeDetailsArgs>{};

    for (var i = 0; i < ids.length; i += chunkSize) {
      final chunk = ids.sublist(
        i,
        i + chunkSize > ids.length ? ids.length : i + chunkSize,
      );
      final snap = await firestore
          .collection('recipes')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        final data = doc.data();
        final steps = (data['steps'] as List<dynamic>?) ?? const [];
        byId[doc.id] = RecipeDetailsArgs(
          id: doc.id,
          title: (data['title'] ?? '').toString(),
          imageUrl: (data['coverImageUrl'] ?? data['imageUrl'] ?? '')
              .toString(),
          time: l10n.profileStepsCount(steps.length),
          difficulty: '-',
          originalLanguageCode:
              (data['originalLanguageCode'] as String?) ?? 'en',
          ingredients: const [],
          steps: const [],
        );
      }
    }

    // Preserve entry ordering and filter out missing docs.
    final ordered = ids.where(byId.containsKey).map((id) => byId[id]!).toList();
    debugPrint(
      '[DISCOVER_COOKBOOK_DETAILS] fetchedRecipes=${ordered.length}',
    );
    return ordered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewerUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final viewerIsOwner = viewerUid.isNotEmpty && viewerUid == ownerId;

    debugPrint('[DISCOVER_COOKBOOK_DETAILS] open cookbookId=$cookbookId');

    final cookbookStream = FirebaseFirestore.instance
        .collection('cookbooks')
        .doc(cookbookId)
        .snapshots();

    return Scaffold(
      appBar: FoodiyAppBar(
        title: Text(title.isNotEmpty ? title : l10n.cookbooksUntitled),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: cookbookStream,
        builder: (context, cookbookSnapshot) {
          if (cookbookSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cookbookSnapshot.hasError) {
            return Center(child: Text(l10n.discoverCookbookLoadFailed));
          }
          final data = cookbookSnapshot.data?.data();
          if (data == null) {
            return Center(child: Text(l10n.discoverCookbookNotFound));
          }
          final recipeIds = (data['recipeIds'] as List<dynamic>? ?? const [])
              .whereType<String>()
              .where((id) => id.isNotEmpty)
              .toList(growable: false);
          final updatedAt = data['updatedAt'];
          debugPrint(
            '[DISCOVER_COOKBOOK_DETAILS] snapshot recipeIdsCount=${recipeIds.length} updatedAt=$updatedAt',
          );
          if (recipeIds.isEmpty) {
            return Center(
              child: Text(l10n.discoverCookbookNoRecipes),
            );
          }
          return FutureBuilder<List<RecipeDetailsArgs>>(
            future: _loadRecipesByIds(l10n, recipeIds),
            builder: (context, recipesSnapshot) {
              if (recipesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (recipesSnapshot.hasError) {
                return Center(child: Text(l10n.discoverRecipesLoadFailed));
              }
              final recipes = recipesSnapshot.data ?? const [];
              if (recipes.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.discoverCookbookNoRecipesAvailable),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: recipes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: RecipeImage(
                        imageUrl: recipe.imageUrl,
                        height: 56,
                        width: 56,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        recipe.title.isNotEmpty
                            ? recipe.title
                            : l10n.untitledRecipe,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(recipe.time),
                      onTap: () {
                        context.push(AppRoutes.recipeDetails, extra: recipe);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          message,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
        ),
      ),
    );
  }
}

int _safeInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
