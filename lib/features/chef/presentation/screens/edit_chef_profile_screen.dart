import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:foodiy/shared/widgets/foodiy_app_bar.dart';
import 'package:foodiy/l10n/app_localizations.dart';

class EditChefProfileScreen extends StatefulWidget {
  const EditChefProfileScreen({super.key, required this.chefId});

  final String chefId;

  @override
  State<EditChefProfileScreen> createState() => _EditChefProfileScreenState();
}

class _EditChefProfileScreenState extends State<EditChefProfileScreen> {
  final _bioController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _avatarUrl;
  XFile? _newAvatarFile;
  String _initialBio = '';
  String? _initialAvatarUrl;
  bool _canEdit = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[EDIT_PROFILE_INIT] uid=${widget.chefId}');
    _bioController.addListener(() {
      setState(() {});
    });
    _load();
  }

  Future<void> _load() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.chefId)
          .get();
      final data = snap.data() ?? {};
      debugPrint(
        '[EDIT_PROFILE_DOC] uid=${widget.chefId} exists=${snap.exists} keys=${data.keys.toList()}',
      );
      _initialBio = (data['chefBio'] as String?)?.trim() ?? '';
      _initialAvatarUrl = (data['chefAvatarUrl'] as String?)?.trim();
      _bioController.text = _initialBio;
      _avatarUrl = _initialAvatarUrl;
      _canEdit = FirebaseAuth.instance.currentUser?.uid == widget.chefId;
    } catch (e, st) {
      debugPrint('EditChefProfileScreen load error: $e\n$st');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  bool get _dirty =>
      (_bioController.text.trim() != _initialBio) || _newAvatarFile != null;

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) {
      setState(() {
        _newAvatarFile = file;
      });
    }
  }

  Future<void> _save() async {
    debugPrint(
      '[EDIT_SAVE_TAP] enabled=${_canEdit && _dirty && !_saving && !_loading} dirty=$_dirty canEdit=$_canEdit saving=$_saving',
    );
    if (_saving || !_dirty || !_canEdit) return;
    setState(() => _saving = true);
    try {
      String? downloadUrl = _avatarUrl;
      if (_newAvatarFile != null) {
        final uid = widget.chefId;
        final ref = FirebaseStorage.instance
            .ref()
            .child('chef_avatars')
            .child(uid)
            .child('avatar.jpg');
        await ref.putFile(File(_newAvatarFile!.path));
        downloadUrl = await ref.getDownloadURL();
      }
      await FirebaseFirestore.instance.collection('users').doc(widget.chefId).set(
        {
          'chefBio': _bioController.text.trim(),
          'chefAvatarUrl': downloadUrl ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      if (!mounted) return;
      debugPrint('[EDIT_SAVE_SUCCESS_POP] uid=${widget.chefId}');
      Navigator.of(context).pop(true);
    } catch (e, st) {
      debugPrint('EditChefProfileScreen save error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.chefSaveFailed)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    debugPrint(
      '[L10N] locale=${Localizations.localeOf(context)} screen=edit_chef_profile',
    );
    final canEdit = _canEdit;
    final avatarPreview = _newAvatarFile != null
        ? Image.file(File(_newAvatarFile!.path), fit: BoxFit.cover)
        : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
            ? Image.network(_avatarUrl!, fit: BoxFit.cover)
            : const Icon(Icons.person, size: 32, color: Colors.white);

    return Scaffold(
      appBar: FoodiyAppBar(
        title: Text(l10n.profileEditChefProfile),
        actions: [
          TextButton(
            onPressed:
                (!_loading && canEdit && _dirty && !_saving) ? _save : null,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.cookbooksSave),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!canEdit)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.chefEditOwnOnly,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else ...[
                Text(
                  l10n.chefEditAvatarLabel,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        child: avatarPreview,
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _saving ? null : _pickAvatar,
                      icon: const Icon(Icons.photo_camera),
                      label: Text(l10n.chefEditChangePhoto),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(l10n.chefEditBioLabel, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _bioController,
                  maxLength: 300,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: l10n.chefEditBioHint,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                if (!_dirty)
                  Text(
                    l10n.chefEditMakeChangeToSave,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
