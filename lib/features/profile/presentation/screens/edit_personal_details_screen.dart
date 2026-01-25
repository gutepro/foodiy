import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/shared/widgets/foodiy_app_bar.dart';

class EditPersonalDetailsScreen extends StatefulWidget {
  const EditPersonalDetailsScreen({super.key});

  @override
  State<EditPersonalDetailsScreen> createState() =>
      _EditPersonalDetailsScreenState();
}

class _EditPersonalDetailsScreenState extends State<EditPersonalDetailsScreen> {
  final _displayNameController = TextEditingController();
  User? _user;
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _loadDisplayName();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _loadDisplayName() async {
    final cached = CurrentUserService.instance.currentProfile;
    if (cached?.displayName?.isNotEmpty == true) {
      _displayNameController.text = cached!.displayName!;
      setState(() => _isLoading = false);
      return;
    }
    final uid = _user?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }
    final snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = snap.data() ?? {};
    final name = (data['displayName'] as String?) ?? '';
    _displayNameController.text = name;
    setState(() => _isLoading = false);
  }

  Future<void> _onSavePressed() async {
    final newName = _displayNameController.text.trim();
    if (_user == null) return;
    if (newName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a name')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await CurrentUserService.instance.updateDisplayName(newName);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Details updated')));
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Failed to update')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FoodiyAppBar(title: Text('Edit personal details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const LinearProgressIndicator(minHeight: 2)
            else
              TextField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: 'Display name'),
              ),
            const SizedBox(height: 12),
            if (_user?.email != null)
              Text(
                'Email: ${_user!.email}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _onSavePressed,
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
