import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy policy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            'This is a placeholder for the Foodiy privacy policy.\n\n'
            'Here you will describe how user data is used, stored, and protected.\n'
            'Later we will replace this text with the real policy.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
