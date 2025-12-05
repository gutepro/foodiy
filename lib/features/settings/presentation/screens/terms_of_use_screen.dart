import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of use'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            'This is a placeholder for the Foodiy terms of use.\n\n'
            'Here you will describe the rules for using the app, limitations of liability, and other legal details.\n'
            'Later we will replace this text with the real terms.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
