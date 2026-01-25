// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeTitle => 'Home';

  @override
  String get myRecipesTitle => 'My recipes';

  @override
  String get backToHomeButton => 'Back to Home';

  @override
  String get homeLoadErrorTitle => 'We had trouble loading recipes.';

  @override
  String get untitledRecipe => 'Untitled recipe';

  @override
  String get deleteRecipeTooltip => 'Delete recipe';

  @override
  String get noRecipesYet => 'No recipes yet';

  @override
  String get homeLoadErrorHeadline => 'We had trouble loading your content.';

  @override
  String get homeLoadErrorDescription =>
      'Your recipes and cookbooks stay safe. You can try again, or go back to Home.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get homeChefPlaceholder => 'Chef';

  @override
  String homeGreetingChef(Object name) {
    return 'Hi $name, ready to cook?';
  }

  @override
  String homeGreetingUser(Object name) {
    return 'Hi $name, welcome back';
  }

  @override
  String get homeUploadPromptChef =>
      'Upload a recipe to turn it into a calm, step-by-step experience.';

  @override
  String get homeUploadPromptUser =>
      'Explore recipes and cookbooks. Uploads are for chefs.';

  @override
  String get homeUploadRecipe => 'Upload recipe';

  @override
  String get homeCreateManual => 'Create manually';

  @override
  String homeFreeChefLimit(int limit) {
    return 'Free chefs can publish up to $limit recipes.';
  }

  @override
  String get homeUpgradeToChef => 'Become a Chef to upload';

  @override
  String get homeShoppingListTooltip => 'Shopping list';

  @override
  String get homeSearchTooltip => 'Search';

  @override
  String get homeResumeCookingTitle => 'Resume cooking';

  @override
  String get homeNotNow => 'Not now';

  @override
  String homeStepRemaining(int step, Object time) {
    return 'Step $step • $time remaining';
  }

  @override
  String get homeResumeButton => 'Resume';

  @override
  String get homeMyCookbooks => 'My cookbooks';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeNoCookbooks => 'No cookbooks yet';

  @override
  String get homeLoadingRecipesTimeout => 'Loading recipes timed out.';

  @override
  String get homeUploadsForChefsTitle => 'Uploads are for chefs';

  @override
  String get homeUploadsForChefsBody =>
      'Become a Chef to add and organize your own recipes.';

  @override
  String get homeBecomeChefButton => 'Become a Chef';

  @override
  String get homeUploadDocBody =>
      'Upload a recipe document to start your personal cookbook.';

  @override
  String get homeUploadsForChefsSnackbar =>
      'Uploads are for chefs. Become a Chef to add recipes.';

  @override
  String get homeDeleteRecipeTitle => 'Delete recipe';

  @override
  String homeDeleteRecipeMessage(Object title) {
    return 'Are you sure you want to delete \"$title\"? This cannot be undone.';
  }

  @override
  String get homeCancel => 'Cancel';

  @override
  String get homeDelete => 'Delete';

  @override
  String get homeRecipeDeleted => 'Recipe deleted';

  @override
  String homeDeleteRecipeFailed(Object error) {
    return 'Failed to delete recipe: $error';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileAnonymousUser => 'Anonymous user';

  @override
  String get profileNoEmail => 'No email';

  @override
  String get profileEditChefProfile => 'Edit Chef Profile';

  @override
  String get profileAccountTypeChef => 'Chef account';

  @override
  String get profileAccountTypeUser => 'Regular user account';

  @override
  String get profilePlanBillingTitle => 'Plan and billing';

  @override
  String get profileSubscriptionTitle => 'View my subscription';

  @override
  String get profileSubscriptionSubtitle =>
      'See your current plan and upgrade options';

  @override
  String get profileChefToolsTitle => 'Chef tools';

  @override
  String get profileRecentActivityTitle => 'Recent activity';

  @override
  String get profileSeeAll => 'See all';

  @override
  String get profileNoRecentActivity => 'No recent activity yet';

  @override
  String get profileSettingsTitle => 'Settings';

  @override
  String get profileOpenSettings => 'Open settings';

  @override
  String get profileOpenSettingsSubtitle => 'Account, preferences and more';

  @override
  String get profileUserTypeFreeUser => 'Free user';

  @override
  String get profileUserTypePremiumUser => 'Premium user';

  @override
  String get profileUserTypeFreeChef => 'Free chef';

  @override
  String get profileUserTypePremiumChef => 'Premium chef';

  @override
  String get profileChefDashboardUnavailable =>
      'Chef dashboard is available for chef accounts.';

  @override
  String get profileChefDashboardTitle => 'Chef Dashboard';

  @override
  String get profileChefDashboardSubtitle => 'Manage your content on Foodiy';

  @override
  String get profileUploadRecipe => 'Upload recipe';

  @override
  String get profileCreateCookbook => 'Create cookbook';

  @override
  String get profileChefInsights => 'Chef Insights';

  @override
  String profileFreeChefLimitMessage(int limit, int current) {
    return 'Free chefs can publish up to $limit recipes.\\nRecipes: $current / $limit';
  }

  @override
  String get profileUpgradeToPremiumChef => 'Upgrade to Premium Chef';

  @override
  String get profileStatMyRecipes => 'My recipes';

  @override
  String get profileStatMyCookbooks => 'My cookbooks';

  @override
  String get profileStatFollowers => 'Followers';

  @override
  String get profileStatChefInsights => 'Chef Insights';

  @override
  String get profileInsightsDescription =>
      'Your content is visible and discoverable on Foodiy.';

  @override
  String get profileInsightsRecipes => 'Recipes';

  @override
  String get profileInsightsCookbooks => 'Cookbooks';

  @override
  String get profileInsightsFollowers => 'Followers';

  @override
  String get profileInsightsPremiumNote =>
      'Premium chefs enjoy fewer limits and a cleaner experience.';

  @override
  String get profileInsightsClose => 'Close';

  @override
  String profileStepsCount(int count) {
    return '$count steps';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navDiscover => 'Discover';

  @override
  String get navCookbooks => 'Cookbooks';

  @override
  String get navProfile => 'Profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPlayTimerSound => 'Play sound when timer finishes';

  @override
  String get settingsNotificationsSection => 'Notifications';

  @override
  String get settingsNotificationSettings => 'Notification settings';

  @override
  String get settingsNotificationSettingsSubtitle =>
      'Choose which notifications you want to receive';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get settingsEditPersonalDetails => 'Edit personal details';

  @override
  String get settingsChangePassword => 'Change password';

  @override
  String get settingsLogout => 'Log out';

  @override
  String get settingsLogoutFail => 'Failed to log out. Please try again.';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsPreferencesSection => 'App preferences';

  @override
  String get settingsLanguageUnits => 'Language and units';

  @override
  String get settingsLanguageUnitsSubtitle =>
      'Choose app language and measurement units';

  @override
  String get settingsLegalSection => 'Legal';

  @override
  String get settingsTermsOfUse => 'Terms of Use';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsAboutApp => 'About Foodiy';

  @override
  String get settingsAboutAppSubtitle => 'Learn more about this app';

  @override
  String get languageUnitsTitle => 'Language and units';

  @override
  String get languageSectionTitle => 'Language';

  @override
  String get languagePickerLabel => 'App language';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHebrew => 'Hebrew';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageFrench => 'French';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get languageItalian => 'Italian';

  @override
  String get unitsSectionTitle => 'Units';

  @override
  String get unitsMetric => 'Metric (grams, Celsius)';

  @override
  String get unitsImperial => 'Imperial (cups, Fahrenheit)';

  @override
  String get notificationTitle => 'Notifications';

  @override
  String get notificationPreferencesTitle => 'Notification preferences';

  @override
  String get notificationNewChefRecipesTitle => 'New recipes from chefs';

  @override
  String get notificationNewChefRecipesSubtitle =>
      'Get notified when chefs publish new recipes';

  @override
  String get notificationPlaylistSuggestionsTitle => 'Playlist suggestions';

  @override
  String get notificationPlaylistSuggestionsSubtitle =>
      'Get suggestions for playlists you might like';

  @override
  String get notificationAppTipsTitle => 'App tips and updates';

  @override
  String get privacyTitle => 'Privacy policy';

  @override
  String get privacyPlaceholder =>
      'This is a placeholder for the Foodiy privacy policy.\\n\\nHere you will describe how user data is used, stored, and protected.\\nLater we will replace this text with the real policy.';

  @override
  String get termsTitle => 'Terms of Use';

  @override
  String get termsPlaceholder =>
      'This is a placeholder for the Foodiy terms of use.\\n\\nHere you will describe the rules for using the app, limitations of liability, and other legal details.\\nLater we will replace this text with the real terms.';

  @override
  String get aboutTitle => 'About Foodiy';

  @override
  String get aboutAppName => 'Foodiy';

  @override
  String get aboutVersion => 'Version 0.1.0 (dev)';

  @override
  String get aboutDescription =>
      'Foodiy is your personal cooking and cookbook companion.\\n\\nCreate and follow recipe cookbooks, discover chef collections, build your own cookbooks and manage shopping lists – all in one place.';

  @override
  String aboutCopyright(int year) {
    return '© $year Foodiy. All rights reserved.';
  }

  @override
  String get homeSectionFailed => 'Section failed to render';

  @override
  String homeSectionErrorDetails(Object tag, Object error) {
    return '[$tag] $error';
  }

  @override
  String homeUiError(Object error) {
    return 'UI error: $error';
  }

  @override
  String get discoverSearchHint => 'Search cookbooks or chefs';

  @override
  String get discoverNoCookbooks => 'No public cookbooks yet';

  @override
  String get discoverPublicBadge => 'Public';

  @override
  String get discoverCategoryBreakfast => 'Breakfast';

  @override
  String get discoverCategoryBrunch => 'Brunch';

  @override
  String get discoverCategoryQuickWeeknightDinners => 'Quick Weeknight Dinners';

  @override
  String get discoverCategoryFridayLunch => 'Friday Lunch';

  @override
  String get discoverCategoryComfortFood => 'Comfort Food';

  @override
  String get discoverCategoryBakingBasics => 'Baking Basics';

  @override
  String get discoverCategoryBreadAndDough => 'Bread & Dough';

  @override
  String get discoverCategoryPastries => 'Pastries';

  @override
  String get discoverCategoryCakesAndDesserts => 'Cakes & Desserts';

  @override
  String get discoverCategoryCookiesAndSmallSweets => 'Cookies & Small Sweets';

  @override
  String get discoverCategoryChocolateLovers => 'Chocolate Lovers';

  @override
  String get discoverCategoryHealthyAndLight => 'Healthy & Light';

  @override
  String get discoverCategoryHighProtein => 'High Protein';

  @override
  String get discoverCategoryVegetarian => 'Vegetarian';

  @override
  String get discoverCategoryVegan => 'Vegan';

  @override
  String get discoverCategoryGlutenFree => 'Gluten Free';

  @override
  String get discoverCategoryOnePotMeals => 'One Pot Meals';

  @override
  String get discoverCategorySoupsAndStews => 'Soups & Stews';

  @override
  String get discoverCategorySalads => 'Salads';

  @override
  String get discoverCategoryPastaAndRisotto => 'Pasta & Risotto';

  @override
  String get discoverCategoryRiceAndGrains => 'Rice & Grains';

  @override
  String get discoverCategoryMiddleEastern => 'Middle Eastern';

  @override
  String get discoverCategoryItalianClassics => 'Italian Classics';

  @override
  String get discoverCategoryAsianInspired => 'Asian Inspired';

  @override
  String get discoverCategoryStreetFood => 'Street Food';

  @override
  String get discoverCategoryFamilyFavorites => 'Family Favorites';

  @override
  String get discoverCategoryHostingAndHolidays => 'Hosting & Holidays';

  @override
  String get discoverCategoryMealPrep => 'Meal Prep';

  @override
  String get discoverCategoryKidsFriendly => 'Kids Friendly';

  @override
  String get discoverCategoryLateNightCravings => 'Late Night Cravings';

  @override
  String get cookbooksLoadError => 'Cookbooks sync failed. Please try again.';

  @override
  String get cookbooksEmptyTitle => 'You do not have any cookbooks yet';

  @override
  String get cookbooksEmptyBody => 'Create your first personal cookbook';

  @override
  String get cookbooksUntitled => 'Untitled cookbook';

  @override
  String get cookbooksPrivateBadge => 'Private';

  @override
  String cookbooksRecipeCount(int count) {
    return '$count recipes';
  }

  @override
  String get cookbooksChefCookbookSuffix => 'Chef cookbook';

  @override
  String get cookbooksActionRename => 'Rename';

  @override
  String get cookbooksActionShare => 'Share';

  @override
  String get cookbooksActionDelete => 'Delete';

  @override
  String get cookbooksMissing => 'This cookbook no longer exists';

  @override
  String cookbooksCreateFailed(Object error) {
    return 'Unable to create cookbook: $error';
  }

  @override
  String get cookbooksRenameTitle => 'Rename cookbook';

  @override
  String get cookbooksRenameNewName => 'New name';

  @override
  String get cookbooksNameRequired => 'Name is required';

  @override
  String get cookbooksSave => 'Save';

  @override
  String get cookbooksDeleteTitle => 'Delete cookbook';

  @override
  String cookbooksDeleteMessage(Object name) {
    return 'Delete \"$name\"?';
  }

  @override
  String cookbooksShareSubject(Object name) {
    return 'Cookbook: $name';
  }

  @override
  String get cookbooksCategoryLimit => 'You can select up to 5 categories';

  @override
  String get cookbooksCategoryPublicRequired =>
      'Select 1-5 categories for public cookbooks';

  @override
  String get cookbooksPublicSubtitle =>
      'Public cookbooks are visible to others';

  @override
  String get cookbooksBasicsTitle => 'Basics';

  @override
  String get cookbooksNameLabel => 'Cookbook name';

  @override
  String get cookbooksChooseImage => 'Choose image';

  @override
  String get cookbooksCategoriesTitle => 'Categories';

  @override
  String get cookbooksCategoriesPublicHint =>
      'Select 1-5 categories so others can find your cookbook.';

  @override
  String get cookbooksCategoriesPrivateHint =>
      'Optional: add up to 5 categories.';

  @override
  String cookbooksCategoriesSelected(int count) {
    return '$count/5 selected';
  }

  @override
  String get cookbooksCreateTitle => 'Create cookbook';

  @override
  String get cookbooksBack => 'Back';

  @override
  String get cookbooksNext => 'Next';

  @override
  String get cookbooksCreate => 'Create';

  @override
  String get recipeDifficultyMedium => 'Medium';

  @override
  String recipeSaveSuccess(Object title) {
    return 'Recipe \"$title\" saved and added to My recipes';
  }

  @override
  String recipeSaveFailed(Object error) {
    return 'Failed to save/publish recipe: $error';
  }

  @override
  String get recipeCreateTitle => 'Create recipe';

  @override
  String get recipeEditTitle => 'Edit recipe';

  @override
  String get recipeOnlyChefBody =>
      'Only chef accounts can upload recipes.\n\nUpgrade to a chef plan to start creating recipes.';

  @override
  String get recipeFreePlanLimitBody =>
      'You have reached the upload limit for the free chef plan.\n\nUpgrade to a premium chef plan to create more recipes.';

  @override
  String get recipePhotoLabel => 'Recipe photo';

  @override
  String get recipeTakePhoto => 'Take a photo';

  @override
  String get recipePhotoLibrary => 'Photo library';

  @override
  String get recipePickFile => 'Files';

  @override
  String get recipeUploadLimitBanner =>
      'Free chef plan - recipe upload is limited.\nUpgrade to premium chef to remove this limit.';

  @override
  String get recipeTitleLabel => 'Recipe title';

  @override
  String get recipeIngredientsTitle => 'Ingredients';

  @override
  String get recipeIngredientLabel => 'Ingredient';

  @override
  String get recipeQuantityLabel => 'Qty';

  @override
  String get recipeUnitLabel => 'Unit';

  @override
  String get recipeAddIngredient => 'Add ingredient';

  @override
  String get recipeToolsTitle => 'Tools / Equipment';

  @override
  String get recipeToolLabel => 'Tool';

  @override
  String get recipeAddTool => 'Add tool';

  @override
  String get recipePreCookingTitle => 'Preparation before cooking';

  @override
  String get recipePreCookingHint =>
      'For example: preheat oven to 200C, line the tray, soak beans overnight...';

  @override
  String get recipeStepsTitle => 'Steps';

  @override
  String get recipeAddStep => 'Add step';

  @override
  String get recipePreviewInPlayer => 'Preview in player';

  @override
  String get recipeUpdateButton => 'Update recipe';

  @override
  String get recipeSaveButton => 'Save recipe';

  @override
  String get recipeStepLabel => 'Step';

  @override
  String get recipeStepMinutesLabel => 'min';

  @override
  String get recipeRemoveStepTooltip => 'Remove step';

  @override
  String get recipeDeleteButton => 'Delete recipe';

  @override
  String get recipeDeleteStep1Title => 'Delete recipe?';

  @override
  String get recipeDeleteStep1Body =>
      'Are you sure you want to delete this recipe?';

  @override
  String get recipeDeleteStep1Continue => 'Continue';

  @override
  String get recipeDeleteStep2Title => 'This cannot be undone';

  @override
  String get recipeDeleteStep2Body =>
      'Deleting this recipe will remove it permanently.';

  @override
  String get recipeDeleteStep2Delete => 'Delete';

  @override
  String recipeDeleteFailed(Object error) {
    return 'Failed to delete recipe: $error';
  }

  @override
  String get importDocTitle => 'Import recipe from document';

  @override
  String get importDocHeader => 'Import a recipe from a document';

  @override
  String get importDocBody =>
      'Choose a clean recipe file or photo. We will keep things steady while we read it and create a recipe for you.';

  @override
  String get importDocFileReady => 'File ready';

  @override
  String get importDocAddDocument => 'Add a recipe document';

  @override
  String get importDocFormatsShort => 'PDF, DOCX, JPG, PNG, WEBP';

  @override
  String get importDocProcessingNote =>
      'We will keep your upload stable while we process it.';

  @override
  String get importDocEmptyHelper =>
      'No file chosen yet. Add a clear recipe file or photo to continue.';

  @override
  String get importDocChooseFile => 'Choose file';

  @override
  String get importDocChoosePhoto => 'Choose photo';

  @override
  String get importDocTakePhoto => 'Take photo';

  @override
  String get importDocTipsTitle => 'Tips for a calm import';

  @override
  String get importDocTip1 =>
      'Use a well-lit photo with the full recipe visible.';

  @override
  String get importDocTip2 =>
      'Stay on this screen until we send you to the recipe.';

  @override
  String get importDocTip3 => 'You can edit details after the import finishes.';

  @override
  String get importDocUpload => 'Upload and import';

  @override
  String get importDocSupportedFooter =>
      'Supported: PDF, DOC, DOCX, JPG, PNG, WEBP. Larger files may take longer to process.';

  @override
  String get addButton => 'Add';

  @override
  String get addSelected => 'Add selected';

  @override
  String get backButton => 'Back';

  @override
  String get cancel => 'Cancel';

  @override
  String chefByLine(Object name) {
    return 'By $name';
  }

  @override
  String get chefFollowLabel => 'Follow';

  @override
  String get chefFollowSignInRequired => 'Sign in to follow chefs';

  @override
  String chefFollowUpdateFailed(Object error) {
    return 'Failed to update follow: $error';
  }

  @override
  String get chefFollowingLabel => 'Following';

  @override
  String get chefMyRecipesSubtitle => 'Manage your recipes';

  @override
  String get chefNoCookbooks => 'No cookbooks yet';

  @override
  String get chefNotEnabledBody =>
      'Chef tools are available for chef accounts.';

  @override
  String get chefNotEnabledTitle => 'Chef tools unavailable';

  @override
  String get chefNotFound => 'Chef not found';

  @override
  String get chefPremiumFeaturesBody =>
      'Upgrade to Premium Chef to unlock publishing, cookbooks, and insights.';

  @override
  String get chefPremiumFeaturesTitle => 'Premium features';

  @override
  String get chefPublicCookbook => 'Public';

  @override
  String get chefUploadNewRecipe => 'Upload new recipe';

  @override
  String get chefUploadNewRecipeSubtitle =>
      'Import a recipe document or create manually.';

  @override
  String cookbooksAddRecipeFailed(Object error) {
    return 'Failed to add recipe: $error';
  }

  @override
  String get cookbooksAddRecipes => 'Add recipes';

  @override
  String get cookbooksAddingRecipes => 'Adding recipes...';

  @override
  String get cookbooksCoverImage => 'Cover image';

  @override
  String get cookbooksDeleteWarning =>
      'Delete this cookbook? This cannot be undone.';

  @override
  String get cookbooksDescriptionLabel => 'Description';

  @override
  String get cookbooksEditTitle => 'Edit cookbook';

  @override
  String cookbooksLoadRecipesFailed(Object error) {
    return 'Failed to load recipes: $error';
  }

  @override
  String get cookbooksLoadRecipesFailedDetail =>
      'Failed to load recipes. Please try again.';

  @override
  String get cookbooksLoadRecipesFailedSimple => 'Failed to load recipes';

  @override
  String get cookbooksNoRecipesAvailable =>
      'This cookbook has no recipes available.';

  @override
  String get cookbooksNoRecipesToAdd => 'No recipes available to add.';

  @override
  String get cookbooksNoRecipesYet => 'This cookbook has no recipes yet.';

  @override
  String get cookbooksPlaylistTitleLabel => 'Playlist title';

  @override
  String get cookbooksPlaylistTitleRequired => 'Please enter a playlist title';

  @override
  String get cookbooksPublicCreateTitle => 'Create public cookbook';

  @override
  String get cookbooksPublicCreated => 'Public playlist created';

  @override
  String get cookbooksPublicLabel => 'Public';

  @override
  String get cookbooksPublicNoRecipesBody =>
      'You have no recipes to add yet.\nUpload recipes to create a public cookbook.';

  @override
  String get cookbooksRecipesAdded => 'Recipes added to cookbook';

  @override
  String get cookbooksSaveChanges => 'Save changes';

  @override
  String cookbooksSaveFailed(Object error) {
    return 'Failed to save: $error';
  }

  @override
  String get cookbooksSaveToMy => 'Save to my cookbooks';

  @override
  String cookbooksSavedToMy(Object name) {
    return 'Saved $name to your cookbooks';
  }

  @override
  String get cookbooksSelectAtLeastOneRecipe => 'Select at least one recipe';

  @override
  String get cookbooksSelectRecipes => 'Select recipes';

  @override
  String get cookbooksSelectRecipesToInclude => 'Select recipes to include';

  @override
  String get cookbooksUpdated => 'Cookbook updated';

  @override
  String get discoverChefsToFollow => 'Chefs to follow';

  @override
  String discoverFollowersCount(int count) {
    return '$count followers';
  }

  @override
  String get discoverNoChefsYet => 'No chefs to follow yet';

  @override
  String durationHours(int hours) {
    return '$hours hr';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours hr $minutes min';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get goHomeButton => 'Go Home';

  @override
  String get importDocEmptyFile => 'File is empty. Choose another file.';

  @override
  String get importDocOverlayErrorTitle => 'We couldn\'t process this file';

  @override
  String get importDocOverlayProcessing => 'Processing...';

  @override
  String get importDocOverlayUploading => 'Uploading...';

  @override
  String importDocPickPhotoFailed(Object error) {
    return 'Failed to pick photo: $error';
  }

  @override
  String importDocReadBytesFailed(Object error) {
    return 'Failed to read file: $error';
  }

  @override
  String get importDocSignInRequired => 'Sign in to upload recipes.';

  @override
  String get importDocStepSaving => 'Saving recipe';

  @override
  String get importDocStepUnderstanding => 'Understanding recipe';

  @override
  String get importDocStepUploading => 'Uploading file';

  @override
  String importDocTakePhotoFailed(Object error) {
    return 'Failed to take photo: $error';
  }

  @override
  String get importDocUploadFailed => 'Upload failed';

  @override
  String importDocUploadFailedCode(Object code) {
    return 'Upload failed ($code)';
  }

  @override
  String importDocUploadFailedWithError(Object error) {
    return 'Upload failed: $error';
  }

  @override
  String get importDocUploaded => 'Upload complete';

  @override
  String get importedRecipeTitle => 'Imported recipe';

  @override
  String get playlistPlayAll => 'Play all';

  @override
  String get playlistPlayAllNotImplemented => 'Play all is not implemented yet';

  @override
  String playlistPlayerTitle(Object title) {
    return 'Playlist - $title';
  }

  @override
  String get playlistStepCookFirstRecipe =>
      'Cook the first recipe according to its instructions.';

  @override
  String get playlistStepCookRemaining => 'Cook the rest of the playlist.';

  @override
  String get playlistStepPrepIngredients =>
      'Prepare ingredients for the first recipe.';

  @override
  String get playlistStepPrepNextRecipe =>
      'Prepare the next recipe in the playlist.';

  @override
  String get recipeAddIngredientsToCart => 'Add ingredients to cart';

  @override
  String get recipeAddToCartFailed => 'Failed to add to cart';

  @override
  String get recipeAddToCookbook => 'Add to cookbook';

  @override
  String recipeAddToCookbookFailed(Object error) {
    return 'Failed to add to cookbook: $error';
  }

  @override
  String get recipeAddToCookbooksTitle => 'Add to cookbooks';

  @override
  String get recipeAddToFavorites => 'Add to favorites';

  @override
  String recipeAddedToCart(int count) {
    return 'Added $count items to cart';
  }

  @override
  String get recipeAddedToCookbooks => 'Added to cookbooks';

  @override
  String get recipeAddedToFavorites => 'Added to favorites';

  @override
  String get recipeAttachDialogFailed => 'Unable to load cookbooks';

  @override
  String get recipeCookbooksLoadFailed => 'Failed to load cookbooks';

  @override
  String recipeCoverUploadFailed(Object error) {
    return 'Failed to upload cover: $error';
  }

  @override
  String get recipeCreateCookbookFirst => 'Create a cookbook first';

  @override
  String get recipeDifficultyEasy => 'Easy';

  @override
  String get recipeEditButton => 'Edit';

  @override
  String get recipeImportFailedBody =>
      'We couldn\'t import this recipe. Try again or go Home.';

  @override
  String get recipeImportFailedScreenTitle => 'Import failed';

  @override
  String get recipeImportFailedTitle => 'Import failed';

  @override
  String get recipeImportNeedsReviewBody =>
      'We imported the recipe but it needs review. You can edit it now.';

  @override
  String get recipeImportNeedsReviewTitle => 'Needs review';

  @override
  String get recipeImportProcessingTitle => 'Still working on it';

  @override
  String get recipeImportStepExtractingText => 'Extracting text';

  @override
  String get recipeImportStepFinalizing => 'Finalizing';

  @override
  String get recipeImportStepUnderstanding => 'Understanding recipe';

  @override
  String get recipeImportStepUploadComplete => 'Upload complete';

  @override
  String get recipeImportTimeoutBody =>
      'This is taking longer than expected. You can try again or go Home.';

  @override
  String get recipeImportTimeoutTitle => 'Import timeout';

  @override
  String get recipeImportUnknownError => 'Unknown import error';

  @override
  String get recipeNoIngredients => 'No ingredients yet';

  @override
  String get recipeNoIngredientsToAdd => 'No ingredients to add';

  @override
  String get recipeNoSteps => 'No steps yet';

  @override
  String get recipeNoTools => 'No tools listed';

  @override
  String get recipeNotFoundBody => 'We couldn\'t find this recipe.';

  @override
  String get recipeNotFoundTitle => 'Recipe not found';

  @override
  String get recipeOcrPreviewLabel => 'OCR preview';

  @override
  String get recipeOriginalLanguageLabel => 'Original';

  @override
  String get recipePlayerHandsFreeMode => 'Hands-free mode';

  @override
  String get recipePlayerHandsFreeOn => 'Hands-free mode ON';

  @override
  String get recipePlayerNoSteps => 'No steps available';

  @override
  String recipePlayerStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String recipePlayerStepPlaceholder(int number) {
    return 'Step $number';
  }

  @override
  String get recipePlayerVoiceControl => 'Voice control';

  @override
  String get recipeProcessing => 'Processing';

  @override
  String get recipeRemoveFromFavorites => 'Remove from favorites';

  @override
  String get recipeRemovedFromFavorites => 'Removed from favorites';

  @override
  String get recipeSignInToSave => 'Sign in to save recipes.';

  @override
  String get recipeStartCooking => 'Start cooking';

  @override
  String get recipeStepRequired => 'Step is required';

  @override
  String get recipeTitleRequired => 'Title is required';

  @override
  String get recipeTranslateToEnglish => 'Translate to English';

  @override
  String recipeTranslatedFrom(Object language) {
    return 'Translated from $language';
  }

  @override
  String get recipeTranslating => 'Translating';

  @override
  String get recipeTranslationUnavailable => 'Translation is unavailable';

  @override
  String get recipeUnavailableBody => 'This recipe isn\'t available right now.';

  @override
  String get recipeUnavailableTitle => 'Recipe unavailable';

  @override
  String get recipeViewChef => 'View chef';

  @override
  String get recipeViewOriginal => 'View original';

  @override
  String get recipesLabel => 'Recipes';

  @override
  String get chefSaveFailed => 'Failed to save profile';

  @override
  String get chefEditOwnOnly => 'You can only edit your own profile.';

  @override
  String get chefEditAvatarLabel => 'Avatar';

  @override
  String get chefEditChangePhoto => 'Change photo';

  @override
  String get chefEditBioLabel => 'Bio';

  @override
  String get chefEditBioHint =>
      'Tell followers about your cooking style, specialties, and inspirations.';

  @override
  String get chefEditMakeChangeToSave => 'Make a change to enable Save.';

  @override
  String get chefNoRecipesYet => 'You have not published any recipes yet';

  @override
  String get chefLoadRecipesFailed =>
      'Failed to load recipes. Please try again.';

  @override
  String chefRecipeStats(int views, int saves) {
    return 'Views: $views • Saves: $saves';
  }

  @override
  String chefRecipeDeleted(Object title) {
    return 'Recipe \"$title\" deleted';
  }

  @override
  String get discoverFeaturedCookbooks => 'Featured cookbooks';

  @override
  String get discoverCookbookLoadFailed => 'Failed to load cookbook';

  @override
  String get discoverCookbookNotFound => 'Cookbook not found';

  @override
  String get discoverCookbookNoRecipes => 'No recipes in this cookbook yet.';

  @override
  String get discoverCookbookNoRecipesAvailable => 'No recipes available.';

  @override
  String get discoverRecipesLoadFailed => 'Failed to load recipes';
}
