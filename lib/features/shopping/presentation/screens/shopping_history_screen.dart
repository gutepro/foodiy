import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/features/shopping/application/shopping_list_service.dart';
import 'package:foodiy/features/shopping/presentation/screens/shopping_history_details_screen.dart';
import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/shared/widgets/foodiy_app_bar.dart';

class ShoppingHistoryScreen extends StatelessWidget {
  const ShoppingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = ShoppingListService.instance.history;

    return Scaffold(
      appBar: const FoodiyAppBar(title: Text('Shopping history')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: history.isEmpty
            ? const Center(child: Text('No past lists yet'))
            : ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final snapshot = history[index];
                  final created = snapshot.createdAt;
                  final finished = snapshot.finishedAt;
                  final subtitle =
                      'Created: ${created.year}-${created.month.toString().padLeft(2, '0')}-${created.day.toString().padLeft(2, '0')} ${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')}'
                      '\nFinished: ${finished.year}-${finished.month.toString().padLeft(2, '0')}-${finished.day.toString().padLeft(2, '0')} ${finished.hour.toString().padLeft(2, '0')}:${finished.minute.toString().padLeft(2, '0')}'
                      '\nItems: ${snapshot.items.length}';
                  return Card(
                    margin: EdgeInsets.only(top: index == 0 ? 0 : 12),
                    child: ListTile(
                      title: Text(snapshot.title),
                      subtitle: Text(subtitle),
                      onTap: () {
                        context.push(
                          AppRoutes.shoppingHistoryDetails,
                          extra: ShoppingHistoryDetailsArgs(listId: snapshot.id),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
