import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DiscoveryScreen extends StatelessWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('foodiy - Discovery'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(
              child: Center(
                child: Text(
                  'Explore curated recipes, chefs, playlists, and shopping inspiration right from this hub.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () => context.go('/recipe'),
                  child: const Text('Go to Recipe'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.go('/chef'),
                  child: const Text('Go to Chef'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.go('/playlists'),
                  child: const Text('Go to Playlists'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.go('/shopping'),
                  child: const Text('Go to Shopping List'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
