import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:foodiy/core/models/user_type.dart';
import 'package:foodiy/core/services/access_control_service.dart';
import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/features/chef/application/chef_recipes_service.dart';
import 'package:foodiy/features/recipe/application/recipe_firestore_service.dart';
import 'package:foodiy/features/recipe/domain/recipe.dart';
import 'package:foodiy/features/recipe/domain/recipe_step.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_player_screen.dart';
import 'package:foodiy/features/chef/presentation/screens/chef_my_recipes_screen.dart';
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

  bool get _isEdit => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _prefillFromRecipe(widget.recipe!);
    } else {
      _addIngredientRow();
      _addToolRow();
    }
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

  void _prefillFromRecipe(Recipe recipe) {
    _titleController.text = recipe.title;
    _preNotesController.text = recipe.preCookingNotes;
    _existingImageUrl = recipe.imageUrl;

    _ingredientNameControllers.clear();
    _ingredientQuantityControllers.clear();
    _ingredientUnitControllers.clear();
    for (final ing in recipe.ingredients) {
      _ingredientNameControllers.add(TextEditingController(text: ing.name));
      _ingredientQuantityControllers
          .add(TextEditingController(text: ing.quantity));
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
        field.minutesController.text =
            s.durationSeconds != null ? (s.durationSeconds! ~/ 60).toString() : '';
        _steps.add(field);
      }
    }
  }

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
        : _existingImageUrl;

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

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid.isEmpty) {
      _showMessage('Please sign in to save recipes');
      return;
    }
    final profile = CurrentUserService.instance.currentProfile;
    final chefId = user.uid;
    final chefName = profile?.displayName ?? user.displayName;
    final chefAvatarUrl = profile?.photoUrl ?? user.photoURL;

    final recipeId =
        _isEdit ? (widget.recipe?.id ?? '') : RecipeFirestoreService.instance.newRecipeId();
    String imageUrl = _existingImageUrl;
    if (_pickedImage != null) {
      final storageRef =
          FirebaseStorage.instance.ref().child('recipes/$chefId/$recipeId.jpg');
      try {
        await storageRef.putData(
          _pickedImageBytes ?? await _pickedImage!.readAsBytes(),
        );
        imageUrl = await storageRef.getDownloadURL();
      } catch (e) {
        debugPrint('Failed to upload recipe image: $e');
      }
    }

    final data = {
      'id': recipeId,
      'originalLanguageCode': originalLanguageCode,
      'title': title,
      'imageUrl': imageUrl,
      'steps': steps.map((s) => s.toJson()).toList(),
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'tools': tools.map((t) => t.toJson()).toList(),
      'preCookingNotes': preNotes,
      'chefId': chefId,
      'chefName': chefName,
      'chefAvatarUrl': chefAvatarUrl,
      'views': 0,
      'playlistAdds': 0,
      'isPublic': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      debugPrint(
        'Saving recipe: $data',
      );
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(recipeId)
          .set(data, SetOptions(merge: true));
      if (mounted) {
        _showMessage('Recipe "$title" saved');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ChefMyRecipesScreen()),
        );
      }
    } catch (e) {
      _showMessage('Failed to save recipe: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: AppBar(
          title: const Text('Create recipe'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Only chef accounts can upload recipes.\n\n'
              'Upgrade to a chef plan to start creating recipes.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (reachedLimit) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create recipe'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'You have reached the upload limit for the free chef plan.\n\n'
              'Upgrade to a premium chef plan to create more recipes.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit recipe' : 'Create recipe'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recipe photo', style: theme.textTheme.titleMedium),
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
                      : (_existingImageUrl.isNotEmpty
                          ? Image.network(
                              _existingImageUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/foodiy_logo.png.png',
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                );
                              },
                            )
                          : Image.asset(
                              'assets/images/foodiy_logo.png.png',
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.contain,
                            )),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Choose from gallery'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Take a photo'),
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
                  child: const Text(
                    'Free chef plan - recipe upload is limited.\n'
                    'Upgrade to premium chef to remove this limit.',
                  ),
                ),
              ],
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Recipe title',
                ),
              ),
              const SizedBox(height: 20),
              Text('Ingredients', style: theme.textTheme.titleMedium),
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
                              controller: _ingredientNameControllers[index],
                              decoration: const InputDecoration(
                                labelText: 'Ingredient',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _ingredientQuantityControllers[index],
                              decoration: const InputDecoration(
                                labelText: 'Qty',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _ingredientUnitControllers[index],
                              decoration: const InputDecoration(
                                labelText: 'Unit',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: _ingredientNameControllers.length > 1
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
                  label: const Text('Add ingredient'),
                ),
              ),
              const SizedBox(height: 24),
              Text('Tools / Equipment', style: theme.textTheme.titleMedium),
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
                            decoration: const InputDecoration(
                              labelText: 'Tool',
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
                  label: const Text('Add tool'),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Preparation before cooking',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _preNotesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText:
                      'For example: preheat oven to 200C, line the tray, soak beans overnight...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Text('Steps', style: theme.textTheme.titleMedium),
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
                label: const Text('Add step'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _previewInPlayer,
                child: const Text('Preview in player'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onSavePressed,
                  child: const Text('Save recipe'),
                ),
              ),
            ],
          ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: stepField.textController,
            decoration: const InputDecoration(labelText: 'Step'),
            maxLines: null,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: TextField(
            controller: stepField.minutesController,
            decoration: const InputDecoration(labelText: 'min'),
            keyboardType: TextInputType.number,
          ),
        ),
        if (showRemove) ...[
          const SizedBox(width: 4),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close),
            tooltip: 'Remove step',
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
