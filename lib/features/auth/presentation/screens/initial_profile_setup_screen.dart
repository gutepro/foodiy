import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/router/app_routes.dart';

class InitialProfileSetupScreen extends StatefulWidget {
  const InitialProfileSetupScreen({super.key});

  @override
  State<InitialProfileSetupScreen> createState() => _InitialProfileSetupScreenState();
}

enum _UserIntent { cook, chef }

class _InitialProfileSetupScreenState extends State<InitialProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  _UserIntent _intent = _UserIntent.cook;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _continue() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage('Please enter your name');
      return;
    }
    // TODO: Save initial profile data (displayName, role) to Firestore.
    _goToPackages();
  }

  Future<void> _goToPackages() async {
    await CurrentUserService.instance.refreshFromFirebase();
    // TODO: Only show package selection on first login, skip for returning users based on Firestore flag.
    if (!mounted) return;
    context.go(AppRoutes.selectPackage);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete your profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tell us a bit about you'),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Display name',
              ),
            ),
            const SizedBox(height: 16),
            const Text('I am here mainly to:'),
            RadioListTile<_UserIntent>(
              title: const Text('Cook and save recipes'),
              value: _UserIntent.cook,
              groupValue: _intent,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _intent = value);
                }
              },
            ),
            RadioListTile<_UserIntent>(
              title: const Text('Create and share recipes'),
              value: _UserIntent.chef,
              groupValue: _intent,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _intent = value);
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _continue,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
