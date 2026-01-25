// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get homeTitle => 'Accueil';

  @override
  String get myRecipesTitle => 'Mes recettes';

  @override
  String get backToHomeButton => 'Retour à l\'accueil';

  @override
  String get homeLoadErrorTitle =>
      'Nous avons rencontré un problème lors du chargement des recettes.';

  @override
  String get untitledRecipe => 'Recette sans titre';

  @override
  String get deleteRecipeTooltip => 'Supprimer la recette';

  @override
  String get noRecipesYet => 'Pas encore de recettes';

  @override
  String get homeLoadErrorHeadline =>
      'Nous avons rencontré un problème lors du chargement de votre contenu.';

  @override
  String get homeLoadErrorDescription =>
      'Vos recettes et carnets restent en sécurité. Vous pouvez réessayer ou retourner à l\'accueil.';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get homeChefPlaceholder => 'Chef';

  @override
  String homeGreetingChef(Object name) {
    return 'Salut $name, prêt à cuisiner ?';
  }

  @override
  String homeGreetingUser(Object name) {
    return 'Salut $name, bon retour';
  }

  @override
  String get homeUploadPromptChef =>
      'Publiez une recette et transformez-la en expérience calme, étape par étape.';

  @override
  String get homeUploadPromptUser =>
      'Explorez des recettes et des livres. Les ajouts sont réservés aux chefs.';

  @override
  String get homeUploadRecipe => 'Publier une recette';

  @override
  String get homeCreateManual => 'Créer manuellement';

  @override
  String homeFreeChefLimit(int limit) {
    return 'Les chefs gratuits peuvent publier jusqu\'à $limit recettes.';
  }

  @override
  String get homeUpgradeToChef => 'Devenir chef pour publier';

  @override
  String get homeShoppingListTooltip => 'Liste de courses';

  @override
  String get homeSearchTooltip => 'Recherche';

  @override
  String get homeResumeCookingTitle => 'Reprendre la cuisine';

  @override
  String get homeNotNow => 'Pas maintenant';

  @override
  String homeStepRemaining(int step, Object time) {
    return 'Étape $step • $time restantes';
  }

  @override
  String get homeResumeButton => 'Reprendre';

  @override
  String get homeMyCookbooks => 'Mes livres de recettes';

  @override
  String get homeSeeAll => 'Tout voir';

  @override
  String get homeNoCookbooks => 'Aucun livre de recettes pour l\'instant';

  @override
  String get homeLoadingRecipesTimeout =>
      'Le chargement des recettes a expiré.';

  @override
  String get homeUploadsForChefsTitle => 'Les ajouts sont réservés aux chefs';

  @override
  String get homeUploadsForChefsBody =>
      'Devenez chef pour ajouter et organiser vos recettes.';

  @override
  String get homeBecomeChefButton => 'Devenir chef';

  @override
  String get homeUploadDocBody =>
      'Publiez un document de recette pour démarrer votre livre personnel.';

  @override
  String get homeUploadsForChefsSnackbar =>
      'Les ajouts sont réservés aux chefs. Devenez chef pour ajouter des recettes.';

  @override
  String get homeDeleteRecipeTitle => 'Supprimer la recette';

  @override
  String homeDeleteRecipeMessage(Object title) {
    return 'Supprimer \"$title\" ? Ceci est irréversible.';
  }

  @override
  String get homeCancel => 'Annuler';

  @override
  String get homeDelete => 'Supprimer';

  @override
  String get homeRecipeDeleted => 'Recette supprimée';

  @override
  String homeDeleteRecipeFailed(Object error) {
    return 'Échec de la suppression de la recette : $error';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileAnonymousUser => 'Utilisateur anonyme';

  @override
  String get profileNoEmail => 'Pas d\'e-mail';

  @override
  String get profileEditChefProfile => 'Modifier le profil chef';

  @override
  String get profileAccountTypeChef => 'Compte chef';

  @override
  String get profileAccountTypeUser => 'Compte utilisateur standard';

  @override
  String get profilePlanBillingTitle => 'Offre et facturation';

  @override
  String get profileSubscriptionTitle => 'Voir mon abonnement';

  @override
  String get profileSubscriptionSubtitle =>
      'Consultez votre offre actuelle et les options de mise à niveau';

  @override
  String get profileChefToolsTitle => 'Outils chef';

  @override
  String get profileRecentActivityTitle => 'Activité récente';

  @override
  String get profileSeeAll => 'Tout voir';

  @override
  String get profileNoRecentActivity => 'Aucune activité récente';

  @override
  String get profileSettingsTitle => 'Paramètres';

  @override
  String get profileOpenSettings => 'Ouvrir les paramètres';

  @override
  String get profileOpenSettingsSubtitle => 'Compte, préférences et plus';

  @override
  String get profileUserTypeFreeUser => 'Utilisateur gratuit';

  @override
  String get profileUserTypePremiumUser => 'Utilisateur premium';

  @override
  String get profileUserTypeFreeChef => 'Chef gratuit';

  @override
  String get profileUserTypePremiumChef => 'Chef premium';

  @override
  String get profileChefDashboardUnavailable =>
      'Le tableau de bord chef est disponible pour les comptes chef.';

  @override
  String get profileChefDashboardTitle => 'Tableau de bord chef';

  @override
  String get profileChefDashboardSubtitle => 'Gérez votre contenu sur Foodiy';

  @override
  String get profileUploadRecipe => 'Publier une recette';

  @override
  String get profileCreateCookbook => 'Créer un livre de recettes';

  @override
  String get profileChefInsights => 'Insights chef';

  @override
  String profileFreeChefLimitMessage(int limit, int current) {
    return 'Les chefs gratuits peuvent publier jusqu\'à $limit recettes.\\nRecettes : $current / $limit';
  }

  @override
  String get profileUpgradeToPremiumChef => 'Passer en Chef Premium';

  @override
  String get profileStatMyRecipes => 'Mes recettes';

  @override
  String get profileStatMyCookbooks => 'Mes livres de recettes';

  @override
  String get profileStatFollowers => 'Abonnés';

  @override
  String get profileStatChefInsights => 'Insights chef';

  @override
  String get profileInsightsDescription =>
      'Votre contenu est visible et découvrable sur Foodiy.';

  @override
  String get profileInsightsRecipes => 'Recettes';

  @override
  String get profileInsightsCookbooks => 'Livres de recettes';

  @override
  String get profileInsightsFollowers => 'Abonnés';

  @override
  String get profileInsightsPremiumNote =>
      'Les chefs premium ont moins de limites et une expérience plus fluide.';

  @override
  String get profileInsightsClose => 'Fermer';

  @override
  String profileStepsCount(int count) {
    return '$count étapes';
  }

  @override
  String get navHome => 'Accueil';

  @override
  String get navDiscover => 'Découvrir';

  @override
  String get navCookbooks => 'Livres de recettes';

  @override
  String get navProfile => 'Profil';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsPlayTimerSound =>
      'Jouer un son quand le minuteur se termine';

  @override
  String get settingsNotificationsSection => 'Notifications';

  @override
  String get settingsNotificationSettings => 'Paramètres des notifications';

  @override
  String get settingsNotificationSettingsSubtitle =>
      'Choisissez quelles notifications recevoir';

  @override
  String get settingsAccountSection => 'Compte';

  @override
  String get settingsEditPersonalDetails =>
      'Modifier les informations personnelles';

  @override
  String get settingsChangePassword => 'Changer le mot de passe';

  @override
  String get settingsLogout => 'Se déconnecter';

  @override
  String get settingsLogoutFail => 'Échec de la déconnexion. Réessayez.';

  @override
  String get settingsDeleteAccount => 'Supprimer le compte';

  @override
  String get settingsPreferencesSection => 'Préférences de l\'app';

  @override
  String get settingsLanguageUnits => 'Langue et unités';

  @override
  String get settingsLanguageUnitsSubtitle =>
      'Choisissez la langue et les unités de mesure';

  @override
  String get settingsLegalSection => 'Mentions légales';

  @override
  String get settingsTermsOfUse => 'Conditions d\'utilisation';

  @override
  String get settingsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get settingsAboutSection => 'À propos';

  @override
  String get settingsAboutApp => 'À propos de Foodiy';

  @override
  String get settingsAboutAppSubtitle => 'En savoir plus sur cette application';

  @override
  String get languageUnitsTitle => 'Langue et unités';

  @override
  String get languageSectionTitle => 'Langue';

  @override
  String get languagePickerLabel => 'Langue de l\'application';

  @override
  String get languageSystemDefault => 'Langue du système';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageHebrew => 'Hébreu';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageArabic => 'Arabe';

  @override
  String get languageChinese => 'Chinois';

  @override
  String get languageJapanese => 'Japonais';

  @override
  String get languageItalian => 'Italien';

  @override
  String get unitsSectionTitle => 'Unités';

  @override
  String get unitsMetric => 'Métrique (grammes, Celsius)';

  @override
  String get unitsImperial => 'Impérial (tasses, Fahrenheit)';

  @override
  String get notificationTitle => 'Notifications';

  @override
  String get notificationPreferencesTitle => 'Préférences de notifications';

  @override
  String get notificationNewChefRecipesTitle => 'Nouvelles recettes des chefs';

  @override
  String get notificationNewChefRecipesSubtitle =>
      'Recevez une alerte quand les chefs publient de nouvelles recettes';

  @override
  String get notificationPlaylistSuggestionsTitle => 'Suggestions de playlists';

  @override
  String get notificationPlaylistSuggestionsSubtitle =>
      'Recevez des suggestions de playlists susceptibles de vous plaire';

  @override
  String get notificationAppTipsTitle => 'Astuces et mises à jour';

  @override
  String get privacyTitle => 'Politique de confidentialité';

  @override
  String get privacyPlaceholder =>
      'Ceci est un texte provisoire pour la politique de confidentialité de Foodiy.\\n\\nIci seront décrits l\'utilisation, le stockage et la protection des données.\\nNous remplacerons plus tard ce texte par la politique réelle.';

  @override
  String get termsTitle => 'Conditions d\'utilisation';

  @override
  String get termsPlaceholder =>
      'Ceci est un texte provisoire pour les conditions d\'utilisation de Foodiy.\\n\\nIci seront décrites les règles d\'utilisation, les limites de responsabilité et autres détails légaux.\\nNous remplacerons ce texte par les conditions réelles ultérieurement.';

  @override
  String get aboutTitle => 'À propos de Foodiy';

  @override
  String get aboutAppName => 'Foodiy';

  @override
  String get aboutVersion => 'Version 0.1.0 (dev)';

  @override
  String get aboutDescription =>
      'Foodiy est votre compagnon personnel de cuisine et de livres de recettes.\\n\\nCréez et suivez des livres de recettes, découvrez des collections de chefs, créez vos propres livres et gérez vos listes de courses — tout au même endroit.';

  @override
  String aboutCopyright(int year) {
    return '© $year Foodiy. Tous droits réservés.';
  }

  @override
  String get homeSectionFailed => 'La section n’a pas pu s’afficher';

  @override
  String homeSectionErrorDetails(Object tag, Object error) {
    return '[$tag] $error';
  }

  @override
  String homeUiError(Object error) {
    return 'Erreur d\'interface : $error';
  }

  @override
  String get discoverSearchHint => 'Rechercher des livres ou des chefs';

  @override
  String get discoverNoCookbooks =>
      'Aucun livre de recettes public pour l’instant';

  @override
  String get discoverPublicBadge => 'Public';

  @override
  String get discoverCategoryBreakfast => 'Petit-déjeuner';

  @override
  String get discoverCategoryBrunch => 'Brunch';

  @override
  String get discoverCategoryQuickWeeknightDinners =>
      'Dîners rapides en semaine';

  @override
  String get discoverCategoryFridayLunch => 'Déjeuner du vendredi';

  @override
  String get discoverCategoryComfortFood => 'Cuisine réconfortante';

  @override
  String get discoverCategoryBakingBasics => 'Bases de boulangerie';

  @override
  String get discoverCategoryBreadAndDough => 'Pains et pâtes';

  @override
  String get discoverCategoryPastries => 'Pâtisseries';

  @override
  String get discoverCategoryCakesAndDesserts => 'Gâteaux et desserts';

  @override
  String get discoverCategoryCookiesAndSmallSweets =>
      'Biscuits et petites douceurs';

  @override
  String get discoverCategoryChocolateLovers => 'Passion chocolat';

  @override
  String get discoverCategoryHealthyAndLight => 'Sain et léger';

  @override
  String get discoverCategoryHighProtein => 'Riche en protéines';

  @override
  String get discoverCategoryVegetarian => 'Végétarien';

  @override
  String get discoverCategoryVegan => 'Végan';

  @override
  String get discoverCategoryGlutenFree => 'Sans gluten';

  @override
  String get discoverCategoryOnePotMeals => 'Plats tout-en-un';

  @override
  String get discoverCategorySoupsAndStews => 'Soupes et ragoûts';

  @override
  String get discoverCategorySalads => 'Salades';

  @override
  String get discoverCategoryPastaAndRisotto => 'Pâtes et risotto';

  @override
  String get discoverCategoryRiceAndGrains => 'Riz et céréales';

  @override
  String get discoverCategoryMiddleEastern => 'Moyen-Orient';

  @override
  String get discoverCategoryItalianClassics => 'Classiques italiens';

  @override
  String get discoverCategoryAsianInspired => 'Inspiration asiatique';

  @override
  String get discoverCategoryStreetFood => 'Street food';

  @override
  String get discoverCategoryFamilyFavorites => 'Favoris de la famille';

  @override
  String get discoverCategoryHostingAndHolidays => 'Réceptions et fêtes';

  @override
  String get discoverCategoryMealPrep => 'Préparation des repas';

  @override
  String get discoverCategoryKidsFriendly => 'Adapté aux enfants';

  @override
  String get discoverCategoryLateNightCravings => 'Envies nocturnes';

  @override
  String get cookbooksLoadError =>
      'Échec de la synchronisation des livres. Réessayez.';

  @override
  String get cookbooksEmptyTitle =>
      'Vous n’avez pas encore de livres de recettes';

  @override
  String get cookbooksEmptyBody => 'Créez votre premier livre de recettes';

  @override
  String get cookbooksUntitled => 'Livre de recettes sans titre';

  @override
  String get cookbooksPrivateBadge => 'Privé';

  @override
  String cookbooksRecipeCount(int count) {
    return '$count recettes';
  }

  @override
  String get cookbooksChefCookbookSuffix => 'Livre de chef';

  @override
  String get cookbooksActionRename => 'Renommer';

  @override
  String get cookbooksActionShare => 'Partager';

  @override
  String get cookbooksActionDelete => 'Supprimer';

  @override
  String get cookbooksMissing => 'Ce livre n’existe plus';

  @override
  String cookbooksCreateFailed(Object error) {
    return 'Impossible de créer le livre : $error';
  }

  @override
  String get cookbooksRenameTitle => 'Renommer le livre';

  @override
  String get cookbooksRenameNewName => 'Nouveau nom';

  @override
  String get cookbooksNameRequired => 'Le nom est requis';

  @override
  String get cookbooksSave => 'Enregistrer';

  @override
  String get cookbooksDeleteTitle => 'Supprimer le livre';

  @override
  String cookbooksDeleteMessage(Object name) {
    return 'Supprimer \"$name\" ?';
  }

  @override
  String cookbooksShareSubject(Object name) {
    return 'Livre de recettes : $name';
  }

  @override
  String get cookbooksCategoryLimit =>
      'Vous pouvez choisir jusqu’à 5 catégories';

  @override
  String get cookbooksCategoryPublicRequired =>
      'Sélectionnez 1 à 5 catégories pour les livres publics';

  @override
  String get cookbooksPublicSubtitle =>
      'Les livres publics sont visibles par tous';

  @override
  String get cookbooksBasicsTitle => 'Bases';

  @override
  String get cookbooksNameLabel => 'Nom du livre';

  @override
  String get cookbooksChooseImage => 'Choisir une image';

  @override
  String get cookbooksCategoriesTitle => 'Catégories';

  @override
  String get cookbooksCategoriesPublicHint =>
      'Sélectionnez 1 à 5 catégories pour que l’on trouve votre livre.';

  @override
  String get cookbooksCategoriesPrivateHint =>
      'Facultatif : ajoutez jusqu’à 5 catégories.';

  @override
  String cookbooksCategoriesSelected(int count) {
    return '$count/5 sélectionnées';
  }

  @override
  String get cookbooksCreateTitle => 'Créer un livre';

  @override
  String get cookbooksBack => 'Retour';

  @override
  String get cookbooksNext => 'Suivant';

  @override
  String get cookbooksCreate => 'Créer';

  @override
  String get recipeDifficultyMedium => 'Moyenne';

  @override
  String recipeSaveSuccess(Object title) {
    return 'Recette \"$title\" enregistrée et ajoutée à Mes recettes';
  }

  @override
  String recipeSaveFailed(Object error) {
    return 'Échec de l’enregistrement/publication de la recette : $error';
  }

  @override
  String get recipeCreateTitle => 'Créer une recette';

  @override
  String get recipeEditTitle => 'Modifier la recette';

  @override
  String get recipeOnlyChefBody =>
      'Seuls les comptes chef peuvent importer des recettes.\n\nPassez à un plan chef pour créer des recettes.';

  @override
  String get recipeFreePlanLimitBody =>
      'Vous avez atteint la limite d’import du plan chef gratuit.\n\nPassez à chef premium pour créer plus de recettes.';

  @override
  String get recipePhotoLabel => 'Photo de la recette';

  @override
  String get recipeTakePhoto => 'Prendre une photo';

  @override
  String get recipePhotoLibrary => 'Bibliothèque de photos';

  @override
  String get recipePickFile => 'Fichiers';

  @override
  String get recipeUploadLimitBanner =>
      'Plan chef gratuit : import de recettes limité.\nPassez à chef premium pour supprimer cette limite.';

  @override
  String get recipeTitleLabel => 'Titre de la recette';

  @override
  String get recipeIngredientsTitle => 'Ingrédients';

  @override
  String get recipeIngredientLabel => 'Ingrédient';

  @override
  String get recipeQuantityLabel => 'Qté';

  @override
  String get recipeUnitLabel => 'Unité';

  @override
  String get recipeAddIngredient => 'Ajouter un ingrédient';

  @override
  String get recipeToolsTitle => 'Outils / Équipement';

  @override
  String get recipeToolLabel => 'Outil';

  @override
  String get recipeAddTool => 'Ajouter un outil';

  @override
  String get recipePreCookingTitle => 'Préparation avant cuisson';

  @override
  String get recipePreCookingHint =>
      'Exemple : préchauffer le four à 200°C, chemiser le plat, faire tremper les haricots toute la nuit...';

  @override
  String get recipeStepsTitle => 'Étapes';

  @override
  String get recipeAddStep => 'Ajouter une étape';

  @override
  String get recipePreviewInPlayer => 'Prévisualiser dans le lecteur';

  @override
  String get recipeUpdateButton => 'Mettre à jour la recette';

  @override
  String get recipeSaveButton => 'Enregistrer la recette';

  @override
  String get recipeStepLabel => 'Étape';

  @override
  String get recipeStepMinutesLabel => 'min';

  @override
  String get recipeRemoveStepTooltip => 'Supprimer l’étape';

  @override
  String get recipeDeleteButton => 'Supprimer la recette';

  @override
  String get recipeDeleteStep1Title => 'Supprimer la recette ?';

  @override
  String get recipeDeleteStep1Body =>
      'Voulez-vous vraiment supprimer cette recette ?';

  @override
  String get recipeDeleteStep1Continue => 'Continuer';

  @override
  String get recipeDeleteStep2Title => 'Action définitive';

  @override
  String get recipeDeleteStep2Body =>
      'Supprimer cette recette la retirera définitivement.';

  @override
  String get recipeDeleteStep2Delete => 'Supprimer';

  @override
  String recipeDeleteFailed(Object error) {
    return 'Impossible de supprimer la recette : $error';
  }

  @override
  String get importDocTitle => 'Importer une recette depuis un document';

  @override
  String get importDocHeader => 'Importez une recette à partir d’un document';

  @override
  String get importDocBody =>
      'Choisissez un fichier ou une photo de recette nette. Nous garderons tout stable pendant la lecture et la création de la recette.';

  @override
  String get importDocFileReady => 'Fichier prêt';

  @override
  String get importDocAddDocument => 'Ajouter un document de recette';

  @override
  String get importDocFormatsShort => 'PDF, DOCX, JPG, PNG, WEBP';

  @override
  String get importDocProcessingNote =>
      'Nous garderons votre envoi stable pendant le traitement.';

  @override
  String get importDocEmptyHelper =>
      'Aucun fichier choisi pour le moment. Ajoutez un fichier ou une photo claire pour continuer.';

  @override
  String get importDocChooseFile => 'Choisir un fichier';

  @override
  String get importDocChoosePhoto => 'Choisir une photo';

  @override
  String get importDocTakePhoto => 'Prendre une photo';

  @override
  String get importDocTipsTitle => 'Conseils pour un import serein';

  @override
  String get importDocTip1 =>
      'Utilisez une photo bien éclairée avec la recette entièrement visible.';

  @override
  String get importDocTip2 =>
      'Restez sur cet écran jusqu’à ce que nous vous dirigions vers la recette.';

  @override
  String get importDocTip3 =>
      'Vous pourrez modifier les détails une fois l’import terminé.';

  @override
  String get importDocUpload => 'Téléverser et importer';

  @override
  String get importDocSupportedFooter =>
      'Formats pris en charge : PDF, DOC, DOCX, JPG, PNG, WEBP. Les fichiers volumineux peuvent prendre plus de temps à traiter.';

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
