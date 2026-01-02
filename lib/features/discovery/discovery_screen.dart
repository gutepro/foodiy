import 'package:flutter/material.dart';

import 'package:foodiy/features/discovery/discovery_feed.dart';

class DiscoveryScreen extends StatelessWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discovery')),
      body: const DiscoveryFeed(),
    );
  }
}
