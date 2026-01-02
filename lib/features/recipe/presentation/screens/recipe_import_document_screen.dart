import 'dart:typed_data';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/features/recipe/application/recipe_firestore_service.dart';
import 'package:foodiy/features/recipe/domain/recipe.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_details_screen.dart';
import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/shared/widgets/foodiy_logo.dart';
import 'package:foodiy/l10n/app_localizations.dart';

class RecipeImportDocumentScreen extends StatefulWidget {
  const RecipeImportDocumentScreen({super.key});

  @override
  State<RecipeImportDocumentScreen> createState() =>
      _RecipeImportDocumentScreenState();
}

class _RecipeImportDocumentScreenState
    extends State<RecipeImportDocumentScreen> {
  String _selectedFileName = '';
  Uint8List? _selectedBytes;
  String _selectedExtension = '';
  _ImportPhase _phase = _ImportPhase.idle;
  String? _errorMessage;
  int _progressStep = 0;
  bool _navigating = false;

  final List<String> _progressSteps = const [
    'Uploading securely',
    'Understanding the recipe',
    'Saving to your cookbook',
  ];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hasSelection =
        _selectedBytes != null && _selectedExtension.isNotEmpty;
    final selectedSize = _selectedBytes != null
        ? _formatBytes(_selectedBytes!.length)
        : '';

    return WillPopScope(
      onWillPop: () async => !_isBusy,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.importDocTitle),
          leading: _isBusy ? Container() : null,
        ),
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.importDocHeader,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.importDocBody,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.description_outlined,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        hasSelection
                                            ? l10n.importDocFileReady
                                            : l10n.importDocAddDocument,
                                        style:
                                            theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        hasSelection
                                            ? _selectedFileName
                                            : l10n.importDocFormatsShort,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                if (hasSelection)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      selectedSize,
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: hasSelection
                                  ? Container(
                                      key: const ValueKey('file-selected'),
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surfaceVariant
                                            .withOpacity(0.35),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.check_circle,
                                              color: Colors.green),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              l10n.importDocProcessingNote,
                                              style: theme
                                                  .textTheme.bodyMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      key: const ValueKey('file-empty'),
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.dividerColor,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.hourglass_empty_outlined,
                                            color: theme.disabledColor,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              l10n.importDocEmptyHelper,
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _isBusy ? null : _onPickFile,
                                  icon: const Icon(Icons.attach_file),
                                  label: Text(l10n.importDocChooseFile),
                                ),
                                OutlinedButton.icon(
                                  onPressed: _isBusy ? null : _onPickGallery,
                                  icon: const Icon(Icons.photo_library_outlined),
                                  label: Text(l10n.importDocChoosePhoto),
                                ),
                                OutlinedButton.icon(
                                  onPressed: _isBusy ? null : _onTakePhoto,
                                  icon: const Icon(Icons.photo_camera),
                                  label: Text(l10n.importDocTakePhoto),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.importDocTipsTitle,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ...[
                              l10n.importDocTip1,
                              l10n.importDocTip2,
                              l10n.importDocTip3,
                            ].map(
                              (tip) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 6),
                                      child: Icon(
                                        Icons.circle,
                                        size: 6,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: SizedBox(
                        width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                                (!_isBusy && hasSelection) ? _onUploadPressed : null,
                            icon: _isBusy
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.cloud_upload_outlined),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(l10n.importDocUpload),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.importDocSupportedFooter,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.hintColor),
                    ),
                  ],
                ),
              ),
            ),
            if (_phase != _ImportPhase.idle) _buildOverlay(context, theme),
          ],
        ),
      ),
    );
  }

  Future<void> _onPickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'jpg',
        'jpeg',
        'png',
        'webp',
        'heic',
        'heif',
      ],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    Uint8List? bytes = file.bytes;
    // iOS/iCloud may return null bytes with a path; try reading from path.
    if (bytes == null && file.path != null) {
      try {
        final ioFile = File(file.path!);
        if (await ioFile.exists()) {
          bytes = await ioFile.readAsBytes();
        }
      } catch (e) {
        debugPrint('Failed to read picked file from path: $e');
      }
    }

    if (bytes == null || bytes.isEmpty) {
      _showMessage('Failed to read file bytes. Please pick a local file.');
      return;
    }

    setState(() {
      _selectedFileName = file.name;
      _selectedBytes = bytes;
      final parts = file.name.split('.');
      _selectedExtension =
          parts.length > 1 ? parts.last.toLowerCase() : '';
    });
  }

  Future<void> _onTakePhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedFileName =
            'camera_${DateTime.now().millisecondsSinceEpoch}.jpg';
        _selectedBytes = bytes;
        _selectedExtension = 'jpg';
      });
    } catch (e) {
      debugPrint('Failed to take photo: $e');
      _showMessage('Failed to take photo');
    }
  }

  Future<void> _onPickGallery() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      final name = picked.name.isNotEmpty
          ? picked.name
          : 'gallery_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final parts = name.split('.');
      final ext = parts.length > 1 ? parts.last.toLowerCase() : 'jpg';
      setState(() {
        _selectedFileName = name;
        _selectedBytes = bytes;
        _selectedExtension = ext;
      });
    } catch (e) {
      debugPrint('Failed to pick photo: $e');
      _showMessage('Failed to pick photo');
    }
  }

  Future<void> _onUploadPressed() async {
    if (_isBusy || _navigating) return;
    final bytes = _selectedBytes;
    if (bytes == null || _selectedExtension.isEmpty) return;
    if (bytes.isEmpty) {
      _showMessage('Selected file is empty. Please choose another file.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid.isEmpty) {
      _showMessage('Please sign in to import recipes');
      return;
    }

    _setPhase(_ImportPhase.uploading);

    try {
      final uid = user.uid;
      final recipeId = RecipeFirestoreService.instance.newRecipeId();

      final ext = _selectedExtension;
      final safeExt = ext.isNotEmpty ? ext : 'bin';
      final path = 'recipe_docs/$uid/$recipeId/source.$safeExt';

      // Use the same bucket where existing assets live.
      final storage = FirebaseStorage.instanceFor(
        bucket: 'gs://foodiy-6a9d9.firebasestorage.app',
      );
      final ref = storage.ref().child(path);

      debugPrint(
        'UPLOAD PATH (Flutter) = $path | size=${bytes.length} bytes | ext=$safeExt | uid=$uid',
      );

      await _uploadWithRetry(ref, bytes, ext);

      _setPhase(_ImportPhase.processing);

      final downloadUrl = await ref.getDownloadURL();

      final localeCode = Localizations.localeOf(context).languageCode;
      final profile = CurrentUserService.instance.currentProfile;

      final title = _selectedFileName.isNotEmpty
          ? _selectedFileName.replaceAll(RegExp(r'\.[^.]+$'), '')
          : 'Imported recipe';

      final recipe = Recipe(
        id: recipeId,
        originalLanguageCode: localeCode,
        title: title,
        imageUrl: null,
        coverImageUrl: null,
        categories: const [],
        sourceType: 'document',
        originalDocumentUrl: downloadUrl,
        sourceFilePath: path,
        status: 'uploading',
        progress: 0,
        debugStage: 'uploaded',
        importStatus: 'uploading',
        importStage: 'uploading',
        steps: const [],
        ingredients: const [],
        tools: const [],
        preCookingNotes: '',
        chefId: uid,
        chefName: profile?.displayName ?? user.displayName,
        chefAvatarUrl: profile?.photoUrl ?? user.photoURL,
        isPublic: false,
        views: 0,
        playlistAdds: 0,
      );

      _setPhase(_ImportPhase.saving);
      await RecipeFirestoreService.instance.saveRecipe(recipe);
      debugPrint('RecipeImportDocumentScreen: listening path recipes/$recipeId');

      if (!mounted) return;

      _setPhase(_ImportPhase.success);
      _showMessage('Document uploaded. Recipe created.');

      // Navigate to recipe details - the recipe may still be processing.
      _navigating = true;
      _closeBlockingUiAndReset();
      debugPrint('[NAV] from=RecipeImportDocument to=${AppRoutes.recipeDetails} reason=upload_success id=$recipeId');
      context.go(
        AppRoutes.recipeDetails,
        extra: RecipeDetailsArgs(
          id: recipeId,
          title: recipe.title,
          imageUrl: '',
          time: '0 steps',
          difficulty: '-',
          originalLanguageCode: localeCode,
          ingredients: const [],
          steps: const [],
        ),
      );
      _navigating = false;
    } catch (e, st) {
      debugPrint('RecipeImportDocumentScreen: upload failed: $e\n$st');
      _setPhase(
        _ImportPhase.error,
        error: 'Failed to upload document. Please try again.',
      );
      if (mounted) {
        if (e is FirebaseException) {
          _showMessage(
            'Failed to upload: ${e.code}. Tap Retry or pick another file.',
          );
        } else {
          _showMessage('Failed to upload document: $e');
        }
      }
    } finally {
      if (mounted && _phase != _ImportPhase.processing) {}
    }
  }

  Future<void> _uploadWithRetry(
    Reference ref,
    Uint8List bytes,
    String ext, {
    int maxAttempts = 2,
  }) async {
    FirebaseException? lastError;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: _guessContentType(ext)),
        );
        final snapshot = await uploadTask;
        if (snapshot.state != TaskState.success) {
          throw FirebaseException(
            plugin: 'firebase_storage',
            code: 'upload-failed',
            message:
                'Upload task ended with state ${snapshot.state}. bytes=${bytes.length}',
          );
        }
        // Confirm object exists before moving on.
        await ref.getMetadata();
        return;
      } on FirebaseException catch (e) {
        lastError = e;
        debugPrint('Upload attempt $attempt failed: ${e.code} ${e.message}');
        if (attempt == maxAttempts) rethrow;
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
    if (lastError != null) throw lastError;
  }

  String _guessContentType(String ext) {
    final lower = ext.toLowerCase();
    if (['jpg', 'jpeg'].contains(lower)) return 'image/jpeg';
    if (lower == 'png') return 'image/png';
    if (lower == 'webp') return 'image/webp';
    if (lower == 'pdf') return 'application/pdf';
    if (lower == 'doc') return 'application/msword';
    if (lower == 'docx') {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    return 'application/octet-stream';
  }

  bool get _isBusy =>
      _phase == _ImportPhase.uploading ||
      _phase == _ImportPhase.processing ||
      _phase == _ImportPhase.saving;

  void _closeBlockingUiAndReset() {
    if (!mounted) return;
    _setPhase(_ImportPhase.idle);
    final rootNav = Navigator.of(context, rootNavigator: true);
    if (rootNav.canPop()) {
      rootNav.popUntil((route) => route.isFirst);
    }
  }

  void _setPhase(_ImportPhase phase, {String? error}) {
    if (!mounted) return;
    setState(() {
      _phase = phase;
      _errorMessage = error;
      if (phase == _ImportPhase.idle ||
          phase == _ImportPhase.success ||
          phase == _ImportPhase.error) {}
      _progressStep = _stepForPhase(phase);
    });
  }

  int _stepForPhase(_ImportPhase phase) {
    switch (phase) {
      case _ImportPhase.uploading:
        return 0;
      case _ImportPhase.processing:
        return 1;
      case _ImportPhase.saving:
      case _ImportPhase.success:
        return 2;
      case _ImportPhase.error:
        return _progressStep;
      case _ImportPhase.idle:
        return 0;
    }
  }

  Widget _buildOverlay(BuildContext context, ThemeData theme) {
    final isError = _phase == _ImportPhase.error;
    final stepIndex = _progressStep.clamp(0, _progressSteps.length - 1);
    return Positioned.fill(
      child: Stack(
        children: [
          const ModalBarrier(
            dismissible: false,
            color: Colors.black26,
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 80,
                      width: 80,
                      child: FoodiyLogo(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isError
                          ? 'Something went wrong'
                          : (_phase == _ImportPhase.uploading
                              ? 'Uploading…'
                              : 'Processing…'),
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    if (!isError)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_progressSteps.length, (index) {
                          final label = _progressSteps[index];
                          final isDone = index < stepIndex;
                          final isActive = index == stepIndex;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isDone
                                      ? Icons.check_circle
                                      : isActive
                                          ? Icons.timelapse
                                          : Icons.radio_button_unchecked,
                                  color: isDone
                                      ? Colors.green
                                      : isActive
                                          ? theme.colorScheme.primary
                                          : theme.disabledColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  label,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    if (isError && _errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton(
                            onPressed: () => _setPhase(_ImportPhase.idle),
                            child: const Text('Back'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _onUploadPressed,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ],
                    if (!isError) ...[
                      const SizedBox(height: 16),
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${size.toStringAsFixed(size >= 10 ? 0 : 1)} ${units[unitIndex]}';
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

enum _ImportPhase {
  idle,
  uploading,
  processing,
  saving,
  success,
  error,
}
