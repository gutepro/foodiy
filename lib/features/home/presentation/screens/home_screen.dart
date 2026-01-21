import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/core/models/user_type.dart';
import 'package:foodiy/core/services/access_control_service.dart';
import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/core/widgets/recipe_image.dart';
import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/features/playlist/application/cookbook_firestore_service.dart';
import 'package:foodiy/features/playlist/application/playlist_firestore_service.dart';
import 'package:foodiy/features/playlist/domain/personal_playlist_models.dart';
import 'package:foodiy/features/playlist/presentation/screens/personal_playlist_details_screen.dart';
import 'package:foodiy/shared/widgets/foodiy_logo.dart';
import 'package:foodiy/shared/widgets/auto_direction_text.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_details_screen.dart';
import 'package:foodiy/features/recipe/domain/recipe.dart';
import 'package:foodiy/shared/services/ads_service.dart';
import 'package:foodiy/shared/widgets/ad_placeholder.dart';
import 'package:foodiy/shared/widgets/sponsored_banner.dart';
import 'package:foodiy/features/recipe/application/recipe_player_session_service.dart';
import 'package:foodiy/features/recipe/application/recipe_firestore_service.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_player_screen.dart';
import 'package:foodiy/shared/widgets/banner_ad_container.dart';
import 'package:foodiy/core/utils/auth_guards.dart';
import 'package:foodiy/shared/widgets/foodiy_home_logo_button.dart';
import 'package:foodiy/shared/widgets/foodiy_app_bar.dart';
import 'package:foodiy/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _CookbookTile extends StatelessWidget {
  const _CookbookTile({
    required this.playlist,
    required this.entries,
    required this.recipeCount,
    required this.onOpen,
  });

  final PersonalPlaylist playlist;
  final List<PersonalPlaylistEntry> entries;
  final int recipeCount;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final isFavorite = playlist.name.toLowerCase() == 'favorite recipes';
    // Build up to 4 thumbnail urls from playlist entries
    final thumbUrls = entries
        .map((e) => e.imageUrl)
        .where((url) => url.isNotEmpty)
        .take(4)
        .toList();
    if (thumbUrls.isEmpty && playlist.imageUrl.isNotEmpty) {
      thumbUrls.add(playlist.imageUrl);
    }
    final card = Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFavorite)
            Container(
              height: 120,
              color: Colors.pink.shade100,
              alignment: Alignment.center,
              child: const Icon(Icons.favorite, color: Colors.pink, size: 36),
            )
          else
            _PlaylistCoverCollage(imageUrls: thumbUrls, height: 120),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              playlist.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    return InkWell(onTap: onOpen, child: card);
  }
}

class _RecipeTile extends StatelessWidget {
  const _RecipeTile({
    required this.recipe,
    required this.accentColor,
    required this.darkColor,
    required this.localeCode,
    this.onDelete,
  });

  final Recipe recipe;
  final Color accentColor;
  final Color darkColor;
  final String localeCode;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    debugPrint(
      'RecipeTile: id=${recipe.id}, imageUrl=${recipe.imageUrl}, coverImageUrl=${recipe.coverImageUrl}',
    );
    final safeTitle = recipe.title.isNotEmpty
        ? recipe.title
        : AppLocalizations.of(context)!.untitledRecipe;
    final safeImage = recipe.coverImageUrl ?? recipe.imageUrl ?? '';
    return InkWell(
      onTap: () {
        context.push(
          AppRoutes.recipeDetails,
          extra: RecipeDetailsArgs(
            id: recipe.id,
            title: safeTitle,
            imageUrl: safeImage,
            time: l10n.profileStepsCount(recipe.steps.length),
            difficulty: '-',
            originalLanguageCode: localeCode,
            ingredients: const [],
            steps: const [],
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: RecipeImage(
                    imageUrl: safeImage,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        safeTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: darkColor,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (onDelete != null)
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: Colors.black54,
                  onPressed: onDelete,
                  tooltip: AppLocalizations.of(context)!.homeDeleteRecipeTitle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InlineErrorCard extends StatelessWidget {
  const _InlineErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeLoadErrorTitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.red.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.red.shade700),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.tryAgain),
          ),
        ],
      ),
    );
  }
}

class _RecipesLoadingSkeleton extends StatelessWidget {
  const _RecipesLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                color: Colors.grey.shade200,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  height: 14,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  height: 12,
                  width: 80,
                  color: Colors.grey.shade200,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  PlayerSession? _resumeSession;
  Recipe? _resumeRecipe;
  int _homeReloadToken = 0;
  bool _adsLogged = false;
  bool _openingCreateRecipe = false;

  void _logNav(String to, String reason) {
    debugPrint('[NAV] from=HomeScreen to=$to reason=$reason');
  }

  void _showCreateRecipeError(BuildContext context, Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unable to open Create recipe: $error'),
      ),
    );
  }

  Future<void> _handleCreateRecipeTap() async {
    if (_openingCreateRecipe) return;
    setState(() => _openingCreateRecipe = true);
    debugPrint('[CREATE_RECIPE_TAP] start');
    try {
      final canProceed = await ensureNotGuest(context);
      if (!canProceed) return;
      debugPrint('[CREATE_RECIPE_TAP] before_route');
      _logNav(AppRoutes.recipeCreate, 'tap:create_manual');
      await context.push(AppRoutes.recipeCreate);
      debugPrint('[CREATE_RECIPE_TAP] after_route');
    } catch (e, st) {
      debugPrint('[CREATE_RECIPE_TAP] error=$e\n$st');
      if (mounted) {
        _showCreateRecipeError(context, e);
        context.go(AppRoutes.home);
      }
    } finally {
      if (mounted) {
        setState(() => _openingCreateRecipe = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadResumeSession();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    debugPrint('[HOME] build start');
    debugPrint(
      '[L10N] locale=${Localizations.localeOf(context)} screen=Home keys=homeGreetingChef,homeGreetingUser,homeUploadRecipe',
    );
    const darkGreen = Color(0xFF1B4332);
    const warmOrange = Color(0xFFEF8354);
    try {
      ErrorWidget.builder = (details) {
        debugPrint(
          'Home ErrorWidget caught: ${details.exceptionAsString()}\n${details.stack}',
        );
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _HomeFallback(
                greetingName: 'Chef',
                isChef: false,
                onUpload: _openImportDocument,
                onManualCreate: null,
                onRetry: _triggerHomeReload,
                onBackToHome: () => context.go(AppRoutes.home),
              ),
            ),
          ),
        );
      };
      final localeCode = Localizations.localeOf(context).languageCode;
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final profile = CurrentUserService.instance.currentProfile;
      final userType = profile?.userType ?? UserType.freeUser;
      final access = AccessControlService.instance;
      final isChef = access.isChef(userType);
      final isFreeChef = userType == UserType.freeChef;
      final canUpload = isChef;
      if (!_adsLogged) {
        debugPrint(
          '[ADS_TIER] screen=Home uid=$uid tier=$userType adsEnabled=${AdsService.adsEnabled(userType)}',
        );
        _adsLogged = true;
      }
      final displayName = (profile?.displayName ?? '').trim();
      final greetingName = displayName.isNotEmpty
          ? displayName.split(' ').first
          : l10n.homeChefPlaceholder;
      debugPrint('[Home] build normal branch reloadToken=$_homeReloadToken uid=$uid');

      final showAds = AdsService.adsEnabled(userType);
      return Scaffold(
        bottomNavigationBar: BannerAdContainer(showAds: showAds),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 240),
                        child: const FoodiyHomeLogoButton(height: 56, width: 56),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        _logNav(AppRoutes.shoppingList, 'tap:shopping');
                        context.push(AppRoutes.shoppingList);
                      },
                      icon: const Icon(Icons.shopping_cart_outlined),
                      tooltip: l10n.homeShoppingListTooltip,
                    ),
                    IconButton(
                      onPressed: () {
                        _logNav(AppRoutes.search, 'tap:search');
                        context.push(AppRoutes.search);
                      },
                      icon: const Icon(Icons.search),
                      tooltip: l10n.homeSearchTooltip,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Builder(
                  builder: (context) {
                    try {
                      debugPrint('[Home] rendering main list reloadToken=$_homeReloadToken');
                      debugPrint('[HOME] before recipes');
                      final recipesSection = _MyRecipesSection(
                        uid: uid,
                        accentColor: warmOrange,
                        darkColor: darkGreen,
                        localeCode: localeCode,
                        reloadToken: _homeReloadToken,
                        canUpload: canUpload,
                        onUpgradeToChef: () =>
                            context.push(AppRoutes.selectPackage),
                        onUploadFromDoc: canUpload
                            ? _openImportDocument
                            : null,
                        canCreateManually: canUpload,
                        onManualCreate: canUpload
                            ? () => _handleCreateRecipeTap()
                            : null,
                        onSeeAll: () => _openMyRecipes(
                          uid: uid,
                          accentColor: warmOrange,
                          darkColor: darkGreen,
                          localeCode: localeCode,
                        ),
                      );
                      debugPrint('[HOME] after recipes');
                      debugPrint('[HOME] before chefs');
                      const chefsSection = SizedBox.shrink();
                      debugPrint('[HOME] after chefs');
                      debugPrint('[HOME] before cookbooks');
                      final cookbooksSection = _MyPlaylistsSection(
                        uid: uid,
                        reloadToken: _homeReloadToken,
                        onSeeAll: _openMyPlaylists,
                        onOpenPlaylist: _openPlaylistDetails,
                        onRetry: _triggerHomeReload,
                      );
                      debugPrint('[HOME] after cookbooks');
                      return ListView(
                        padding: EdgeInsets.zero,
                        children: [
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoDirectionText(
                                      isChef
                                          ? l10n.homeGreetingChef(greetingName)
                                          : l10n.homeGreetingUser(greetingName),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    AutoDirectionText(
                                      isChef
                                          ? l10n.homeUploadPromptChef
                                          : l10n.homeUploadPromptUser,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 8,
                                      children: [
                                        if (canUpload) ...[
                                          ElevatedButton.icon(
                                            onPressed: () async {
                                              if (!await ensureNotGuest(context)) return;
                                              _logNav(AppRoutes.recipeImportDocument, 'tap:upload');
                                              _openImportDocument();
                                            },
                                            icon: const Icon(
                                              Icons.cloud_upload_outlined,
                                            ),
                                            label: AutoDirectionText(
                                              l10n.homeUploadRecipe,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await _handleCreateRecipeTap();
                                            },
                                            child: AutoDirectionText(
                                              l10n.homeCreateManual,
                                            ),
                                          ),
                                          if (isFreeChef)
                                            AutoDirectionText(
                                              l10n.homeFreeChefLimit(10),
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                        ] else ...[
                                          OutlinedButton.icon(
                                            onPressed: () {
                                              _logNav(AppRoutes.selectPackage, 'tap:upgrade');
                                              context.push(
                                                AppRoutes.selectPackage,
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.workspace_premium,
                                            ),
                                            label: AutoDirectionText(
                                              l10n.homeUpgradeToChef,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_shouldShowAds(userType)) ...[
                              const SizedBox(height: 16),
                              AdPlaceholder(
                                label: 'Ad slot - Home banner',
                                logTag: 'ADS_HOME',
                              ),
                            ],
                            const SizedBox(height: 16),
                            if (_resumeSession != null && _resumeRecipe != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _ResumeCookingCard(
                                  recipe: _resumeRecipe!,
                                  session: _resumeSession!,
                                  onResume: _resumeCooking,
                                  onDismiss: _dismissResume,
                                ),
                              ),
                            chefsSection,
                            recipesSection,
                            const SizedBox(height: 24),
                            if (_shouldShowAds(userType))
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: SponsoredBanner(),
                              ),
                            cookbooksSection,
                          ],
                        );
                    } catch (e, st) {
                        debugPrint(
                          'HomeScreen fallback UI because of error: $e\n$st',
                        );
                        debugPrint('[Home] rendering fallback due to exception');
                        return _HomeFallback(
                          greetingName: greetingName,
                          isChef: isChef,
                          onUpload: _openImportDocument,
                          onManualCreate: isChef
                              ? () => _handleCreateRecipeTap()
                              : null,
                          onRetry: _triggerHomeReload,
                          onBackToHome: () => context.go(AppRoutes.home),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('HomeScreen top-level error: $e\n$st');
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _HomeFallback(
              greetingName: 'Chef',
              isChef: false,
              onUpload: _openImportDocument,
              onManualCreate: () => _handleCreateRecipeTap(),
              onRetry: _triggerHomeReload,
              onBackToHome: () => context.go(AppRoutes.home),
            ),
          ),
        ),
      );
    }
  }

  void _triggerHomeReload() {
    setState(() {
      _homeReloadToken++;
    });
  }

  Future<void> _openMyRecipes({
    required String uid,
    required Color accentColor,
    required Color darkColor,
    required String localeCode,
  }) async {
    if (uid.isEmpty) return;
    _logNav('UserRecipesScreen', 'tap:see_all_recipes');
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _UserRecipesScreen(
          uid: uid,
          accentColor: accentColor,
          darkColor: darkColor,
          localeCode: localeCode,
        ),
      ),
    );
  }

  Future<void> _openMyPlaylists() async {
    _logNav(AppRoutes.myPlaylists, 'tap:see_all_playlists');
    await context.push(AppRoutes.myPlaylists);
    setState(() {});
  }

  Future<void> _openImportDocument() async {
    final userType = CurrentUserService.instance.currentUserType;
    if (!AccessControlService.instance.isChef(userType)) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.homeUploadsForChefsSnackbar)),
        );
      }
      return;
    }
    await context.push(AppRoutes.recipeImportDocument);
    setState(() {});
  }

  Future<void> _openPlaylistDetails(String playlistId) async {
    _logNav(AppRoutes.myPlaylistsDetails, 'tap:playlist $playlistId');
    await context.push(
      AppRoutes.myPlaylistsDetails,
      extra: PersonalPlaylistDetailsArgs(playlistId: playlistId),
    );
    setState(() {});
  }

  Future<void> _loadResumeSession() async {
    final session = await RecipePlayerSessionService.instance
        .loadValidSession();
    if (!mounted) return;
    if (session == null) {
      setState(() {
        _resumeSession = null;
        _resumeRecipe = null;
      });
      return;
    }
    final recipe = await RecipeFirestoreService.instance.getRecipeById(
      session.recipeId,
    );
    if (!mounted) return;
    if (recipe == null || recipe.steps.isEmpty) {
      await RecipePlayerSessionService.instance.clearSession();
      setState(() {
        _resumeSession = null;
        _resumeRecipe = null;
      });
      return;
    }
    final clampedIndex = session.stepIndex.clamp(0, recipe.steps.length - 1);
    setState(() {
      _resumeSession = session.copyWith(stepIndex: clampedIndex);
      _resumeRecipe = recipe;
    });
  }

  Future<void> _resumeCooking() async {
    final session = _resumeSession;
    final recipe = _resumeRecipe;
    if (session == null || recipe == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    int? pausedMs = session.pausedRemainingMs;
    if (session.timerEndEpochMs != null && session.isPlaying) {
      final remaining = session.timerEndEpochMs! - now;
      pausedMs = remaining > 0 ? remaining : 0;
    }
    final args = RecipePlayerArgs(
      title: recipe.title,
      imageUrl: recipe.coverImageUrl ?? recipe.imageUrl ?? '',
      steps: recipe.steps,
      languageCode: recipe.originalLanguageCode,
      recipeId: recipe.id,
      initialStepIndex: session.stepIndex,
      initialIsPlaying: session.isPlaying,
      initialTimerEndEpochMs: session.timerEndEpochMs,
      initialPausedRemainingMs: pausedMs,
    );
    await context.push(AppRoutes.recipePlayer, extra: args);
    if (!mounted) return;
    await _loadResumeSession();
  }

  Future<void> _dismissResume() async {
    await RecipePlayerSessionService.instance.clearSession();
    setState(() {
      _resumeSession = null;
      _resumeRecipe = null;
    });
  }

  bool _shouldShowAds(UserType userType) {
    return AdsService.adsEnabled(userType);
  }
}

class _HomeFallback extends StatelessWidget {
  const _HomeFallback({
    required this.greetingName,
    required this.isChef,
    required this.onUpload,
    required this.onManualCreate,
    required this.onRetry,
    required this.onBackToHome,
  });

  final String greetingName;
  final bool isChef;
  final VoidCallback onUpload;
  final VoidCallback? onManualCreate;
  final VoidCallback onRetry;
  final VoidCallback onBackToHome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoDirectionText(
                l10n.homeGreetingUser(greetingName),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              AutoDirectionText(
                l10n.homeUploadPromptChef,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: onUpload,
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: AutoDirectionText(l10n.homeUploadRecipe),
                  ),
                  if (isChef && onManualCreate != null)
                    TextButton(
                      onPressed: onManualCreate,
                      child: AutoDirectionText(l10n.homeCreateManual),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        HomeLoadErrorCard(
          onBackToHome: () => Future.microtask(onBackToHome),
          onTryAgain: () => Future.microtask(onRetry),
        ),
      ],
    );
  }
}

class _ResumeCookingCard extends StatelessWidget {
  const _ResumeCookingCard({
    required this.recipe,
    required this.session,
    required this.onResume,
    required this.onDismiss,
  });

  final Recipe recipe;
  final PlayerSession session;
  final VoidCallback onResume;
  final VoidCallback onDismiss;

  String _formatRemaining() {
    final now = DateTime.now().millisecondsSinceEpoch;
    int remainingMs = 0;
    if (session.isPlaying && session.timerEndEpochMs != null) {
      remainingMs = session.timerEndEpochMs! - now;
    } else {
      remainingMs = session.pausedRemainingMs ?? 0;
    }
    if (remainingMs < 0) remainingMs = 0;
    final minutes = Duration(milliseconds: remainingMs).inMinutes;
    final seconds = (Duration(milliseconds: remainingMs).inSeconds) % 60;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(minutes)}:${two(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final stepNumber = session.stepIndex + 1;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.homeResumeCookingTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: onDismiss,
                  child: Text(l10n.homeNotNow),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              recipe.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.homeStepRemaining(stepNumber, _formatRemaining()),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onResume,
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.homeResumeButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyPlaylistsSection extends StatefulWidget {
  const _MyPlaylistsSection({
    required this.uid,
    required this.reloadToken,
    required this.onSeeAll,
    required this.onOpenPlaylist,
    required this.onRetry,
  });

  final String uid;
  final int reloadToken;
  final VoidCallback onSeeAll;
  final void Function(String playlistId) onOpenPlaylist;
  final VoidCallback onRetry;

  @override
  State<_MyPlaylistsSection> createState() => _MyPlaylistsSectionState();
}

class _MyPlaylistsSectionState extends State<_MyPlaylistsSection> {
  final _remote = PlaylistFirestoreService.instance;
  Future<List<PersonalPlaylist>>? _cookbooksFuture;

  @override
  void initState() {
    super.initState();
    _cookbooksFuture = _loadCookbooks();
  }

  @override
  void didUpdateWidget(covariant _MyPlaylistsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid ||
        oldWidget.reloadToken != widget.reloadToken) {
      _cookbooksFuture = _loadCookbooks();
    }
  }

  Future<List<PersonalPlaylist>> _loadCookbooks() async {
    final uid = widget.uid;
    if (uid.isEmpty) return const [];
    await CookbookFirestoreService.instance.ensureFavoritesCookbook(
      ownerId: uid,
    );
    return _remote.fetchUserCookbooks(ownerId: uid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    Widget content;
    if (widget.uid.isEmpty) {
      content = Text(l10n.homeNoCookbooks);
    } else {
      content = FutureBuilder<List<PersonalPlaylist>>(
        future: _cookbooksFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('[Home MyPlaylists] error: ${snapshot.error}');
            return HomeLoadErrorCard(
              onBackToHome: () => context.go(AppRoutes.home),
              onTryAgain: widget.onRetry,
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final allItems = snapshot.data ?? const <PersonalPlaylist>[];
          assert(() {
            debugPrint(
              '[HOME_COOKBOOKS] uid=${widget.uid} receivedCount=${allItems.length}',
            );
            return true;
          }());
          final items = allItems.take(4).toList();
          if (items.isEmpty) {
            return Text(l10n.homeNoCookbooks);
          }
          return SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final playlist = items[index];
                return SizedBox(
                  width: 200,
                  child: _CookbookTile(
                    playlist: playlist,
                    entries: playlist.entries,
                    recipeCount: playlist.recipeIds.length,
                    onOpen: () => widget.onOpenPlaylist(playlist.id),
                  ),
                );
              },
            ),
          );
        },
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AutoDirectionText(
                l10n.homeMyCookbooks,
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: widget.onSeeAll,
                child: AutoDirectionText(l10n.homeSeeAll),
              ),
            ],
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }
}

class _MyRecipesSection extends StatefulWidget {
  const _MyRecipesSection({
    required this.uid,
    required this.accentColor,
    required this.darkColor,
    required this.localeCode,
    this.reloadToken = 0,
    this.canUpload = false,
    this.canCreateManually = false,
    this.onUploadFromDoc,
    this.onUpgradeToChef,
    this.onManualCreate,
    required this.onSeeAll,
  });

  final String uid;
  final Color accentColor;
  final Color darkColor;
  final String localeCode;
  final int reloadToken;
  final bool canUpload;
  final bool canCreateManually;
  final VoidCallback? onUploadFromDoc;
  final VoidCallback? onUpgradeToChef;
  final VoidCallback? onManualCreate;
  final VoidCallback onSeeAll;

  @override
  State<_MyRecipesSection> createState() => _MyRecipesSectionState();
}

class _MyRecipesSectionState extends State<_MyRecipesSection> {
  StreamSubscription<List<Recipe>>? _sub;
  List<Recipe>? _recipes;
  String? _error;
  bool _timedOut = false;
  bool _loggedError = false;
  int _retryToken = 0;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant _MyRecipesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid || oldWidget.reloadToken != widget.reloadToken) {
      _retryToken++;
      _subscribe();
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  void _subscribe() {
    _timeoutTimer?.cancel();
    _sub?.cancel();
    debugPrint('[Home MyRecipes] subscribing for uid=${widget.uid}');
    setState(() {
      _recipes = null;
      _error = null;
      _timedOut = false;
    });
    _timeoutTimer = Timer(const Duration(seconds: 8), () {
      if (!mounted) return;
      debugPrint('[Home MyRecipes] load timed out for uid=${widget.uid}');
      setState(() {
        _timedOut = true;
        _error ??= null;
      });
    });

    _sub = RecipeFirestoreService.instance
        .watchUserRecipes(uid: widget.uid, limit: 12)
        .listen(
      (recipes) {
        _timeoutTimer?.cancel();
        final sanitized = <Recipe>[];
        var skipped = 0;
        for (final r in recipes) {
          try {
            sanitized.add(
              r.copyWith(
                title: r.title,
                coverImageUrl: r.coverImageUrl?.isNotEmpty == true
                    ? r.coverImageUrl
                    : r.imageUrl ?? '',
                imageUrl: r.coverImageUrl?.isNotEmpty == true
                    ? r.coverImageUrl
                    : r.imageUrl ?? '',
                createdAt: r.createdAt ??
                    r.updatedAt ??
                    DateTime.fromMillisecondsSinceEpoch(0),
                updatedAt: r.updatedAt ??
                    r.createdAt ??
                    DateTime.fromMillisecondsSinceEpoch(0),
              ),
            );
          } catch (_) {
            skipped += 1;
          }
        }
        debugPrint(
          '[Home MyRecipes] stream received total=${recipes.length} sanitized=${sanitized.length} skipped=$skipped uid=${widget.uid}',
        );
        if (!mounted) return;
        setState(() {
          _error = null;
          _timedOut = false;
          _recipes = sanitized;
        });
      },
      onError: (err, stack) {
        _timeoutTimer?.cancel();
        if (!_loggedError) {
          debugPrint('[Home MyRecipes] stream error: $err');
          debugPrint(stack.toString());
          _loggedError = true;
        }
        if (!mounted) return;
        setState(() {
          _error = err.toString();
          _recipes = _recipes ?? [];
        });
      },
    );
  }

  void _retry() {
    setState(() {
      _retryToken++;
    });
    _subscribe();
  }

  Future<void> _deleteRecipeDirectly(BuildContext context, Recipe recipe) async {
    try {
      await RecipeFirestoreService.instance.deleteRecipe(recipe.id);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.homeRecipeDeleted)),
      );
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.homeDeleteRecipeFailed('$e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentUserType =
        CurrentUserService.instance.currentProfile?.userType ?? UserType.freeUser;
    final canUpload = widget.canUpload ||
        AccessControlService.instance.isChef(currentUserType);
    final recipes = _recipes;
    final isLoading = recipes == null && _error == null && !_timedOut;
    final hasError = _error != null || _timedOut;
    final showEmpty = recipes != null && recipes.isEmpty && !hasError;

    return Container(
      key: ValueKey('my-recipes-${widget.uid}-${_retryToken}-${widget.reloadToken}'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AutoDirectionText(
                l10n.myRecipesTitle,
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: widget.onSeeAll,
                child: AutoDirectionText(l10n.homeSeeAll),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: widget.onUploadFromDoc,
              icon: const Icon(Icons.cloud_upload_outlined),
              label: Text(l10n.homeUploadRecipe),
            ),
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const _RecipesLoadingSkeleton()
          else if (hasError)
            _InlineErrorCard(
              message: _error ??
                  (_timedOut
                      ? l10n.homeLoadingRecipesTimeout
                      : l10n.homeLoadErrorTitle),
              onRetry: _retry,
            )
          else if (showEmpty)
            _EmptyPersonalCard(
              title: canUpload ? l10n.noRecipesYet : l10n.homeUploadsForChefsTitle,
              body: canUpload
                  ? l10n.homeUploadDocBody
                  : l10n.homeUploadsForChefsBody,
              primaryLabel: canUpload ? null : l10n.homeBecomeChefButton,
              onPrimary: canUpload ? null : widget.onUpgradeToChef,
              secondaryLabel: canUpload ? l10n.homeUploadRecipe : null,
              onSecondary: canUpload ? widget.onUploadFromDoc : null,
            )
          else if (recipes != null)
            GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recipes.length.clamp(0, 4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return _RecipeTile(
                  recipe: recipe,
                  accentColor: widget.accentColor,
                  darkColor: widget.darkColor,
                  localeCode: widget.localeCode,
                  onDelete: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n.homeDeleteRecipeTitle),
                        content: Text(
                          l10n.homeDeleteRecipeMessage(recipe.title),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text(l10n.homeCancel),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: Text(l10n.homeDelete),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await _deleteRecipeDirectly(context, recipe);
                    }
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PlaylistCoverCollage extends StatelessWidget {
  const _PlaylistCoverCollage({required this.imageUrls, this.height = 120});

  final List<String> imageUrls;
  final double height;

  @override
  Widget build(BuildContext context) {
    final urls = imageUrls.take(4).toList();
    if (urls.isEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined, color: Colors.grey),
      );
    }
    return SizedBox(
      height: height,
      child: Row(
        children: urls.map((url) {
          return Expanded(
            child: RecipeImage(
              imageUrl: url,
              height: height,
              fit: BoxFit.cover,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class HomeLoadErrorCard extends StatelessWidget {
  const HomeLoadErrorCard({
    required this.onBackToHome,
    required this.onTryAgain,
    Key? key,
  }) : super(key: key);

  final VoidCallback onBackToHome;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoDirectionText(
              l10n.homeLoadErrorHeadline,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            AutoDirectionText(l10n.homeLoadErrorDescription),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => Future.microtask(onBackToHome),
                  child: Text(l10n.backToHomeButton),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => Future.microtask(onTryAgain),
                  child: Text(l10n.tryAgain),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPersonalCard extends StatelessWidget {
  const _EmptyPersonalCard({
    required this.title,
    required this.body,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String title;
  final String body;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(body, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              if (primaryLabel != null && onPrimary != null)
                ElevatedButton(
                  onPressed: onPrimary,
                  child: Text(primaryLabel!),
                ),
              if (secondaryLabel != null && onSecondary != null) ...[
                if (primaryLabel != null) const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onSecondary,
                  child: Text(secondaryLabel!),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _UserRecipesScreen extends StatelessWidget {
  const _UserRecipesScreen({
    required this.uid,
    required this.accentColor,
    required this.darkColor,
    required this.localeCode,
  });

  final String uid;
  final Color accentColor;
  final Color darkColor;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: FoodiyAppBar(title: Text(l10n.myRecipesTitle)),
      body: StreamBuilder<List<Recipe>>(
        stream: RecipeFirestoreService.instance.watchUserRecipes(uid: uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            debugPrint('UserRecipesScreen error: ${snapshot.error}');
            return Center(
              child: _InlineErrorCard(
                message: snapshot.error.toString(),
                onRetry: () => Navigator.of(context).pop(),
              ),
            );
          }
          final recipes = snapshot.data ?? [];
          if (recipes.isEmpty) {
            return Center(child: Text(l10n.noRecipesYet));
          }
          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: _RecipeTile(
                  recipe: recipe,
                  accentColor: accentColor,
                  darkColor: darkColor,
                  localeCode: localeCode,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
