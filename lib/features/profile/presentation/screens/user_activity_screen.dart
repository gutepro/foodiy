import 'package:flutter/material.dart';

import 'package:foodiy/features/profile/application/user_profile_service.dart';
import 'package:foodiy/shared/widgets/foodiy_app_bar.dart';

class UserActivityScreen extends StatelessWidget {
  const UserActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = UserProfileService.instance;
    final activity = service.activity;

    return Scaffold(
      appBar: const FoodiyAppBar(title: Text('Activity')),
      body: activity.isEmpty
          ? const Center(child: Text('No recent activity yet'))
          : ListView.builder(
              itemCount: activity.length,
              itemBuilder: (context, index) {
                final item = activity[index];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(item.description),
                  subtitle: Text(item.timestamp.toLocal().toString()),
                );
              },
            ),
    );
  }
}
