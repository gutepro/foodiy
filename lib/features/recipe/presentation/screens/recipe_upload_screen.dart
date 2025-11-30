import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/features/recipe/domain/recipe.dart';
import 'package:foodiy/features/recipe/domain/recipe_step.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_player_screen.dart';
import 'package:foodiy/router/app_routes.dart';

class RecipeUploadScreen extends StatefulWidget {
  const RecipeUploadScreen({super.key});

  @override
  State<RecipeUploadScreen> createState() => _RecipeUploadScreenState();
}

class _RecipeUploadScreenState extends State<RecipeUploadScreen> {
  final _titleController = TextEditingController();
  final _imageController = TextEditingController();
  final _preNotesController = TextEditingController();

  final List<TextEditingController> _ingredientNameControllers = [];
  final List<TextEditingController> _ingredientQuantityControllers = [];
  final List<TextEditingController> _ingredientUnitControllers = [];
  final List<TextEditingController> _toolControllers = [];

  final List<_StepField> _steps = [
    _StepField(),
  ];

  @override
  void initState() {
    super.initState();
    _addIngredientRow();
    _addToolRow();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageController.dispose();
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
    setState(() {
      final removed = _steps.removeAt(index);
      removed.dispose();
    });
  }

  List<RecipeStep> _buildStepsFromForm() {
    final steps = <RecipeStep>[];
    for (final step in _steps) {
      final text = step.textController.text.trim();
      final minutesStr = step.minutesController.text.trim();
      if (text.isEmpty) continue;
      final minutes = int.tryParse(minutesStr) ?? 0;
      final durationSeconds = minutes > 0 ? minutes * 60 : null;
      steps.add(
        RecipeStep(
          text: text,
          durationSeconds: durationSeconds,
        ),
      );
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
      result.add(
        RecipeIngredient(
          name: name,
          quantity: qty,
          unit: unit,
        ),
      );
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

  void _previewInPlayer() {
    final steps = _buildStepsFromForm();
    final languageCode = Localizations.localeOf(context).languageCode;

    final args = RecipePlayerArgs(
      title: _titleController.text.trim().isEmpty
          ? 'Untitled recipe'
          : _titleController.text.trim(),
      imageUrl: _imageController.text.trim().isEmpty
          ? 'https://via.placeholder.com/900x600'
          : _imageController.text.trim(),
      steps: steps,
      languageCode: languageCode,
    );

    context.push(AppRoutes.recipePlayer, extra: args);
  }

  void _onSavePressed() {
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

    if (ingredients.isEmpty) {
      _showMessage('Consider adding ingredients');
    }

    final recipe = Recipe(
      id: 'temp-id',
      originalLanguageCode: originalLanguageCode,
      title: title,
      imageUrl: _imageController.text.trim().isEmpty
          ? 'https://via.placeholder.com/900x600'
          : _imageController.text.trim(),
      steps: steps,
      ingredients: ingredients,
      tools: tools,
      preCookingNotes: preNotes,
    );

    // TODO: Save recipe (with ingredients, tools and preCookingNotes) to Firestore.
    _showMessage('Recipe saved (mock): ${recipe.title}');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create recipe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
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
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Recipe title',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _imageController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL (temporary)',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Ingredients', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Column(
                      children: List.generate(_ingredientNameControllers.length, (index) {
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
                      }),
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
                    Text('Tools', style: theme.textTheme.titleMedium),
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
                                onPressed:
                                    _toolControllers.length > 1 ? () => _removeToolRow(index) : null,
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
                    Text('Preparation before cooking', style: theme.textTheme.titleMedium),
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
                    Text(
                      'Steps',
                      style: theme.textTheme.titleMedium,
                    ),
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
                  onPressed: _onSavePressed,
                  child: const Text('Save recipe'),
                ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: stepField.textController,
            decoration: const InputDecoration(
              labelText: 'Step',
            ),
            maxLines: null,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: TextField(
            controller: stepField.minutesController,
            decoration: const InputDecoration(
              labelText: 'min',
            ),
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
