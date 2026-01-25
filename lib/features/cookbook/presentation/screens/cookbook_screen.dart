// TODO: Legacy cookbook UI, currently unused. Consider deleting this once playlists feature is stable.
import 'package:flutter/material.dart';

import 'package:foodiy/features/cookbook/application/cookbook_service.dart';
import 'package:foodiy/features/cookbook/application/cookbook_share_helper.dart';
import 'package:foodiy/features/cookbook/domain/cookbook_models.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:foodiy/shared/widgets/foodiy_app_bar.dart';

class CookbookScreen extends StatefulWidget {
  const CookbookScreen({super.key});

  @override
  State<CookbookScreen> createState() => _CookbookScreenState();
}

class _CookbookScreenState extends State<CookbookScreen> {
  @override
  Widget build(BuildContext context) {
    final service = CookbookService.instance;
    final cookbooks = service.cookbooks;
    debugPrint(
      'CookbookScreen: building, cookbooks: ${cookbooks.length}, first recipes: ${cookbooks.isNotEmpty ? service.getRecipeCountForCookbook(cookbooks.first.id) : 0}',
    );

    return Scaffold(
      appBar: FoodiyAppBar(
        title: Text('Cookbooks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add test recipe',
            onPressed: _onAddTestRecipeToFirstCookbook,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreateCookbookPressed,
        child: const Icon(Icons.add),
        tooltip: 'Create cookbook',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: cookbooks.isEmpty
            ? const _EmptyCookbooks()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Create cookbook'),
                    onPressed: _onCreateCookbookPressed,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cookbooks.length,
                      itemBuilder: (context, index) {
                        final book = cookbooks[index];
                        final count = book.recipes.length;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.favorite),
                            title: Text(book.name),
                            subtitle: Text('$count recipes'),
                            trailing: PopupMenuButton<_CookbookAction>(
                              onSelected: (action) {
                                switch (action) {
                                  case _CookbookAction.rename:
                                    _onRenameCookbook(book);
                                    break;
                                  case _CookbookAction.share:
                                    _onShareCookbook(book);
                                    break;
                                  case _CookbookAction.delete:
                                    _onDeleteCookbook(book);
                                    break;
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: _CookbookAction.rename,
                                  child: Text('Rename'),
                                ),
                                PopupMenuItem(
                                  value: _CookbookAction.share,
                                  child: Text('Share'),
                                ),
                                PopupMenuItem(
                                  value: _CookbookAction.delete,
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                            onTap: () {
                              // TODO: Open cookbook details with recipe list.
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _onCreateCookbookPressed() async {
    final nameController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create cookbook'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Cookbook name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
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
          ],
        );
      },
    );

    if (result != true) return;

    final name = nameController.text.trim();
    CookbookService.instance.createCookbook(name);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cookbook "$name" created')),
    );
  }

  Future<void> _onDeleteCookbook(Cookbook book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete cookbook'),
          content: Text('Delete "${book.name}"?'),
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

    if (confirmed == true) {
      CookbookService.instance.removeCookbook(book.id);
      setState(() {});
    }
  }

  Future<void> _onRenameCookbook(Cookbook book) async {
    final controller = TextEditingController(text: book.name);
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
      final newName = controller.text.trim();
      CookbookService.instance.renameCookbook(book.id, newName);
      setState(() {});
    }
  }

  void _onShareCookbook(Cookbook book) {
    final service = CookbookService.instance;
    final text = CookbookShareHelper.formatCookbook(book, service);
    Share.share(
      text,
      subject: 'Cookbook: ${book.name}',
    );
  }

  void _onAddTestRecipeToFirstCookbook() {
    final service = CookbookService.instance;
    if (service.cookbooks.isEmpty) return;
    final first = service.cookbooks.first;

    final entry = CookbookRecipeEntry(
      recipeId: 'test-id',
      title: 'Test recipe',
      imageUrl: '',
      time: '10 min',
      difficulty: 'Easy',
    );

    service.addRecipeToCookbook(first.id, entry);
    setState(() {});
  }
}

enum _CookbookAction { rename, share, delete }

class _EmptyCookbooks extends StatelessWidget {
  const _EmptyCookbooks();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border, size: 72, color: color),
          const SizedBox(height: 12),
          const Text('You do not have any cookbooks yet'),
          const SizedBox(height: 8),
          const Text('Create your first personal recipe book'),
        ],
      ),
    );
  }
}
