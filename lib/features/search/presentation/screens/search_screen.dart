import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/features/search/presentation/screens/search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  // TODO: Persist recent searches using shared preferences or a local database.
  final List<String> _recentSearches = [];
  final List<String> _popularQueries = [
    'Pasta',
    'Chicken',
    'Kids recipes',
    'On the grill',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSubmitQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _recentSearches.remove(trimmed);
      _recentSearches.insert(0, trimmed);
    });

    context.push(
      AppRoutes.searchResults,
      extra: SearchResultsArgs(query: trimmed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search recipes, cookbooks, chefs',
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _onSubmitQuery,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_recentSearches.isNotEmpty) ...[
              Text('Recent searches', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _recentSearches.map((q) {
                  return ActionChip(
                    label: Text(q),
                    onPressed: () => _onSubmitQuery(q),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
            Text('Popular', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Column(
              children: _popularQueries.map((q) {
                return ListTile(
                  title: Text(q),
                  onTap: () => _onSubmitQuery(q),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
