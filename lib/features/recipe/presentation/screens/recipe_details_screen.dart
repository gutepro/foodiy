import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/features/analytics/application/recipe_analytics_service.dart';
import 'package:foodiy/core/widgets/recipe_image.dart';
import 'package:foodiy/features/recipe/domain/recipe.dart';
import 'package:foodiy/features/recipe/domain/recipe_step.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_player_screen.dart';
import 'package:foodiy/features/recipe/application/recipe_translation_service.dart';
import 'package:foodiy/features/playlist/application/cookbook_firestore_service.dart';
import 'package:foodiy/features/playlist/application/personal_playlist_service.dart';
import 'package:foodiy/features/playlist/application/playlist_firestore_service.dart';
import 'package:foodiy/features/recipe/presentation/screens/import_needs_review_screen.dart';
import 'package:foodiy/features/recipe/presentation/screens/import_failed_screen.dart';
import 'package:foodiy/features/playlist/domain/personal_playlist_models.dart';
import 'package:foodiy/core/utils/auth_guards.dart';
import 'package:foodiy/features/shopping/application/shopping_list_service.dart';
import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/shared/widgets/foodiy_logo.dart';
import 'package:foodiy/shared/widgets/foodiy_app_bar.dart';
import 'package:uuid/uuid.dart';
import 'package:foodiy/l10n/app_localizations.dart';

class RecipeDetailsArgs {
  final String id;
  final String title;
  final String imageUrl;
  final String time;
  final String difficulty;
  final String originalLanguageCode;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;
  final bool allowCoverPrompt;

  const RecipeDetailsArgs({
    this.id = '',
    required this.title,
    required this.imageUrl,
    required this.time,
    required this.difficulty,
    this.originalLanguageCode = 'he',
    this.ingredients = const [],
    this.steps = const [],
    this.allowCoverPrompt = false,
  });
}

class RecipeDetailsScreen extends StatefulWidget {
  const RecipeDetailsScreen({super.key, required this.args});

  final RecipeDetailsArgs args;

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen>
    with SingleTickerProviderStateMixin {
  bool _viewRecorded = false;
  Recipe? _recipe;
  bool _isLoading = true;
  bool _navigatedToEditForNeedsReview = false;
  bool _timedOut = false;
  Timer? _statusTimeoutTimer;
  String? _lastImportStatus;
  DateTime? _statusLastChangedAt;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  Recipe? _translatedRecipe;
  bool _showingTranslation = false;
  bool _isTranslating = false;
  bool _isAddingToCookbook = false;
  bool _redirectingToEdit = false;
  bool _isFavoritesCookbook(PersonalPlaylist cb, String currentUid) {
    final lower = cb.name.toLowerCase().trim();
    final favId = PersonalPlaylistService.favoritesCookbookId(currentUid);
    return cb.id == favId ||
        cb.isFavorites ||
        (lower == 'favorite recipes' && cb.ownerId == currentUid);
  }

  List<PersonalPlaylist> _mergeCookbooks({
    required List<PersonalPlaylist> local,
    required List<PersonalPlaylist> remote,
    required String currentUid,
  }) {
    final favId = PersonalPlaylistService.favoritesCookbookId(currentUid);
    final byId = <String, PersonalPlaylist>{};
    int legacyFavs = 0;
    for (final pl in [...remote, ...local]) {
      if (pl.id.isEmpty) continue;
      final isLegacyFav = pl.id != favId &&
          ((pl.name.toLowerCase() == 'favorite recipes') || pl.isFavoritesCookbook);
      if (pl.id == favId) {
        byId[pl.id] = pl.copyWith(id: favId, isFavorites: true);
        continue;
      }
      if (isLegacyFav) {
        legacyFavs++;
        continue;
      }
      byId.putIfAbsent(pl.id, () => pl);
    }
    byId.putIfAbsent(
      favId,
      () => PersonalPlaylist.favoritesPlaceholder(currentUid),
    );
    final mergedList = byId.values.toList();
    PersonalPlaylist? fav;
    final rest = <PersonalPlaylist>[];
    for (final pl in mergedList) {
      if (_isFavoritesCookbook(pl, currentUid) && fav == null) {
        fav = pl.id == favId
            ? pl
            : PersonalPlaylist(
                id: favId,
                name: pl.name,
                imageUrl: pl.imageUrl,
                entries: List<PersonalPlaylistEntry>.from(pl.entries),
                ownerId: pl.ownerId,
                isPublic: pl.isPublic,
                isChefPlaylist: false,
                isFavorites: true,
                categories: pl.categories,
                createdAt: pl.createdAt,
              );
        continue;
      }
      rest.add(pl);
    }
    rest.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    final result = fav != null ? [fav, ...rest] : rest;
    debugPrint(
      '[ATTACH_MERGE] local=${local.length} firestore=${remote.length} afterDedup=${result.length} favoritesSource=${fav != null && byId.containsKey(favId) ? 'merged' : ''} legacyFavoritesFiltered=$legacyFavs',
    );
    return result;
  }
  bool _isFavorited = false;
  bool _handledMissingRecipe = false;

  Recipe _buildRecipeFromArgs(RecipeDetailsArgs args) {
    return Recipe(
      id: args.id,
      originalLanguageCode: args.originalLanguageCode,
      title: args.title,
      imageUrl: args.imageUrl,
      coverImageUrl: args.imageUrl,
      categories: const [],
      steps: args.steps,
      ingredients: args.ingredients,
      tools: const [],
      preCookingNotes: '',
      chefId: '',
      chefName: null,
      chefAvatarUrl: null,
      views: 0,
      playlistAdds: 0,
      isPublic: true,
    );
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    final args = widget.args;
    debugPrint('RecipeDetailsScreen: args.id=${args.id}');
    if (args.id.isEmpty) {
      setState(() {
        _recipe = _buildRecipeFromArgs(args);
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_viewRecorded) return;
        _viewRecorded = true;
      });
      return;
    }

    // Streaming handled in build for non-empty ids.
    setState(() {
      _isLoading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_viewRecorded) return;
      if (args.id.isNotEmpty) {
        RecipeAnalyticsService.instance.recordView(args.id);
      }
      _viewRecorded = true;
    });
  }

  void _updateFavoriteState(String recipeId) {
    final fav =
        PersonalPlaylistService.instance.favoritesPlaylist ??
        PersonalPlaylistService.instance.ensureFavoritesPlaylist();
    final entries = PersonalPlaylistService.instance.getEntries(fav.id);
    _isFavorited = entries.any((e) => e.recipeId == recipeId);
  }

  @override
  void dispose() {
    _statusTimeoutTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  TextDirection _directionFromLanguage(String code) {
    const rtlLanguages = ['he', 'ar', 'fa', 'ur'];
    if (rtlLanguages.contains(code.toLowerCase())) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }

  Widget _buildRecipeView(
    ThemeData theme,
    Recipe recipe, {
    bool showProcessing = false,
    String? translatedFrom,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final safeTitle = recipe.title.isNotEmpty
        ? recipe.title
        : l10n.importedRecipeTitle;
    final ingredients = recipe.ingredients;
    final steps = recipe.steps;
    final tools = recipe.tools;
    final ocrPreview = recipe.ocrRawText ?? '';
    final showOcrDebug = recipe.importStatus == 'needs_review' ||
        ingredients.isEmpty ||
        steps.isEmpty ||
        tools.isEmpty;
    final canEdit =
        recipe.chefId.isNotEmpty &&
        recipe.chefId == FirebaseAuth.instance.currentUser?.uid;
    final isTranslatedView = translatedFrom != null;
    final canTranslate = recipe.originalLanguageCode.toLowerCase() != 'en';
    final hasChef = recipe.chefId.isNotEmpty;

    return Directionality(
      textDirection: _directionFromLanguage(recipe.originalLanguageCode),
      child: Scaffold(
        appBar: FoodiyAppBar(
          title: Text(safeTitle),
          actions: [
            IconButton(
              tooltip: _isFavorited
                  ? l10n.recipeRemoveFromFavorites
                  : l10n.recipeAddToFavorites,
              icon: Icon(
                _isFavorited ? Icons.favorite : Icons.favorite_border,
                color: _isFavorited ? Colors.redAccent : null,
              ),
              onPressed: () => _toggleFavorite(recipe),
            ),
            if (canEdit)
              TextButton.icon(
                onPressed: () async {
                  context.push(AppRoutes.recipeEdit, extra: recipe.id);
                },
                icon: const Icon(Icons.edit, size: 18),
                label: Text(l10n.recipeEditButton),
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                child: RecipeImage(
                  imageUrl: recipe.coverImageUrl?.isNotEmpty == true
                      ? recipe.coverImageUrl!
                      : (recipe.imageUrl ?? ''),
                  height: 220,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              if (recipe.ocrRawText == null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('OCR text missing - please reimport'),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.title, style: theme.textTheme.headlineSmall),
                    if (hasChef) ...[
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () {
                          debugPrint(
                            '[CHEF_NAV] recipeId=${recipe.id} ownerId=${recipe.chefId} ownerName=${recipe.chefName}',
                          );
                          context.push(
                            AppRoutes.chefProfile,
                            extra: recipe.chefId,
                          );
                        },
                        child: Text(
                          (recipe.chefName?.isNotEmpty ?? false)
                              ? recipe.chefName!
                              : l10n.recipeViewChef,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    if (canTranslate)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _isTranslating
                                ? null
                                : () {
                                    if (isTranslatedView) {
                                      setState(() {
                                        _showingTranslation = false;
                                      });
                                    } else {
                                      _translateToEnglish(recipe);
                                    }
                                  },
                            icon: _isTranslating
                                ? SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.primary,
                                    ),
                                  )
                                : const Icon(Icons.translate),
                            label: Text(
                              isTranslatedView
                                  ? l10n.recipeViewOriginal
                                  : l10n.recipeTranslateToEnglish,
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _isAddingToCookbook
                              ? null
                              : () => _showAddToCookbooks(recipe),
                          icon: const Icon(Icons.library_add_outlined),
                          label: Text(l10n.recipeAddToCookbook),
                        ),
                      ),
                    ),
                    if (isTranslatedView) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.recipeTranslatedFrom(
                          translatedFrom.isNotEmpty
                              ? translatedFrom
                              : l10n.recipeOriginalLanguageLabel,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                    if (_isTranslating) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.recipeTranslating,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _MetaChip(
                          icon: Icons.access_time,
                          label: widget.args.time,
                        ),
                        const SizedBox(width: 8),
                        _MetaChip(
                          icon: Icons.bolt_outlined,
                          label: widget.args.difficulty,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (showProcessing) ...[
                      Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(l10n.recipeProcessing),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (showOcrDebug) ...[
                      Text(
                        'OCR text extracted: ${ocrPreview.length} chars',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.recipeOcrPreviewLabel,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        height: 160,
                        child: SingleChildScrollView(
                          child: Text(
                            ocrPreview.length > 2000
                                ? '${ocrPreview.substring(0, 2000)}...'
                                : ocrPreview,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: Text(l10n.recipeStartCooking),
                        onPressed: () {
                          final playerArgs = RecipePlayerArgs(
                            title: recipe.title,
                            imageUrl:
                                recipe.coverImageUrl ?? recipe.imageUrl ?? '',
                            steps: steps.isNotEmpty ? steps : widget.args.steps,
                            languageCode: recipe.originalLanguageCode,
                            recipeId: recipe.id,
                            initialStepIndex: 0,
                          );
                          context.push(
                            AppRoutes.recipePlayer,
                            extra: playerArgs,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.recipeIngredientsTitle, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (ingredients.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add_shopping_cart),
                          label: Text(l10n.recipeAddIngredientsToCart),
                          onPressed: () => _onAddIngredientsToCart(recipe),
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (ingredients.isEmpty)
                      Text(l10n.recipeNoIngredients)
                    else
                      Column(
                        children: ingredients
                            .map(
                              (i) => Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${i.name} ${i.quantity} ${i.unit}'.trim(),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 24),
                    Text(l10n.recipeStepsTitle, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    if (steps.isEmpty)
                      Text(l10n.recipeNoSteps)
                    else
                      Column(
                        children: steps.asMap().entries.map((entry) {
                          final index = entry.key + 1;
                          final step = entry.value;
                          final hasTimer = (step.durationSeconds ?? 0) > 0;
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: theme.colorScheme.primary,
                                  child: Text(
                                    '$index',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        step.text,
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                      if (hasTimer) ...[
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.timer_outlined,
                                              size: 18,
                                              color: theme.colorScheme.primary,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _formatMinutes(
                                                step.durationSeconds!,
                                              ),
                                              style: theme.textTheme.labelMedium
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .primary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 24),
                    Text(l10n.recipeToolsTitle, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    if (tools.isEmpty)
                      Text(l10n.recipeNoTools)
                    else
                      Wrap(
                        spacing: 8,
                        children: tools
                            .map((t) => Chip(label: Text(t.name)))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingScreen(ThemeData theme, Recipe recipe,
      {bool timedOut = false}) {
    final l10n = AppLocalizations.of(context)!;
    final status = recipe.importStatus;
    final importDebug = recipe.importDebug ?? const <String, dynamic>{};
    final debugStage = importDebug['stage'] as String? ?? '';
    final debugErrors = importDebug['errors'] as List<dynamic>? ?? const <dynamic>[];
    bool isOneOf(Set<String> values) => values.contains(status);

    final uploadDone = status != 'uploading';
    final extractingTextDone = isOneOf(
      {'ocr_done', 'parsed', 'needs_review', 'failed', 'ready'},
    );
    final understandingDone = isOneOf(
      {'parsed', 'needs_review', 'failed', 'ready'},
    );
    final finalizingDone = understandingDone;

    final steps = [
      {'label': l10n.recipeImportStepUploadComplete, 'done': uploadDone},
      {'label': l10n.recipeImportStepExtractingText, 'done': extractingTextDone},
      {'label': l10n.recipeImportStepUnderstanding, 'done': understandingDone},
      {'label': l10n.recipeImportStepFinalizing, 'done': finalizingDone},
    ];

    final isFailed = recipe.importStatus == 'failed';
    final showTimeout = timedOut;

    return Scaffold(
      appBar: const FoodiyAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: const SizedBox(
                  width: 120,
                  height: 120,
                  child: FoodiyLogo(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isFailed
                    ? l10n.recipeImportFailedTitle
                    : showTimeout
                        ? l10n.recipeImportTimeoutTitle
                        : l10n.recipeImportProcessingTitle,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              if (showTimeout)
                Column(
                  children: [
                    Text(
                      l10n.recipeImportTimeoutBody,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () => context.go(AppRoutes.home),
                          child: Text(l10n.goHomeButton),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () => context.go(
                            AppRoutes.recipeImportDocument,
                          ),
                          child: Text(l10n.tryAgain),
                        ),
                      ],
                    ),
                  ],
                )
              else if (isFailed)
                Column(
                  children: [
                    Text(
                      recipe.errorMessage ??
                          recipe.importError ??
                          l10n.recipeImportUnknownError,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () => context.go(AppRoutes.home),
                          child: Text(l10n.goHomeButton),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () => context.go(
                            AppRoutes.recipeImportDocument,
                          ),
                          child: Text(l10n.tryAgain),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Column(
                  children: steps
                      .map(
                        (step) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                step['done'] == true
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: step['done'] == true
                                    ? Colors.green
                                    : Colors.grey,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(step['label'] as String),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              if (debugStage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Debug stage: $debugStage'),
                if (debugErrors.isNotEmpty)
                  Text('Debug errors: ${debugErrors.length}'),
              ],
              if (!showTimeout && !isFailed) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: Text(l10n.goHomeButton),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImportFailedScreen(BuildContext context, {Recipe? recipe}) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: FoodiyAppBar(title: Text(l10n.recipeImportFailedScreenTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.recipeImportFailedBody),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Future.microtask(() => context.go(AppRoutes.home));
                },
                child: Text(l10n.goHomeButton),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Future.microtask(() => context.go(AppRoutes.recipeImportDocument));
                },
                child: Text(l10n.tryAgain),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortStack(StackTrace stack) {
    final lines = stack.toString().split('\n');
    final libLines = lines.where((l) => l.contains('/lib/')).toList();
    final picked = libLines.isNotEmpty ? libLines.take(25) : lines.take(25);
    return picked.join('\n');
  }

  Widget _buildNeedsReviewScreen(ThemeData theme, Recipe recipe) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: FoodiyAppBar(title: Text(l10n.recipeImportNeedsReviewTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recipeImportNeedsReviewBody,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (recipe.ocrRawText != null) ...[
              Text(
                'OCR text extracted: ${recipe.ocrRawText!.length} chars',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              Text(l10n.recipeOcrPreviewLabel, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                height: 160,
                child: SingleChildScrollView(
                  child: Text(
                    recipe.ocrRawText!,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.go(AppRoutes.home);
                },
                child: Text(l10n.goHomeButton),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.push(
                    AppRoutes.recipeEdit,
                    extra: RecipeDetailsArgs(
                      id: recipe.id,
                      title: recipe.title,
                      imageUrl: recipe.coverImageUrl ?? recipe.imageUrl ?? '',
                      time: l10n.profileStepsCount(recipe.steps.length),
                      difficulty: '-',
                      originalLanguageCode: recipe.originalLanguageCode,
                      ingredients: recipe.ingredients,
                      steps: recipe.steps,
                    ),
                  );
                },
                child: Text(l10n.recipeEditButton),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.go(AppRoutes.recipeImportDocument);
                },
                child: Text(l10n.tryAgain),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _trackImportStatus(String recipeId, String status) {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
    final now = DateTime.now();
    final isTerminal = status == 'parsed' ||
        status == 'ready' ||
        status == 'needs_review' ||
        status == 'failed';
    if (isTerminal) {
      _statusTimeoutTimer?.cancel();
      _timedOut = false;
    }
    if (status != _lastImportStatus) {
      _statusLastChangedAt = now;
      _lastImportStatus = status;
      _timedOut = false;
      _statusTimeoutTimer?.cancel();
      if (!isTerminal) {
        _statusTimeoutTimer = Timer(const Duration(seconds: 60), () {
          if (!mounted) return;
          if (_lastImportStatus == status) {
            setState(() {
              _timedOut = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.recipeImportTimeoutBody)),
            );
          }
        });
      }
    }
    debugPrint(
      '[ImportProgress] listening path=recipes/$recipeId uid=$uid importStatus=$status lastChange=${_statusLastChangedAt ?? now}',
    );
  }

  Widget _buildRecipeErrorFallback(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: FoodiyAppBar(title: Text(l10n.recipeUnavailableTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.recipeUnavailableBody),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Future.microtask(() => context.go(AppRoutes.home));
                },
                child: Text(l10n.goHomeButton),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Future.microtask(() => context.go(AppRoutes.recipeImportDocument));
                },
                child: Text(l10n.tryAgain),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    debugPrint(
      '[L10N] locale=${Localizations.localeOf(context)} screen=RecipeDetails keys=recipeIngredientsTitle,recipeStepsTitle,recipeToolsTitle',
    );
    final args = widget.args;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (args.id.isEmpty) {
      if (_recipe == null) {
        return _buildRecipeNotFoundView();
      }
      return _buildRecipeView(theme, _recipe!);
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('recipes')
          .doc(args.id)
          .snapshots(),
      builder: (context, snapshot) {
        debugPrint('RecipeDetails stream listening to recipes/${args.id}');
        if (snapshot.hasError) {
          debugPrint('RecipeDetails StreamBuilder error: ${snapshot.error}');
          debugPrint(_shortStack(snapshot.stackTrace ?? StackTrace.current));
          return _buildImportFailedScreen(context);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildRecipeNotFoundView();
        }
        final data = snapshot.data!.data();
        if (data == null) {
          debugPrint('[RecipeDetails] data null for id=${args.id}');
          return _buildRecipeErrorFallback(context);
        }
        data['id'] = snapshot.data!.id;
        Recipe? recipe;
        try {
          recipe = Recipe.fromJson(data, docId: snapshot.data!.id);
        } catch (e, st) {
          debugPrint('[RecipeDetails] parse error for id=${args.id}: $e\n$st');
          return _buildRecipeErrorFallback(context);
        }
        _trackImportStatus(recipe.id, recipe.importStatus);
        debugPrint(
          'RecipeDetails open id=${recipe.id} importStatus=${recipe.importStatus} needsReview=${recipe.status == 'needs_review' || recipe.importStatus == 'needs_review'} titleLen=${recipe.title.length} issuesCount=${recipe.issues.length}',
        );
        if (!_viewRecorded) {
          RecipeAnalyticsService.instance.recordView(recipe.id);
          _viewRecorded = true;
        }
        _updateFavoriteState(recipe.id);
        final status = recipe.importStatus;
        final isFailed = status == 'failed';
        final isNeedsReviewStatus = status == 'needs_review';
        final isParsed = status == 'parsed' || status == 'ready';
        final isProcessing =
            !isFailed && !isNeedsReviewStatus && !isParsed;

        if (_timedOut) {
          return _buildProcessingScreen(theme, recipe, timedOut: true);
        }

        if (isProcessing) {
          return _buildProcessingScreen(theme, recipe);
        }

        final hasContent =
            (recipe.ingredients.isNotEmpty || recipe.steps.isNotEmpty);
        final showFailed =
            isFailed || (!hasContent && status != 'needs_review');

        if (showFailed) {
          try {
            return _buildImportFailedScreen(context, recipe: recipe);
          } catch (e, st) {
            debugPrint('RecipeDetails build crash (failed): $e');
            debugPrint(_shortStack(st));
            return _buildImportFailedScreen(context);
          }
        }

        final needsReviewWithContent =
            (isNeedsReviewStatus ||
                recipe.needsReview ||
                recipe.status == 'needs_review' ||
                recipe.title.trim().isEmpty) &&
            hasContent;

        if (needsReviewWithContent) {
          return ImportNeedsReviewScreen(recipe: recipe);
        }
        final showTranslated =
            _showingTranslation &&
            _translatedRecipe != null &&
            _translatedRecipe!.id == recipe.id;
        final recipeToShow = showTranslated ? _translatedRecipe! : recipe;
        try {
          return _buildRecipeView(
            theme,
            recipeToShow,
            translatedFrom: showTranslated ? recipe.originalLanguageCode : null,
          );
        } catch (e, st) {
          debugPrint('RecipeDetails build crash: $e');
          debugPrint(_shortStack(st));
          return _buildImportFailedScreen(context, recipe: recipeToShow);
        }
      },
    );
  }

  Widget _buildRecipeNotFoundView() {
    _maybePopMissingRecipe();
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: FoodiyAppBar(title: Text(l10n.recipeNotFoundTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(
                l10n.recipeNotFoundBody,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: Text(l10n.goHomeButton),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go(AppRoutes.recipeImportDocument),
                  child: Text(l10n.tryAgain),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _maybePopMissingRecipe() {
    if (_handledMissingRecipe) return;
    _handledMissingRecipe = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).maybePop();
    });
  }

  Future<void> _onAddIngredientsToCart(Recipe recipe) async {
    final l10n = AppLocalizations.of(context)!;
    if (recipe.ingredients.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.recipeNoIngredientsToAdd)));
      return;
    }
    final selections = List<bool>.filled(
      recipe.ingredients.length,
      true,
      growable: false,
    );
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.recipeAddIngredientsToCart),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: recipe.ingredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = recipe.ingredients[index];
                    final quantity = '${ingredient.quantity} ${ingredient.unit}'
                        .trim();
                    return CheckboxListTile(
                      value: selections[index],
                      onChanged: (value) {
                        setState(() {
                          selections[index] = value ?? false;
                        });
                      },
                      title: Text(ingredient.name),
                      subtitle: quantity.isNotEmpty ? Text(quantity) : null,
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.addSelected),
                ),
              ],
            );
          },
        );
      },
    );
    if (result != true) return;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final now = DateTime.now();
    final items = <ShoppingListItem>[];
    final uuid = const Uuid();
    for (var i = 0; i < recipe.ingredients.length; i++) {
      if (!selections[i]) continue;
      final ing = recipe.ingredients[i];
      items.add(
        ShoppingListItem(
          id: uuid.v4(),
          userId: uid,
          name: _cleanIngredientName(ing),
          quantityText: '',
          isChecked: false,
          createdAt: now,
          sourceRecipeId: recipe.id.isNotEmpty ? recipe.id : null,
          sourceRecipeTitle: recipe.title,
          isCustom: false,
        ),
      );
    }
    if (items.isEmpty) return;
    try {
      await ShoppingListService.instance.addItems(items);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recipeAddedToCart(items.length))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recipeAddToCartFailed)),
      );
    }
  }

  Future<void> _translateToEnglish(Recipe recipe) async {
    if (_isTranslating) return;
    setState(() {
      _isTranslating = true;
    });
    final translated = await RecipeTranslationService.instance
        .translateToEnglish(recipe);
    if (!mounted) return;
    if (translated == null) {
      setState(() {
        _isTranslating = false;
        _showingTranslation = false;
      });
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recipeTranslationUnavailable)),
      );
      return;
    }
    setState(() {
      _translatedRecipe = translated;
      _showingTranslation = true;
      _isTranslating = false;
    });
  }

  Future<void> _showAddToCookbooks(Recipe recipe) async {
    final l10n = AppLocalizations.of(context)!;
    if (isGuestUser) {
      await ensureNotGuest(context);
      return;
    }
    if (_isAddingToCookbook) return;
    setState(() => _isAddingToCookbook = true);
    try {
      debugPrint('[ATTACH_FLOW] onTap start for recipe ${recipe.id}');
      final service = PersonalPlaylistService.instance;
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      debugPrint('[ATTACH_FLOW] fetching playlists');
      List<PersonalPlaylist> remote = const [];
      try {
        remote = await PlaylistFirestoreService.instance.fetchUserCookbooks(
          ownerId: uid,
        );
      } catch (e, st) {
        debugPrint('[ATTACH_FLOW][error] fetching remote cookbooks: $e\n$st');
      }
      List<PersonalPlaylist> playlists;
      try {
        playlists = _mergeCookbooks(
          local: service.getCurrentUserPlaylists(),
          remote: remote,
          currentUid: uid,
        );
        debugPrint('[ATTACH_FLOW] playlists merged count=${playlists.length}');
      } catch (e, st) {
        debugPrint('[ATTACH_FLOW][error] merging playlists: $e\n$st');
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.recipeCookbooksLoadFailed)));
        return;
      }
      if (playlists.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.recipeCreateCookbookFirst)),
        );
        return;
      }
      final selections = List<bool>.filled(
        playlists.length,
        false,
        growable: false,
      );
      debugPrint('[ATTACH_FLOW] showing dialog');
      bool? confirmed;
      bool isSaving = false;
      try {
        confirmed =
            await showDialog<bool>(
              context: context,
              barrierDismissible: true,
              builder: (ctx) {
                debugPrint('[ATTACH_FLOW] dialog builder enter');
                return StatefulBuilder(
                  builder: (dialogCtx, setDialogState) {
                    final maxHeight = MediaQuery.of(dialogCtx).size.height * 0.6;
                    return AlertDialog(
                      title: Text(l10n.recipeAddToCookbooksTitle),
                      insetPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                    content: SizedBox(
                      width: MediaQuery.of(dialogCtx).size.width - 32,
                      height: maxHeight,
                      child: Scrollbar(
                        child: ListView.builder(
                          itemCount: playlists.length,
                          itemBuilder: (context, index) {
                            final pl = playlists[index];
                            return CheckboxListTile(
                              value: selections[index],
                              onChanged: (v) {
                                setDialogState(
                                  () => selections[index] = v ?? false,
                                );
                              },
                              title: Text(pl.name),
                            );
                          },
                        ),
                      ),
                    ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(false),
                          child: Text(l10n.cancel),
                        ),
                        ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : () => Navigator.of(dialogCtx).pop(true),
                          child: isSaving
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.addSelected),
                        ),
                      ],
                    );
                  },
                );
              },
            ).timeout(
              const Duration(seconds: 8),
              onTimeout: () {
                debugPrint('[ATTACH_FLOW][timeout] dialog did not close in time');
                return false;
              },
            );
        debugPrint('[ATTACH_FLOW] dialog completed confirmed=$confirmed');
      } catch (e, st) {
        debugPrint('[ATTACH_FLOW][error] dialog: $e\n$st');
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.recipeAttachDialogFailed)));
        return;
      }
      if (confirmed != true) return;
      debugPrint('[ATTACH_FLOW] attaching selections');
      for (var i = 0; i < playlists.length; i++) {
        if (!selections[i]) continue;
        final pl = playlists[i];
        try {
          final isFav = _isFavoritesCookbook(pl, uid);
          final targetId = isFav
              ? PersonalPlaylistService.favoritesCookbookId(uid)
              : pl.id;
          debugPrint('[ADD_TO_COOKBOOK] TAP cookbookId=${pl.id} recipeId=${recipe.id}');
          debugPrint('[ADD_TO_COOKBOOK] selectedCookbookId=${pl.id} resolvedTargetId=$targetId recipeId=${recipe.id} isFavorites=$isFav');
          debugPrint('[ADD_TO_COOKBOOK] START cookbookId=$targetId recipeId=${recipe.id}');
          setState(() => isSaving = true);
          await CookbookFirestoreService.instance
              .addRecipeToCookbook(
                cookbookId: targetId,
                ownerId: pl.ownerId.isNotEmpty ? pl.ownerId : uid,
                title: pl.name,
                isPublic: pl.isPublic,
                coverImageUrl: pl.imageUrl,
                recipeId: recipe.id,
              )
              .timeout(const Duration(seconds: 10));
        } catch (e, st) {
          debugPrint('[ATTACH_FLOW][error] write playlist=${pl.id}: $e\n$st');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.recipeAddToCookbookFailed('$e')),
              ),
            );
          }
        } finally {
          setState(() => isSaving = false);
        }
      }
      debugPrint(
        '[ATTACH_DONE] recipeId=${recipe.id} cookbooks=${[
          for (var i = 0; i < playlists.length; i++)
            if (selections[i])
              ( _isFavoritesCookbook(playlists[i], uid)
                  ? PersonalPlaylistService.favoritesCookbookId(uid)
                  : playlists[i].id)
        ].join(',')} triggeringRefresh=true',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recipeAddedToCookbooks)),
      );
      if (playlists.any((p) => _isFavoritesCookbook(p, uid))) {
        setState(() {
          _isFavorited = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingToCookbook = false);
      } else {
        _isAddingToCookbook = false;
      }
    }
  }

  void _toggleFavorite(Recipe recipe) {
    if (isGuestUser) {
      ensureNotGuest(context);
      return;
    }
    final service = PersonalPlaylistService.instance;
    final fav = service.favoritesPlaylist ?? service.ensureFavoritesPlaylist();
    final isCurrentlyFav = _isFavorited;
    if (isCurrentlyFav) {
      service.removeEntry(fav.id, recipe.id);
    } else {
      service.addEntry(
        fav.id,
        PersonalPlaylistEntry(
          recipeId: recipe.id,
          title: recipe.title,
          imageUrl: recipe.coverImageUrl ?? recipe.imageUrl ?? '',
          time: AppLocalizations.of(context)!.profileStepsCount(
            recipe.steps.length,
          ),
          difficulty: AppLocalizations.of(context)!.recipeDifficultyMedium,
        ),
      );
    }
    setState(() {
      _isFavorited = !isCurrentlyFav;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorited
              ? AppLocalizations.of(context)!.recipeAddedToFavorites
              : AppLocalizations.of(context)!.recipeRemovedFromFavorites,
        ),
      ),
    );
  }

  String _formatMinutes(int seconds) {
    if (seconds <= 0) return '';
    final minutes = (seconds / 60).ceil();
    if (minutes < 60) {
      return AppLocalizations.of(context)!.durationMinutes(minutes);
    }
    final hours = minutes ~/ 60;
    final remMinutes = minutes % 60;
    if (remMinutes == 0) {
      return AppLocalizations.of(context)!.durationHours(hours);
    }
    return AppLocalizations.of(context)!.durationHoursMinutes(hours, remMinutes);
  }

  String _cleanIngredientName(RecipeIngredient ingredient) {
    final raw = ingredient.name.trim();
    if (raw.isEmpty) return raw;

    // Take only the portion before commas to drop preparation notes like "chopped".
    final base = raw.split(',').first;

    // Strip leading quantities and units (numbers, fractions, common units in EN/HE).
    final cleaned = base
        .replaceFirst(
          RegExp(
            r'^([0-9]+[\\/.,]?[0-9]*|\d+|[¼½¾⅐⅑⅒⅓⅔⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞])\s*'
            r'(cup|cups|tbsps?|tbsp|tablespoons?|tsp|teaspoons?|kg|g|gram|grams|ml|l|liter|liters|ounce|ounces|oz|lb|lbs|'
            r'גרם|ק\"ג|מ\"ל|כף|כפות|כפית|כפיות|כוס|כוסות|שקית|חבילה|יחידה|יחידות)?\s*',
            caseSensitive: false,
          ),
          '',
        )
        .replaceFirst(RegExp(r'^of\s+', caseSensitive: false), '')
        .trim();

    if (cleaned.isEmpty) return raw;
    // Capitalize first letter for readability.
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 16), label: Text(label));
  }
}
