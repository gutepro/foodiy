import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/core/widgets/recipe_image.dart';
import 'package:foodiy/features/discovery/discovery_feed.dart';
import 'package:foodiy/features/discovery/discovery_feed.dart'
    show
        DiscoveryCategoryRow,
        DiscoveryCookbook,
        DiscoveryRepository,
        PublicCookbookScreen;
import 'package:foodiy/features/chef/application/chef_follow_service.dart';
import 'package:foodiy/features/search/presentation/screens/search_results_screen.dart';
import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/shared/constants/categories.dart';
import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/core/models/user_type.dart';
import 'package:foodiy/shared/services/ads_service.dart';
import 'package:foodiy/shared/widgets/banner_ad_container.dart';
import 'package:foodiy/l10n/app_localizations.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late final TextEditingController _searchController;
  final DiscoveryRepository _repo = DiscoveryRepository();
  bool _adsLogged = false;
  VoidCallback? _profileListener;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _profileListener = () {
      if (mounted) {
        setState(() {});
      }
    };
    CurrentUserService.instance.profileNotifier.addListener(_profileListener!);
  }

  @override
  void dispose() {
    if (_profileListener != null) {
      CurrentUserService.instance.profileNotifier
          .removeListener(_profileListener!);
    }
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = kRecipeCategoryOptions;
    final userType =
        CurrentUserService.instance.currentProfile?.userType ?? UserType.freeUser;
    final adsOn = AdsService.adsEnabled(userType);
    if (!_adsLogged) {
      debugPrint(
        '[ADS_TIER] screen=Discover tier=$userType adsEnabled=$adsOn',
      );
      _adsLogged = true;
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navDiscover)),
      bottomNavigationBar: BannerAdContainer(showAds: adsOn),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: 2 + categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      final query = value.trim();
                      if (query.isEmpty) return;
                      FocusManager.instance.primaryFocus?.unfocus();
                      context.push(
                        AppRoutes.searchResults,
                        extra: SearchResultsArgs(query: query),
                      );
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: l10n.discoverSearchHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                );
              }

              if (index == 1) {
                final currentUid =
                    CurrentUserService.instance.currentProfile?.uid ?? '';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ChefsCarousel(currentUid: currentUid),
                );
              }

              final categoryIndex = index - 2;
              final category = categories[categoryIndex];
              final stream = _repo.watchPublicCookbooksByCategory(
                category.key,
                limit: 10,
              );
              return StreamBuilder<List<DiscoveryCookbook>>(
                stream: stream,
                builder: (context, snapshot) {
                  final cookbooks =
                      snapshot.data ?? const <DiscoveryCookbook>[];
                  return _CategorySection(
                    title: categoryTitleForKey(l10n, category.key),
                    keyName: category.key,
                    cookbooks: cookbooks,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ChefsCarousel extends StatelessWidget {
  const _ChefsCarousel({required this.currentUid});

  final String currentUid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DiscoverSectionHeader(title: 'Chefs to follow', onSeeAll: null),
        const SizedBox(height: 12),
        StreamBuilder<List<FollowingChef>>(
          stream: ChefFollowService.instance.watchTopChefs(
            excludeUid: currentUid,
            limit: 12,
          ),
          builder: (context, snapshot) {
            final chefs = snapshot.data ?? const <FollowingChef>[];
            if (snapshot.connectionState == ConnectionState.waiting &&
                chefs.isEmpty) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (chefs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No chefs to show yet. Check back soon!',
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }
            return SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: chefs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final chef = chefs[index];
                  return _ChefCard(chef: chef);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ChefCard extends StatelessWidget {
  const _ChefCard({required this.chef});

  final FollowingChef chef;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarUrl = chef.avatarUrl.trim();
    return SizedBox(
      width: 150,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push(AppRoutes.chefProfile, extra: chef.chefId);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                  backgroundColor: Colors.grey.shade200,
                  child: avatarUrl.isEmpty
                      ? Icon(Icons.person, color: Colors.grey.shade600)
                      : null,
                  onBackgroundImageError: (_, __) {},
                ),
                const SizedBox(height: 10),
                Text(
                  chef.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.group_outlined, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${chef.followersCount} followers',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.keyName,
    required this.cookbooks,
  });

  final String title;
  final String keyName;
  final List<DiscoveryCookbook> cookbooks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DiscoverSectionHeader(title: title, onSeeAll: null),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: cookbooks.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.discoverNoCookbooks,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: cookbooks.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final cookbook = cookbooks[index];
                    return _CookbookCardInline(cookbook: cookbook);
                  },
                ),
        ),
      ],
    );
  }
}

class _CookbookCardInline extends StatelessWidget {
  const _CookbookCardInline({required this.cookbook});

  final DiscoveryCookbook cookbook;
  static bool _loggedFirst = false;

  String? _pickImage() {
    final urlA = (cookbook.imageUrl).trim();
    if (urlA.isNotEmpty) return urlA;
    final urlB = (cookbook.coverImageUrl).trim();
    if (urlB.isNotEmpty) return urlB;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final url = _pickImage();

    if (!_loggedFirst) {
      _loggedFirst = true;
      debugPrint(
        '[DISCOVER_CARD_IMAGE] id=${cookbook.id} imageUrl=${cookbook.imageUrl} coverImageUrl=${cookbook.coverImageUrl}',
      );
    }

    return SizedBox(
      width: 180,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        elevation: 0.8,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PublicCookbookScreen(
                  cookbookId: cookbook.id,
                  title: cookbook.title,
                  ownerId: cookbook.ownerId,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: url == null
                        ? _PlaceholderBox()
                        : RecipeImage(
                            imageUrl: url,
                            height: double.infinity,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  cookbook.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cookbook.ownerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.public, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      l10n.discoverPublicBadge,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DiscoverSectionHeader extends StatelessWidget {
  const DiscoverSectionHeader({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: Text(l10n.homeSeeAll)),
        ],
      ),
    );
  }
}

class _PlaceholderBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, size: 32),
      ),
    );
  }
}

String categoryTitleForKey(AppLocalizations l10n, String key) {
  switch (key) {
    case 'breakfast':
      return l10n.discoverCategoryBreakfast;
    case 'brunch':
      return l10n.discoverCategoryBrunch;
    case 'quick-weeknight-dinners':
      return l10n.discoverCategoryQuickWeeknightDinners;
    case 'friday-lunch':
      return l10n.discoverCategoryFridayLunch;
    case 'comfort-food':
      return l10n.discoverCategoryComfortFood;
    case 'baking-basics':
      return l10n.discoverCategoryBakingBasics;
    case 'bread-and-dough':
      return l10n.discoverCategoryBreadAndDough;
    case 'pastries':
      return l10n.discoverCategoryPastries;
    case 'cakes-and-desserts':
      return l10n.discoverCategoryCakesAndDesserts;
    case 'cookies-and-small-sweets':
      return l10n.discoverCategoryCookiesAndSmallSweets;
    case 'chocolate-lovers':
      return l10n.discoverCategoryChocolateLovers;
    case 'healthy-and-light':
      return l10n.discoverCategoryHealthyAndLight;
    case 'high-protein':
      return l10n.discoverCategoryHighProtein;
    case 'vegetarian':
      return l10n.discoverCategoryVegetarian;
    case 'vegan':
      return l10n.discoverCategoryVegan;
    case 'gluten-free':
      return l10n.discoverCategoryGlutenFree;
    case 'one-pot-meals':
      return l10n.discoverCategoryOnePotMeals;
    case 'soups-and-stews':
      return l10n.discoverCategorySoupsAndStews;
    case 'salads':
      return l10n.discoverCategorySalads;
    case 'pasta-and-risotto':
      return l10n.discoverCategoryPastaAndRisotto;
    case 'rice-and-grains':
      return l10n.discoverCategoryRiceAndGrains;
    case 'middle-eastern':
      return l10n.discoverCategoryMiddleEastern;
    case 'italian-classics':
      return l10n.discoverCategoryItalianClassics;
    case 'asian-inspired':
      return l10n.discoverCategoryAsianInspired;
    case 'street-food':
      return l10n.discoverCategoryStreetFood;
    case 'family-favorites':
      return l10n.discoverCategoryFamilyFavorites;
    case 'hosting-and-holidays':
      return l10n.discoverCategoryHostingAndHolidays;
    case 'meal-prep':
      return l10n.discoverCategoryMealPrep;
    case 'kids-friendly':
      return l10n.discoverCategoryKidsFriendly;
    case 'late-night-cravings':
      return l10n.discoverCategoryLateNightCravings;
    default:
      return key;
  }
}
