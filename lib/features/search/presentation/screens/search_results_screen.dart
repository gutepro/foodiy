import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/features/discovery/discovery_feed.dart';
import 'package:foodiy/features/discovery/discovery_feed.dart'
    show PublicCookbookScreen;
import 'package:foodiy/shared/constants/categories.dart';
import 'package:foodiy/shared/widgets/foodiy_app_bar.dart';

class SearchResultsArgs {
  final String query;
  const SearchResultsArgs({required this.query});
}

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key, required this.args});

  final SearchResultsArgs args;

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final _repo = DiscoveryRepository();
  late Future<List<DiscoveryCookbook>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.searchPublicCookbooks(widget.args.query);
  }

  @override
  void didUpdateWidget(covariant SearchResultsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.args.query != widget.args.query) {
      _future = _repo.searchPublicCookbooks(widget.args.query);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: FoodiyAppBar(
        title: const Text('Results'),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: FutureBuilder<List<DiscoveryCookbook>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              final msg = snapshot.error.toString();
              final isIndexError =
                  msg.contains('search-index-missing') ||
                  (msg.contains('failed-precondition') &&
                      msg.contains('index'));
              debugPrint('[SEARCH_RESULTS_ERROR] $msg');
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isIndexError
                            ? 'Search temporarily unavailable. Please try again shortly.'
                            : 'Failed to load results.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _future = _repo.searchPublicCookbooks(
                              widget.args.query,
                            );
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            final cookbooks = snapshot.data ?? const [];
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Results for: ${widget.args.query}',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    title: 'Cookbooks',
                    child: cookbooks.isEmpty
                        ? const Text('No cookbooks found')
                        : Column(
                            children: cookbooks
                                .map(
                                  (p) => Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: p.coverImageUrl.isNotEmpty
                                            ? Image.network(
                                                p.coverImageUrl,
                                                width: 56,
                                                height: 56,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Container(
                                                        width: 56,
                                                        height: 56,
                                                        color: Colors
                                                            .grey
                                                            .shade200,
                                                        alignment:
                                                            Alignment.center,
                                                        child: const Icon(
                                                          Icons.restaurant,
                                                          size: 32,
                                                        ),
                                                      );
                                                    },
                                              )
                                            : Container(
                                                width: 56,
                                                height: 56,
                                                color: Colors.grey.shade200,
                                                alignment: Alignment.center,
                                                child: const Icon(
                                                  Icons.restaurant,
                                                  size: 32,
                                                ),
                                              ),
                                      ),
                                      title: Text(p.title),
                                      subtitle: Text(p.ownerName),
                                      onTap: () {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                PublicCookbookScreen(
                                                  cookbookId: p.id,
                                                  title: p.title,
                                                  ownerId: p.ownerId,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _MockRecipe {
  final String title;
  final String imageUrl;
  final String time;
  const _MockRecipe({
    required this.title,
    required this.imageUrl,
    required this.time,
  });
}

class _MockPlaylist {
  final String title;
  final String imageUrl;
  final String subtitle;
  final String description;
  final String totalTime;

  const _MockPlaylist({
    required this.title,
    required this.imageUrl,
    required this.subtitle,
    required this.description,
    required this.totalTime,
  });
}

class _MockChef {
  final String name;
  const _MockChef(this.name);
}

const _mockRecipes = [
  _MockRecipe(title: 'Pasta Bolognese', imageUrl: '', time: '25 min'),
  _MockRecipe(title: 'Grilled chicken skewers', imageUrl: '', time: '20 min'),
  _MockRecipe(title: 'Shakshuka', imageUrl: '', time: '30 min'),
];

const _mockPlaylists = [
  _MockPlaylist(
    title: 'Weeknight Pasta Hits',
    imageUrl: '',
    subtitle: '5 recipes • 45 min total',
    description: 'Comforting pasta picks for busy nights.',
    totalTime: '45 min',
  ),
  _MockPlaylist(
    title: 'Family BBQ Night',
    imageUrl: '',
    subtitle: '6 recipes • 60 min total',
    description: 'Grill-friendly plates everyone loves.',
    totalTime: '60 min',
  ),
  _MockPlaylist(
    title: 'Quick Lunch Boost',
    imageUrl: '',
    subtitle: '4 recipes • 30 min total',
    description: 'Fast, satisfying midday bites.',
    totalTime: '30 min',
  ),
];

const _mockChefs = [
  _MockChef('Chef Lila'),
  _MockChef('Chef Mateo'),
  _MockChef('Chef Priya'),
  _MockChef('Chef Devon'),
];
