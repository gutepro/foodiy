import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'package:foodiy/core/brand/brand_assets.dart';
import 'package:foodiy/core/models/user_type.dart';
import 'package:foodiy/core/services/access_control_service.dart';
import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/features/chef/application/chef_recipes_service.dart';
import 'package:foodiy/features/recipe/application/recipe_firestore_service.dart';
import 'package:foodiy/features/recipe/domain/recipe.dart';
import 'package:foodiy/features/recipe/domain/recipe_step.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_player_screen.dart';
import 'package:foodiy/l10n/app_localizations.dart';
import 'package:foodiy/router/app_routes.dart';

class RecipeUploadScreen extends StatefulWidget {
  const RecipeUploadScreen({super.key, this.recipe});

  final Recipe? recipe;

  @override
  State<RecipeUploadScreen> createState() => _RecipeUploadScreenState();
}

class _RecipeUploadScreenState extends State<RecipeUploadScreen> {
  final _titleController = TextEditingController();
  final _preNotesController = TextEditingController();

  final List<TextEditingController> _ingredientNameControllers = [];
  final List<TextEditingController> _ingredientQuantityControllers = [];
  final List<TextEditingController> _ingredientUnitControllers = [];
  final List<TextEditingController> _toolControllers = [];

  final List<_StepField> _steps = [_StepField()];

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;
  String _existingImageUrl = '';
  bool _saving = false;

  bool get _isEdit => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _prefillFromRecipe(widget.recipe!);
    } else {
      _addIngredientRow();
      _addToolRow();
    }
  }

  Future<String?> _uploadCoverToStorage({
    required String uid,
    required String recipeId,
    required Uint8List bytes,
    required String filename,
  }) async {
    final ext = filename.split('.').last;
    final path = 'recipe_covers/$uid/$recipeId.${ext.isNotEmpty ? ext : 'jpg'}';
    final ref = FirebaseStorage.instance.ref().child(path);
    debugPrint(
      'RecipeUploadScreen: uploading cover to $path (bucket ${ref.bucket})',
    );
    final stopwatch = Stopwatch()..start();
    try {
      final uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/${ext.isNotEmpty ? ext : 'jpeg'}'),
      );
      uploadTask.snapshotEvents.listen((event) {
        final transferred = event.bytesTransferred;
        final total = event.totalBytes;
        debugPrint(
          'RecipeUploadScreen: cover progress state=${event.state} $transferred/$total bytes',
        );
      });

      final snapshot = await uploadTask.timeout(
        const Duration(seconds: 90),
        onTimeout: () {
          uploadTask.cancel();
          throw TimeoutException('Cover upload timed out');
        },
      );
      if (snapshot.state != TaskState.success) {
        throw Exception(
          'Cover upload did not complete (state=${snapshot.state})',
        );
      }

      final url = await ref.getDownloadURL().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Cover download URL timed out');
        },
      );
      stopwatch.stop();
      debugPrint(
        'RecipeUploadScreen: cover uploaded in ${stopwatch.elapsed.inSeconds}s url=$url',
      );
      return url;
    } catch (e, st) {
      stopwatch.stop();
      debugPrint(
        'RecipeUploadScreen: cover upload failed after ${stopwatch.elapsed.inSeconds}s: $e\n$st',
      );
      _showMessage('Failed to upload cover image: $e');
      if (mounted) {
        setState(() => _saving = false);
      }
      return null;
    }
  }

  Future<String?> _uploadCoverAndGetUrlIfNeeded({
    required String uid,
    required String recipeId,
  }) async {
    if (_pickedImage == null && _pickedImageBytes == null) {
      if (_existingImageUrl.isNotEmpty) {
        return _existingImageUrl;
      }
      return widget.recipe?.coverImageUrl ?? widget.recipe?.imageUrl;
    }

    final bytes = _pickedImageBytes ?? await _pickedImage?.readAsBytes();
    if (bytes == null) return null;

    final url = await _uploadCoverToStorage(
      uid: uid,
      recipeId: recipeId,
      bytes: bytes,
      filename: _pickedImage?.name ?? 'cover.jpg',
    );
    if (url != null) {
      _existingImageUrl = url;
      _pickedImage = null;
      _pickedImageBytes = null;
    }
    return url;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _preNotesController.dispose();
    for (final c in _ingredientNameControllers) {
      c.dispose();
    }
    for (final c in _ingredientQuantityControllers) {
      c.dispose();
    }
    for (final c in _ingredientUnitControllers) {
      c.dispose();
    }
    for (final c in _toolControllers) {
      c.dispose();
    }
    for (final step in _steps) {
      step.dispose();
    }
    super.dispose();
  }

  void _addIngredientRow() {
    _ingredientNameControllers.add(TextEditingController());
    _ingredientQuantityControllers.add(TextEditingController());
    _ingredientUnitControllers.add(TextEditingController());
    setState(() {});
  }

  void _removeIngredientRow(int index) {
    _ingredientNameControllers[index].dispose();
    _ingredientQuantityControllers[index].dispose();
    _ingredientUnitControllers[index].dispose();
    _ingredientNameControllers.removeAt(index);
    _ingredientQuantityControllers.removeAt(index);
    _ingredientUnitControllers.removeAt(index);
    setState(() {});
  }

  void _addToolRow() {
    _toolControllers.add(TextEditingController());
    setState(() {});
  }

  void _removeToolRow(int index) {
    _toolControllers[index].dispose();
    _toolControllers.removeAt(index);
    setState(() {});
  }

  void _addStep() {
    setState(() => _steps.add(_StepField()));
  }

  void _removeStep(int index) {
    if (_steps.length <= 1) return;
    final removed = _steps.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  Future<void> _pickImageFromFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      Uint8List? bytes = file.bytes;
      if (bytes == null && file.path != null) {
        bytes = await XFile(file.path!).readAsBytes();
      }
      if (bytes == null) return;
      setState(() {
        _pickedImage = file.path != null ? XFile(file.path!) : null;
        _pickedImageBytes = bytes;
        _existingImageUrl = '';
      });
    } catch (e, st) {
      debugPrint('RecipeUploadScreen: file pick failed $e\n$st');
    }
  }

  // Recipe categories are removed from the product model.

  List<RecipeStep> _buildStepsFromForm() {
    final steps = <RecipeStep>[];
    for (final step in _steps) {
      final text = step.textController.text.trim();
      final minutesStr = step.minutesController.text.trim();
      if (text.isEmpty) continue;
      final minutes = int.tryParse(minutesStr) ?? 0;
      final durationSeconds = minutes > 0 ? minutes * 60 : null;
      steps.add(RecipeStep(text: text, durationSeconds: durationSeconds));
    }
    return steps;
  }

  void _prefillFromRecipe(Recipe recipe) {
    _titleController.text = recipe.title;
    _preNotesController.text = recipe.preCookingNotes;
    _existingImageUrl =
        (recipe.coverImageUrl?.isNotEmpty == true
            ? recipe.coverImageUrl
            : recipe.imageUrl) ??
        '';

    _ingredientNameControllers.clear();
    _ingredientQuantityControllers.clear();
    _ingredientUnitControllers.clear();
    for (final ing in recipe.ingredients) {
      _ingredientNameControllers.add(TextEditingController(text: ing.name));
      _ingredientQuantityControllers.add(
        TextEditingController(text: ing.quantity),
      );
      _ingredientUnitControllers.add(TextEditingController(text: ing.unit));
    }
    if (_ingredientNameControllers.isEmpty) {
      _addIngredientRow();
    }

    _toolControllers.clear();
    for (final tool in recipe.tools) {
      _toolControllers.add(TextEditingController(text: tool.name));
    }
    if (_toolControllers.isEmpty) {
      _addToolRow();
    }

    _steps.clear();
    if (recipe.steps.isEmpty) {
      _steps.add(_StepField());
    } else {
      for (final s in recipe.steps) {
        final field = _StepField();
        field.textController.text = s.text;
        field.minutesController.text = s.durationSeconds != null
            ? (s.durationSeconds! ~/ 60).toString()
            : '';
        _steps.add(field);
      }
    }
    setState(() {});
  }

  List<RecipeIngredient> _buildIngredientsFromForm() {
    final result = <RecipeIngredient>[];
    for (var i = 0; i < _ingredientNameControllers.length; i++) {
      final name = _ingredientNameControllers[i].text.trim();
      final qty = _ingredientQuantityControllers[i].text.trim();
      final unit = _ingredientUnitControllers[i].text.trim();
      if (name.isEmpty) continue;
      result.add(RecipeIngredient(name: name, quantity: qty, unit: unit));
    }
    return result;
  }

  List<RecipeTool> _buildToolsFromForm() {
    final result = <RecipeTool>[];
    for (final controller in _toolControllers) {
      final name = controller.text.trim();
      if (name.isEmpty) continue;
      result.add(RecipeTool(name: name));
    }
    return result;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _pickedImage = picked;
      _pickedImageBytes = bytes;
    });
  }

  void _previewInPlayer() {
    final steps = _buildStepsFromForm();
    final languageCode = Localizations.localeOf(context).languageCode;

    final previewImage = _pickedImage != null
        ? _pickedImage!.path
        : 'https://via.placeholder.com/900x600';

    final args = RecipePlayerArgs(
      title: _titleController.text.trim().isEmpty
          ? 'Untitled recipe'
          : _titleController.text.trim(),
      imageUrl: previewImage,
      steps: steps,
      languageCode: languageCode,
    );

    context.push(AppRoutes.recipePlayer, extra: args);
  }

  Future<void> _onSavePressed() async {
    if (_saving) return;
    debugPrint(
      'RecipeUploadScreen: save pressed (edit=$_isEdit) title="${_titleController.text.trim()}" pickedImage=${_pickedImage != null} existingImageUrl=$_existingImageUrl',
    );
    final title = _titleController.text.trim();
    final steps = _buildStepsFromForm();
    final originalLanguageCode = Localizations.localeOf(context).languageCode;
    final ingredients = _buildIngredientsFromForm();
    final tools = _buildToolsFromForm();
    final preNotes = _preNotesController.text.trim();

    if (title.isEmpty) {
      _showMessage('Please enter a recipe title');
      return;
    }
    if (steps.isEmpty) {
      _showMessage('Please add at least one step');
      return;
    }

    final hadNewCover = _pickedImage != null || _pickedImageBytes != null;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.uid.isEmpty) {
        _showMessage('Please sign in to save recipes');
        return;
      }
      setState(() => _saving = true);
      final recipeId = _isEdit && (widget.recipe?.id.isNotEmpty ?? false)
          ? widget.recipe!.id
          : RecipeFirestoreService.instance.newRecipeId();
      final imageUrl = await _uploadCoverAndGetUrlIfNeeded(
        uid: user.uid,
        recipeId: recipeId,
      );
      if (hadNewCover && imageUrl == null) {
        return;
      }

      final recipeBase =
          widget.recipe ??
          Recipe(
            id: recipeId,
            originalLanguageCode: originalLanguageCode,
            title: title,
            imageUrl: imageUrl,
            coverImageUrl: imageUrl,
            categories: const [],
            sourceType: 'manual',
            importStatus: 'ready',
            steps: steps,
            ingredients: ingredients,
            tools: tools,
            preCookingNotes: preNotes,
            chefId: user.uid,
          );

      final recipeToSave = recipeBase.copyWith(
        id: recipeId,
        originalLanguageCode:
            widget.recipe?.originalLanguageCode ?? originalLanguageCode,
        title: title,
        imageUrl: imageUrl,
        coverImageUrl: imageUrl,
        categories: const [],
        sourceType: widget.recipe?.sourceType ?? 'manual',
        originalDocumentUrl: widget.recipe?.originalDocumentUrl,
        importStatus: widget.recipe?.importStatus ?? 'ready',
        steps: steps,
        ingredients: ingredients,
        tools: tools,
        preCookingNotes: preNotes,
        chefId: recipeBase.chefId.isNotEmpty ? recipeBase.chefId : user.uid,
        chefName: recipeBase.chefName,
        chefAvatarUrl: recipeBase.chefAvatarUrl,
      );

      debugPrint('RecipeUploadScreen: calling saveRecipe for id=$recipeId');
      final id = await RecipeFirestoreService.instance.saveRecipe(recipeToSave);
      debugPrint('RecipeUploadScreen: saved recipe $id');

      final summary = ChefRecipeSummary(
        id: id,
        title: recipeToSave.title,
        imageUrl: recipeToSave.coverImageUrl ?? recipeToSave.imageUrl ?? '',
        time: AppLocalizations.of(context)!.profileStepsCount(steps.length),
        difficulty: AppLocalizations.of(context)!.recipeDifficultyMedium,
      );
      ChefRecipesService.instance.addRecipe(summary);

      _showMessage(
        AppLocalizations.of(context)!.recipeSaveSuccess(recipeToSave.title),
      );
      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e, st) {
      debugPrint('RecipeUploadScreen: failed to save recipe: $e\n$st');
      // Fail fast: if save verification fails, do not allow "publish" to succeed.
      _showMessage(AppLocalizations.of(context)!.recipeSaveFailed('$e'));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmDelete() async {
    if (!_isEdit || (widget.recipe?.id.isEmpty ?? true)) return;
    final l10n = AppLocalizations.of(context)!;
    final first = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.recipeDeleteStep1Title),
        content: Text(l10n.recipeDeleteStep1Body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.homeCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.recipeDeleteStep1Continue),
          ),
        ],
      ),
    );
    if (first != true) return;

    final second = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.recipeDeleteStep2Title),
        content: Text(l10n.recipeDeleteStep2Body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.homeCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.recipeDeleteStep2Delete),
          ),
        ],
      ),
    );
    if (second != true) return;

    await _deleteRecipe();
  }

  Future<void> _deleteRecipe() async {
    final recipe = widget.recipe;
    if (recipe == null) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _saving = true;
    });
    try {
      await RecipeFirestoreService.instance.deleteRecipe(recipe.id);
      final urls = <String?>{
        recipe.coverImageUrl,
        recipe.imageUrl,
        recipe.originalDocumentUrl,
      };
      for (final url in urls) {
        await _deleteStorageUrl(url);
      }
      if (!mounted) return;
      _showMessage(l10n.homeRecipeDeleted);
      context.go(AppRoutes.home);
    } catch (e, st) {
      debugPrint('RecipeUploadScreen: delete failed $e\n$st');
      if (!mounted) return;
      _showMessage(l10n.recipeDeleteFailed('$e'));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _deleteStorageUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      final ref = FirebaseStorage.instance.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint('RecipeUploadScreen: storage delete skipped for $url error=$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final profile = CurrentUserService.instance.currentProfile;
    final userType = profile?.userType ?? UserType.freeUser;
    final access = AccessControlService.instance;
    final isChef = access.isChef(userType);
    final isFreeChef = userType == UserType.freeChef;
    final chefService = ChefRecipesService.instance;
    final reachedLimit = isFreeChef && chefService.hasReachedFreeChefLimit();

    if (!isChef) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.recipeCreateTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.recipeOnlyChefBody,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (reachedLimit) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.recipeCreateTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.recipeFreePlanLimitBody,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.recipeEditTitle : l10n.recipeCreateTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(l10n.recipePhotoLabel, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        color: Colors.grey.shade100,
                        child: _pickedImageBytes != null
                            ? Image.memory(
                                _pickedImageBytes!,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : _existingImageUrl.isNotEmpty
                            ? Image.network(
                                _existingImageUrl,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    BrandAssets.foodiyLogo,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                  );
                                },
                              )
                            : Image.asset(
                                BrandAssets.foodiyLogo,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.contain,
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        SizedBox(
                          width: (MediaQuery.of(context).size.width - 48) / 2,
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: Text(l10n.recipeTakePhoto),
                          ),
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width - 48) / 2,
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_outlined),
                            label: Text(l10n.recipePhotoLibrary),
                          ),
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width - 48) / 2,
                          child: OutlinedButton.icon(
                            onPressed: _pickImageFromFiles,
                            icon: const Icon(Icons.insert_drive_file_outlined),
                            label: Text(l10n.recipePickFile),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (access.hasUploadLimit(userType)) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(l10n.recipeUploadLimitBanner),
                      ),
                    ],
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: l10n.recipeTitleLabel,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.recipeIngredientsTitle, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Column(
                      children: List.generate(
                        _ingredientNameControllers.length,
                        (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller:
                                        _ingredientNameControllers[index],
                                    decoration: InputDecoration(
                                      labelText: l10n.recipeIngredientLabel,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller:
                                        _ingredientQuantityControllers[index],
                                    decoration: InputDecoration(
                                      labelText: l10n.recipeQuantityLabel,
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller:
                                        _ingredientUnitControllers[index],
                                    decoration: InputDecoration(
                                      labelText: l10n.recipeUnitLabel,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed:
                                      _ingredientNameControllers.length > 1
                                      ? () => _removeIngredientRow(index)
                                      : null,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _addIngredientRow,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.recipeAddIngredient),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.recipeToolsTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: List.generate(_toolControllers.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _toolControllers[index],
                                  decoration: InputDecoration(
                                    labelText: l10n.recipeToolLabel,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: _toolControllers.length > 1
                                    ? () => _removeToolRow(index)
                                    : null,
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _addToolRow,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.recipeAddTool),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.recipePreCookingTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _preNotesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: l10n.recipePreCookingHint,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.recipeStepsTitle, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        for (int i = 0; i < _steps.length; i++) ...[
                          _StepEditor(
                            stepField: _steps[i],
                            onRemove: () => _removeStep(i),
                            showRemove: _steps.length > 1,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: _addStep,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.recipeAddStep),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _previewInPlayer,
                      child: Text(l10n.recipePreviewInPlayer),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _onSavePressed,
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEdit ? l10n.recipeUpdateButton : l10n.recipeSaveButton),
                ),
              ),
            ),
            if (_isEdit)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextButton(
                  onPressed: _saving ? null : _confirmDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  child: Text(AppLocalizations.of(context)!.recipeDeleteButton),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StepEditor extends StatelessWidget {
  const _StepEditor({
    required this.stepField,
    required this.onRemove,
    required this.showRemove,
  });

  final _StepField stepField;
  final VoidCallback onRemove;
  final bool showRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: stepField.textController,
            decoration: InputDecoration(labelText: l10n.recipeStepLabel),
            maxLines: null,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: TextField(
            controller: stepField.minutesController,
            decoration: InputDecoration(labelText: l10n.recipeStepMinutesLabel),
            keyboardType: TextInputType.number,
          ),
        ),
        if (showRemove) ...[
          const SizedBox(width: 4),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close),
            tooltip: l10n.recipeRemoveStepTooltip,
          ),
        ],
      ],
    );
  }
}

class _StepField {
  final TextEditingController textController = TextEditingController();
  final TextEditingController minutesController = TextEditingController();

  void dispose() {
    textController.dispose();
    minutesController.dispose();
  }
}
