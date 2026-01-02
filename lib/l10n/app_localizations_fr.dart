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
}
