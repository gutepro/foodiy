// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get homeTitle => 'Home';

  @override
  String get myRecipesTitle => 'Le mie ricette';

  @override
  String get backToHomeButton => 'Torna alla home';

  @override
  String get homeLoadErrorTitle =>
      'Abbiamo riscontrato un problema nel caricamento delle ricette.';

  @override
  String get untitledRecipe => 'Ricetta senza titolo';

  @override
  String get deleteRecipeTooltip => 'Elimina ricetta';

  @override
  String get noRecipesYet => 'Nessuna ricetta ancora';

  @override
  String get homeLoadErrorHeadline =>
      'Abbiamo riscontrato un problema nel caricamento dei tuoi contenuti.';

  @override
  String get homeLoadErrorDescription =>
      'Le tue ricette e i tuoi ricettari sono al sicuro. Puoi riprovare o tornare alla home.';

  @override
  String get tryAgain => 'Riprova';

  @override
  String get homeChefPlaceholder => 'Chef';

  @override
  String homeGreetingChef(Object name) {
    return 'Ciao $name, pronto a cucinare?';
  }

  @override
  String homeGreetingUser(Object name) {
    return 'Ciao $name, bentornato';
  }

  @override
  String get homeUploadPromptChef =>
      'Carica una ricetta e trasformala in un\'esperienza tranquilla, passo dopo passo.';

  @override
  String get homeUploadPromptUser =>
      'Esplora ricette e ricettari. I caricamenti sono per gli chef.';

  @override
  String get homeUploadRecipe => 'Carica ricetta';

  @override
  String get homeCreateManual => 'Crea manualmente';

  @override
  String homeFreeChefLimit(int limit) {
    return 'Gli chef gratuiti possono pubblicare fino a $limit ricette.';
  }

  @override
  String get homeUpgradeToChef => 'Diventa chef per caricare';

  @override
  String get homeShoppingListTooltip => 'Lista della spesa';

  @override
  String get homeSearchTooltip => 'Cerca';

  @override
  String get homeResumeCookingTitle => 'Riprendi la cucina';

  @override
  String get homeNotNow => 'Non ora';

  @override
  String homeStepRemaining(int step, Object time) {
    return 'Passaggio $step • $time rimanente';
  }

  @override
  String get homeResumeButton => 'Riprendi';

  @override
  String get homeMyCookbooks => 'I miei ricettari';

  @override
  String get homeSeeAll => 'Vedi tutto';

  @override
  String get homeNoCookbooks => 'Nessun ricettario ancora';

  @override
  String get homeLoadingRecipesTimeout => 'Caricamento delle ricette scaduto.';

  @override
  String get homeUploadsForChefsTitle => 'I caricamenti sono per gli chef';

  @override
  String get homeUploadsForChefsBody =>
      'Diventa chef per aggiungere e organizzare le tue ricette.';

  @override
  String get homeBecomeChefButton => 'Diventa chef';

  @override
  String get homeUploadDocBody =>
      'Carica un documento di ricetta per iniziare il tuo ricettario personale.';

  @override
  String get homeUploadsForChefsSnackbar =>
      'I caricamenti sono per gli chef. Diventa chef per aggiungere ricette.';

  @override
  String get homeDeleteRecipeTitle => 'Elimina ricetta';

  @override
  String homeDeleteRecipeMessage(Object title) {
    return 'Eliminare \"$title\"? Non è possibile annullare.';
  }

  @override
  String get homeCancel => 'Annulla';

  @override
  String get homeDelete => 'Elimina';

  @override
  String get homeRecipeDeleted => 'Ricetta eliminata';

  @override
  String homeDeleteRecipeFailed(Object error) {
    return 'Impossibile eliminare la ricetta: $error';
  }

  @override
  String get profileTitle => 'Profilo';

  @override
  String get profileAnonymousUser => 'Utente anonimo';

  @override
  String get profileNoEmail => 'Nessuna email';

  @override
  String get profileEditChefProfile => 'Modifica profilo chef';

  @override
  String get profileAccountTypeChef => 'Account chef';

  @override
  String get profileAccountTypeUser => 'Account utente normale';

  @override
  String get profilePlanBillingTitle => 'Piano e fatturazione';

  @override
  String get profileSubscriptionTitle => 'Visualizza il mio abbonamento';

  @override
  String get profileSubscriptionSubtitle =>
      'Vedi il piano attuale e le opzioni di upgrade';

  @override
  String get profileChefToolsTitle => 'Strumenti chef';

  @override
  String get profileRecentActivityTitle => 'Attività recente';

  @override
  String get profileSeeAll => 'Vedi tutto';

  @override
  String get profileNoRecentActivity => 'Nessuna attività recente';

  @override
  String get profileSettingsTitle => 'Impostazioni';

  @override
  String get profileOpenSettings => 'Apri impostazioni';

  @override
  String get profileOpenSettingsSubtitle => 'Account, preferenze e altro';

  @override
  String get profileUserTypeFreeUser => 'Utente gratuito';

  @override
  String get profileUserTypePremiumUser => 'Utente premium';

  @override
  String get profileUserTypeFreeChef => 'Chef gratuito';

  @override
  String get profileUserTypePremiumChef => 'Chef premium';

  @override
  String get profileChefDashboardUnavailable =>
      'Il pannello chef è disponibile per gli account chef.';

  @override
  String get profileChefDashboardTitle => 'Pannello chef';

  @override
  String get profileChefDashboardSubtitle =>
      'Gestisci i tuoi contenuti su Foodiy';

  @override
  String get profileUploadRecipe => 'Carica ricetta';

  @override
  String get profileCreateCookbook => 'Crea ricettario';

  @override
  String get profileChefInsights => 'Dati chef';

  @override
  String profileFreeChefLimitMessage(int limit, int current) {
    return 'Gli chef gratuiti possono pubblicare fino a $limit ricette.\\nRicette: $current / $limit';
  }

  @override
  String get profileUpgradeToPremiumChef => 'Passa a Chef Premium';

  @override
  String get profileStatMyRecipes => 'Le mie ricette';

  @override
  String get profileStatMyCookbooks => 'I miei ricettari';

  @override
  String get profileStatFollowers => 'Follower';

  @override
  String get profileStatChefInsights => 'Dati chef';

  @override
  String get profileInsightsDescription =>
      'I tuoi contenuti sono visibili e individuabili su Foodiy.';

  @override
  String get profileInsightsRecipes => 'Ricette';

  @override
  String get profileInsightsCookbooks => 'Ricettari';

  @override
  String get profileInsightsFollowers => 'Follower';

  @override
  String get profileInsightsPremiumNote =>
      'Gli chef Premium hanno meno limiti e un\'esperienza più pulita.';

  @override
  String get profileInsightsClose => 'Chiudi';

  @override
  String profileStepsCount(int count) {
    return '$count passaggi';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navDiscover => 'Scopri';

  @override
  String get navCookbooks => 'Ricettari';

  @override
  String get navProfile => 'Profilo';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsPlayTimerSound =>
      'Riproduci un suono al termine del timer';

  @override
  String get settingsNotificationsSection => 'Notifiche';

  @override
  String get settingsNotificationSettings => 'Impostazioni notifiche';

  @override
  String get settingsNotificationSettingsSubtitle =>
      'Scegli quali notifiche vuoi ricevere';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get settingsEditPersonalDetails => 'Modifica dati personali';

  @override
  String get settingsChangePassword => 'Cambia password';

  @override
  String get settingsLogout => 'Esci';

  @override
  String get settingsLogoutFail => 'Disconnessione non riuscita. Riprova.';

  @override
  String get settingsDeleteAccount => 'Elimina account';

  @override
  String get settingsPreferencesSection => 'Preferenze app';

  @override
  String get settingsLanguageUnits => 'Lingua e unità';

  @override
  String get settingsLanguageUnitsSubtitle =>
      'Scegli la lingua dell\'app e le unità di misura';

  @override
  String get settingsLegalSection => 'Legale';

  @override
  String get settingsTermsOfUse => 'Termini di utilizzo';

  @override
  String get settingsPrivacyPolicy => 'Informativa sulla privacy';

  @override
  String get settingsAboutSection => 'Info';

  @override
  String get settingsAboutApp => 'Informazioni su Foodiy';

  @override
  String get settingsAboutAppSubtitle => 'Scopri di più su questa app';

  @override
  String get languageUnitsTitle => 'Lingua e unità';

  @override
  String get languageSectionTitle => 'Lingua';

  @override
  String get languagePickerLabel => 'Lingua dell\'app';

  @override
  String get languageSystemDefault => 'Predefinita di sistema';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageHebrew => 'Ebraico';

  @override
  String get languageSpanish => 'Spagnolo';

  @override
  String get languageFrench => 'Francese';

  @override
  String get languageArabic => 'Arabo';

  @override
  String get languageChinese => 'Cinese';

  @override
  String get languageJapanese => 'Giapponese';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get unitsSectionTitle => 'Unità';

  @override
  String get unitsMetric => 'Metrico (grammi, Celsius)';

  @override
  String get unitsImperial => 'Imperiale (tazze, Fahrenheit)';

  @override
  String get notificationTitle => 'Notifiche';

  @override
  String get notificationPreferencesTitle => 'Preferenze notifiche';

  @override
  String get notificationNewChefRecipesTitle => 'Nuove ricette dai chef';

  @override
  String get notificationNewChefRecipesSubtitle =>
      'Ricevi notifiche quando gli chef pubblicano nuove ricette';

  @override
  String get notificationPlaylistSuggestionsTitle => 'Suggerimenti playlist';

  @override
  String get notificationPlaylistSuggestionsSubtitle =>
      'Ricevi suggerimenti di playlist che potrebbero piacerti';

  @override
  String get notificationAppTipsTitle =>
      'Suggerimenti e aggiornamenti dell\'app';

  @override
  String get privacyTitle => 'Informativa sulla privacy';

  @override
  String get privacyPlaceholder =>
      'Questo è un testo provvisorio per l\'informativa sulla privacy di Foodiy.\\n\\nQui descriveremo come vengono utilizzati, archiviati e protetti i dati.\\nSuccessivamente sostituiremo questo testo con l\'informativa reale.';

  @override
  String get termsTitle => 'Termini di utilizzo';

  @override
  String get termsPlaceholder =>
      'Questo è un testo provvisorio per i termini di utilizzo di Foodiy.\\n\\nQui descriveremo le regole d\'uso, le limitazioni di responsabilità e altri dettagli legali.\\nSuccessivamente sostituiremo questo testo con i termini reali.';

  @override
  String get aboutTitle => 'Informazioni su Foodiy';

  @override
  String get aboutAppName => 'Foodiy';

  @override
  String get aboutVersion => 'Versione 0.1.0 (dev)';

  @override
  String get aboutDescription =>
      'Foodiy è il tuo compagno personale di cucina e ricettari.\\n\\nCrea e segui ricettari, scopri collezioni di chef, crea i tuoi libri e gestisci le liste della spesa, tutto in un unico posto.';

  @override
  String aboutCopyright(int year) {
    return '© $year Foodiy. Tutti i diritti riservati.';
  }

  @override
  String get homeSectionFailed => 'Impossibile mostrare la sezione';

  @override
  String homeSectionErrorDetails(Object tag, Object error) {
    return '[$tag] $error';
  }

  @override
  String homeUiError(Object error) {
    return 'Errore dell\'interfaccia: $error';
  }

  @override
  String get discoverSearchHint => 'Cerca ricettari o chef';

  @override
  String get discoverNoCookbooks => 'Ancora nessun ricettario pubblico';

  @override
  String get discoverPublicBadge => 'Pubblico';

  @override
  String get discoverCategoryBreakfast => 'Colazione';

  @override
  String get discoverCategoryBrunch => 'Brunch';

  @override
  String get discoverCategoryQuickWeeknightDinners =>
      'Cene rapide in settimana';

  @override
  String get discoverCategoryFridayLunch => 'Pranzo del venerdì';

  @override
  String get discoverCategoryComfortFood => 'Comfort food';

  @override
  String get discoverCategoryBakingBasics => 'Basi di panificazione';

  @override
  String get discoverCategoryBreadAndDough => 'Pane e impasti';

  @override
  String get discoverCategoryPastries => 'Pasticceria';

  @override
  String get discoverCategoryCakesAndDesserts => 'Torte e dessert';

  @override
  String get discoverCategoryCookiesAndSmallSweets => 'Biscotti e dolcetti';

  @override
  String get discoverCategoryChocolateLovers => 'Amanti del cioccolato';

  @override
  String get discoverCategoryHealthyAndLight => 'Sano e leggero';

  @override
  String get discoverCategoryHighProtein => 'Alto contenuto proteico';

  @override
  String get discoverCategoryVegetarian => 'Vegetariano';

  @override
  String get discoverCategoryVegan => 'Vegano';

  @override
  String get discoverCategoryGlutenFree => 'Senza glutine';

  @override
  String get discoverCategoryOnePotMeals => 'Piatti in un\'unica pentola';

  @override
  String get discoverCategorySoupsAndStews => 'Zuppe e stufati';

  @override
  String get discoverCategorySalads => 'Insalate';

  @override
  String get discoverCategoryPastaAndRisotto => 'Pasta e risotto';

  @override
  String get discoverCategoryRiceAndGrains => 'Riso e cereali';

  @override
  String get discoverCategoryMiddleEastern => 'Mediorientale';

  @override
  String get discoverCategoryItalianClassics => 'Classici italiani';

  @override
  String get discoverCategoryAsianInspired => 'Ispirazione asiatica';

  @override
  String get discoverCategoryStreetFood => 'Street food';

  @override
  String get discoverCategoryFamilyFavorites => 'Preferiti di famiglia';

  @override
  String get discoverCategoryHostingAndHolidays => 'Ospitalità e feste';

  @override
  String get discoverCategoryMealPrep => 'Preparazione pasti';

  @override
  String get discoverCategoryKidsFriendly => 'A misura di bambino';

  @override
  String get discoverCategoryLateNightCravings => 'Voglie di tarda notte';

  @override
  String get cookbooksLoadError =>
      'Sincronizzazione dei ricettari non riuscita. Riprova.';

  @override
  String get cookbooksEmptyTitle => 'Non hai ancora ricettari';

  @override
  String get cookbooksEmptyBody => 'Crea il tuo primo ricettario personale';

  @override
  String get cookbooksUntitled => 'Ricettario senza titolo';

  @override
  String get cookbooksPrivateBadge => 'Privato';

  @override
  String cookbooksRecipeCount(int count) {
    return '$count ricette';
  }

  @override
  String get cookbooksChefCookbookSuffix => 'Ricettario chef';

  @override
  String get cookbooksActionRename => 'Rinomina';

  @override
  String get cookbooksActionShare => 'Condividi';

  @override
  String get cookbooksActionDelete => 'Elimina';

  @override
  String get cookbooksMissing => 'Questo ricettario non esiste più';

  @override
  String cookbooksCreateFailed(Object error) {
    return 'Impossibile creare il ricettario: $error';
  }

  @override
  String get cookbooksRenameTitle => 'Rinomina ricettario';

  @override
  String get cookbooksRenameNewName => 'Nuovo nome';

  @override
  String get cookbooksNameRequired => 'Il nome è obbligatorio';

  @override
  String get cookbooksSave => 'Salva';

  @override
  String get cookbooksDeleteTitle => 'Elimina ricettario';

  @override
  String cookbooksDeleteMessage(Object name) {
    return 'Eliminare \"$name\"?';
  }

  @override
  String cookbooksShareSubject(Object name) {
    return 'Ricettario: $name';
  }

  @override
  String get cookbooksCategoryLimit => 'Puoi selezionare fino a 5 categorie';

  @override
  String get cookbooksCategoryPublicRequired =>
      'Seleziona 1-5 categorie per i ricettari pubblici';

  @override
  String get cookbooksPublicSubtitle =>
      'I ricettari pubblici sono visibili agli altri';

  @override
  String get cookbooksBasicsTitle => 'Base';

  @override
  String get cookbooksNameLabel => 'Nome del ricettario';

  @override
  String get cookbooksChooseImage => 'Scegli immagine';

  @override
  String get cookbooksCategoriesTitle => 'Categorie';

  @override
  String get cookbooksCategoriesPublicHint =>
      'Seleziona 1-5 categorie perché gli altri trovino il tuo ricettario.';

  @override
  String get cookbooksCategoriesPrivateHint =>
      'Opzionale: aggiungi fino a 5 categorie.';

  @override
  String cookbooksCategoriesSelected(int count) {
    return '$count/5 selezionate';
  }

  @override
  String get cookbooksCreateTitle => 'Crea ricettario';

  @override
  String get cookbooksBack => 'Indietro';

  @override
  String get cookbooksNext => 'Avanti';

  @override
  String get cookbooksCreate => 'Crea';

  @override
  String get recipeDifficultyMedium => 'Media';

  @override
  String recipeSaveSuccess(Object title) {
    return 'Ricetta \"$title\" salvata e aggiunta ai miei ricettari';
  }

  @override
  String recipeSaveFailed(Object error) {
    return 'Impossibile salvare/pubblicare la ricetta: $error';
  }

  @override
  String get recipeCreateTitle => 'Crea ricetta';

  @override
  String get recipeEditTitle => 'Modifica ricetta';

  @override
  String get recipeOnlyChefBody =>
      'Solo gli account chef possono caricare ricette.\n\nPassa a un piano chef per iniziare a creare ricette.';

  @override
  String get recipeFreePlanLimitBody =>
      'Hai raggiunto il limite di caricamenti del piano chef gratuito.\n\nPassa a chef premium per creare altre ricette.';

  @override
  String get recipePhotoLabel => 'Foto della ricetta';

  @override
  String get recipeTakePhoto => 'Scatta una foto';

  @override
  String get recipePhotoLibrary => 'Libreria foto';

  @override
  String get recipePickFile => 'File';

  @override
  String get recipeUploadLimitBanner =>
      'Piano chef gratuito - caricamento ricette limitato.\nPassa a chef premium per rimuovere il limite.';

  @override
  String get recipeTitleLabel => 'Titolo della ricetta';

  @override
  String get recipeIngredientsTitle => 'Ingredienti';

  @override
  String get recipeIngredientLabel => 'Ingrediente';

  @override
  String get recipeQuantityLabel => 'Quantità';

  @override
  String get recipeUnitLabel => 'Unità';

  @override
  String get recipeAddIngredient => 'Aggiungi ingrediente';

  @override
  String get recipeToolsTitle => 'Strumenti / Attrezzatura';

  @override
  String get recipeToolLabel => 'Strumento';

  @override
  String get recipeAddTool => 'Aggiungi strumento';

  @override
  String get recipePreCookingTitle => 'Preparazione prima della cottura';

  @override
  String get recipePreCookingHint =>
      'Ad esempio: preriscaldare il forno a 200°C, foderare la teglia, mettere i fagioli in ammollo tutta la notte...';

  @override
  String get recipeStepsTitle => 'Passaggi';

  @override
  String get recipeAddStep => 'Aggiungi passaggio';

  @override
  String get recipePreviewInPlayer => 'Anteprima nel player';

  @override
  String get recipeUpdateButton => 'Aggiorna ricetta';

  @override
  String get recipeSaveButton => 'Salva ricetta';

  @override
  String get recipeStepLabel => 'Passaggio';

  @override
  String get recipeStepMinutesLabel => 'min';

  @override
  String get recipeRemoveStepTooltip => 'Rimuovi passaggio';

  @override
  String get recipeDeleteButton => 'Elimina ricetta';

  @override
  String get recipeDeleteStep1Title => 'Eliminare la ricetta?';

  @override
  String get recipeDeleteStep1Body =>
      'Sei sicuro di voler eliminare questa ricetta?';

  @override
  String get recipeDeleteStep1Continue => 'Continua';

  @override
  String get recipeDeleteStep2Title => 'Questa azione è definitiva';

  @override
  String get recipeDeleteStep2Body =>
      'Eliminare questa ricetta la rimuoverà in modo permanente.';

  @override
  String get recipeDeleteStep2Delete => 'Elimina';

  @override
  String recipeDeleteFailed(Object error) {
    return 'Impossibile eliminare la ricetta: $error';
  }

  @override
  String get importDocTitle => 'Importa ricetta da documento';

  @override
  String get importDocHeader => 'Importa una ricetta da un documento';

  @override
  String get importDocBody =>
      'Scegli un file o una foto di ricetta pulita. Terremo tutto stabile mentre lo leggiamo e creiamo la ricetta per te.';

  @override
  String get importDocFileReady => 'File pronto';

  @override
  String get importDocAddDocument => 'Aggiungi un documento di ricetta';

  @override
  String get importDocFormatsShort => 'PDF, DOCX, JPG, PNG, WEBP';

  @override
  String get importDocProcessingNote =>
      'Terremo il caricamento stabile durante l\'elaborazione.';

  @override
  String get importDocEmptyHelper =>
      'Nessun file selezionato. Aggiungi un file o foto chiari per continuare.';

  @override
  String get importDocChooseFile => 'Scegli file';

  @override
  String get importDocChoosePhoto => 'Scegli foto';

  @override
  String get importDocTakePhoto => 'Scatta foto';

  @override
  String get importDocTipsTitle => 'Suggerimenti per un import tranquillo';

  @override
  String get importDocTip1 =>
      'Usa una foto ben illuminata con la ricetta completa visibile.';

  @override
  String get importDocTip2 =>
      'Resta su questa schermata finché non ti portiamo alla ricetta.';

  @override
  String get importDocTip3 =>
      'Puoi modificare i dettagli dopo il termine dell\'import.';

  @override
  String get importDocUpload => 'Carica e importa';

  @override
  String get importDocSupportedFooter =>
      'Supportati: PDF, DOC, DOCX, JPG, PNG, WEBP. I file più grandi possono richiedere più tempo per l\'elaborazione.';
}
