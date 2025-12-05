import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:foodiy/core/models/user_type.dart';
import 'package:foodiy/core/services/current_user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();
  Uint8List? _pickedImageBytes;
  String? _uploadedUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = CurrentUserService.instance.currentProfile;
    _firstNameController.text = profile?.firstName ?? '';
    _lastNameController.text = profile?.lastName ?? '';
    _bioController.text = profile?.chefBio ?? '';
    _websiteController.text = profile?.websiteUrl ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _pickedImageBytes = bytes;
    });
  }

  Future<String?> _uploadImage(String uid) async {
    if (_pickedImageBytes == null) return null;
    final ref = FirebaseStorage.instance.ref().child('users/$uid/profile.jpg');
    await ref.putData(_pickedImageBytes!);
    return ref.getDownloadURL();
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      final photoUrl = await _uploadImage(uid) ?? _uploadedUrl;
      final updates = <String, dynamic>{
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'chefBio': _bioController.text.trim(),
        'websiteUrl': _websiteController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (photoUrl != null) {
        updates['photoUrl'] = photoUrl;
      }
      await FirebaseFirestore.instance.collection('users').doc(uid).update(updates);
      await CurrentUserService.instance.refreshFromFirebase();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = CurrentUserService.instance.currentProfile;
    final isChef = (profile?.isChef ?? false) ||
        (profile?.userType == UserType.premiumChef);
    ImageProvider? imageProvider;
    if (_pickedImageBytes != null) {
      imageProvider = MemoryImage(_pickedImageBytes!);
    } else if ((profile?.photoUrl ?? '').isNotEmpty) {
      imageProvider = NetworkImage(profile!.photoUrl!);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage: imageProvider,
                child: imageProvider == null ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _saving ? null : _pickImage,
                child: const Text('Change photo'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _firstNameController,
            decoration: const InputDecoration(labelText: 'First name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _lastNameController,
            decoration: const InputDecoration(labelText: 'Last name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bioController,
            decoration: const InputDecoration(labelText: 'Bio'),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          if (isChef)
            TextField(
              controller: _websiteController,
              decoration: const InputDecoration(labelText: 'Website URL'),
            ),
        ],
      ),
    );
  }
}
