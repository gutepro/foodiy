// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get homeTitle => 'Inicio';

  @override
  String get myRecipesTitle => 'Mis recetas';

  @override
  String get backToHomeButton => 'Volver al inicio';

  @override
  String get homeLoadErrorTitle => 'Tuvimos problemas al cargar recetas.';

  @override
  String get untitledRecipe => 'Receta sin título';

  @override
  String get deleteRecipeTooltip => 'Eliminar receta';

  @override
  String get noRecipesYet => 'Aún no hay recetas';

  @override
  String get homeLoadErrorHeadline =>
      'Tuvimos problemas al cargar tu contenido.';

  @override
  String get homeLoadErrorDescription =>
      'Tus recetas y libros están a salvo. Puedes intentarlo de nuevo o volver al inicio.';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get homeChefPlaceholder => 'Chef';

  @override
  String homeGreetingChef(Object name) {
    return 'Hola $name, ¿listo para cocinar?';
  }

  @override
  String homeGreetingUser(Object name) {
    return 'Hola $name, bienvenido de nuevo';
  }

  @override
  String get homeUploadPromptChef =>
      'Sube una receta y conviértela en una experiencia tranquila, paso a paso.';

  @override
  String get homeUploadPromptUser =>
      'Explora recetas y recetarios. Las subidas son para chefs.';

  @override
  String get homeUploadRecipe => 'Subir receta';

  @override
  String get homeCreateManual => 'Crear manualmente';

  @override
  String homeFreeChefLimit(int limit) {
    return 'Los chefs gratuitos pueden publicar hasta $limit recetas.';
  }

  @override
  String get homeUpgradeToChef => 'Hazte chef para subir';

  @override
  String get homeShoppingListTooltip => 'Lista de compras';

  @override
  String get homeSearchTooltip => 'Buscar';

  @override
  String get homeResumeCookingTitle => 'Reanudar cocina';

  @override
  String get homeNotNow => 'Ahora no';

  @override
  String homeStepRemaining(int step, Object time) {
    return 'Paso $step • quedan $time';
  }

  @override
  String get homeResumeButton => 'Reanudar';

  @override
  String get homeMyCookbooks => 'Mis recetarios';

  @override
  String get homeSeeAll => 'Ver todo';

  @override
  String get homeNoCookbooks => 'Aún no hay recetarios';

  @override
  String get homeLoadingRecipesTimeout =>
      'La carga de recetas se demoró demasiado.';

  @override
  String get homeUploadsForChefsTitle => 'Las subidas son para chefs';

  @override
  String get homeUploadsForChefsBody =>
      'Hazte chef para agregar y organizar tus propias recetas.';

  @override
  String get homeBecomeChefButton => 'Hazte chef';

  @override
  String get homeUploadDocBody =>
      'Sube un documento de receta para iniciar tu recetario personal.';

  @override
  String get homeUploadsForChefsSnackbar =>
      'Las subidas son para chefs. Hazte chef para agregar recetas.';

  @override
  String get homeDeleteRecipeTitle => 'Eliminar receta';

  @override
  String homeDeleteRecipeMessage(Object title) {
    return '¿Eliminar \"$title\"? Esto no se puede deshacer.';
  }

  @override
  String get homeCancel => 'Cancelar';

  @override
  String get homeDelete => 'Eliminar';

  @override
  String get homeRecipeDeleted => 'Receta eliminada';

  @override
  String homeDeleteRecipeFailed(Object error) {
    return 'No se pudo eliminar la receta: $error';
  }

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileAnonymousUser => 'Usuario anónimo';

  @override
  String get profileNoEmail => 'Sin correo electrónico';

  @override
  String get profileEditChefProfile => 'Editar perfil de chef';

  @override
  String get profileAccountTypeChef => 'Cuenta de chef';

  @override
  String get profileAccountTypeUser => 'Cuenta de usuario';

  @override
  String get profilePlanBillingTitle => 'Plan y facturación';

  @override
  String get profileSubscriptionTitle => 'Ver mi suscripción';

  @override
  String get profileSubscriptionSubtitle =>
      'Consulta tu plan actual y opciones de mejora';

  @override
  String get profileChefToolsTitle => 'Herramientas de chef';

  @override
  String get profileRecentActivityTitle => 'Actividad reciente';

  @override
  String get profileSeeAll => 'Ver todo';

  @override
  String get profileNoRecentActivity => 'Aún no hay actividad reciente';

  @override
  String get profileSettingsTitle => 'Configuración';

  @override
  String get profileOpenSettings => 'Abrir configuración';

  @override
  String get profileOpenSettingsSubtitle => 'Cuenta, preferencias y más';

  @override
  String get profileUserTypeFreeUser => 'Usuario gratuito';

  @override
  String get profileUserTypePremiumUser => 'Usuario premium';

  @override
  String get profileUserTypeFreeChef => 'Chef gratuito';

  @override
  String get profileUserTypePremiumChef => 'Chef premium';

  @override
  String get profileChefDashboardUnavailable =>
      'El panel de chef está disponible para cuentas de chef.';

  @override
  String get profileChefDashboardTitle => 'Panel de chef';

  @override
  String get profileChefDashboardSubtitle =>
      'Administra tu contenido en Foodiy';

  @override
  String get profileUploadRecipe => 'Subir receta';

  @override
  String get profileCreateCookbook => 'Crear recetario';

  @override
  String get profileChefInsights => 'Insights de chef';

  @override
  String profileFreeChefLimitMessage(int limit, int current) {
    return 'Los chefs gratuitos pueden publicar hasta $limit recetas.\\nRecetas: $current / $limit';
  }

  @override
  String get profileUpgradeToPremiumChef => 'Actualizar a Chef Premium';

  @override
  String get profileStatMyRecipes => 'Mis recetas';

  @override
  String get profileStatMyCookbooks => 'Mis recetarios';

  @override
  String get profileStatFollowers => 'Seguidores';

  @override
  String get profileStatChefInsights => 'Insights de chef';

  @override
  String get profileInsightsDescription =>
      'Tu contenido es visible y se puede descubrir en Foodiy.';

  @override
  String get profileInsightsRecipes => 'Recetas';

  @override
  String get profileInsightsCookbooks => 'Recetarios';

  @override
  String get profileInsightsFollowers => 'Seguidores';

  @override
  String get profileInsightsPremiumNote =>
      'Los chefs premium tienen menos límites y una experiencia más limpia.';

  @override
  String get profileInsightsClose => 'Cerrar';

  @override
  String profileStepsCount(int count) {
    return '$count pasos';
  }

  @override
  String get navHome => 'Inicio';

  @override
  String get navDiscover => 'Descubrir';

  @override
  String get navCookbooks => 'Recetarios';

  @override
  String get navProfile => 'Perfil';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsPlayTimerSound =>
      'Reproducir sonido cuando termine el temporizador';

  @override
  String get settingsNotificationsSection => 'Notificaciones';

  @override
  String get settingsNotificationSettings => 'Ajustes de notificaciones';

  @override
  String get settingsNotificationSettingsSubtitle =>
      'Elige qué notificaciones quieres recibir';

  @override
  String get settingsAccountSection => 'Cuenta';

  @override
  String get settingsEditPersonalDetails => 'Editar datos personales';

  @override
  String get settingsChangePassword => 'Cambiar contraseña';

  @override
  String get settingsLogout => 'Cerrar sesión';

  @override
  String get settingsLogoutFail =>
      'No se pudo cerrar sesión. Inténtalo de nuevo.';

  @override
  String get settingsDeleteAccount => 'Eliminar cuenta';

  @override
  String get settingsPreferencesSection => 'Preferencias de la app';

  @override
  String get settingsLanguageUnits => 'Idioma y unidades';

  @override
  String get settingsLanguageUnitsSubtitle =>
      'Elige el idioma de la app y las unidades de medida';

  @override
  String get settingsLegalSection => 'Legal';

  @override
  String get settingsTermsOfUse => 'Términos de uso';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';

  @override
  String get settingsAboutSection => 'Acerca de';

  @override
  String get settingsAboutApp => 'Acerca de Foodiy';

  @override
  String get settingsAboutAppSubtitle => 'Conoce más sobre esta app';

  @override
  String get languageUnitsTitle => 'Idioma y unidades';

  @override
  String get languageSectionTitle => 'Idioma';

  @override
  String get languagePickerLabel => 'Idioma de la app';

  @override
  String get languageSystemDefault => 'Idioma del sistema';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageHebrew => 'Hebreo';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languageArabic => 'Árabe';

  @override
  String get languageChinese => 'Chino';

  @override
  String get languageJapanese => 'Japonés';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get unitsSectionTitle => 'Unidades';

  @override
  String get unitsMetric => 'Métrico (gramos, Celsius)';

  @override
  String get unitsImperial => 'Imperial (tazas, Fahrenheit)';

  @override
  String get notificationTitle => 'Notificaciones';

  @override
  String get notificationPreferencesTitle => 'Preferencias de notificaciones';

  @override
  String get notificationNewChefRecipesTitle => 'Nuevas recetas de chefs';

  @override
  String get notificationNewChefRecipesSubtitle =>
      'Recibe avisos cuando los chefs publiquen recetas nuevas';

  @override
  String get notificationPlaylistSuggestionsTitle => 'Sugerencias de listas';

  @override
  String get notificationPlaylistSuggestionsSubtitle =>
      'Recibe sugerencias de listas que te podrían gustar';

  @override
  String get notificationAppTipsTitle => 'Consejos y novedades de la app';

  @override
  String get privacyTitle => 'Política de privacidad';

  @override
  String get privacyPlaceholder =>
      'Este es un texto temporal para la política de privacidad de Foodiy.\\n\\nAquí se describirá cómo se usan, guardan y protegen los datos.\\nLuego reemplazaremos este texto por la política real.';

  @override
  String get termsTitle => 'Términos de uso';

  @override
  String get termsPlaceholder =>
      'Este es un texto temporal para los términos de uso de Foodiy.\\n\\nAquí se describirán las reglas de uso, limitaciones de responsabilidad y otros detalles legales.\\nLuego reemplazaremos este texto por los términos reales.';

  @override
  String get aboutTitle => 'Acerca de Foodiy';

  @override
  String get aboutAppName => 'Foodiy';

  @override
  String get aboutVersion => 'Versión 0.1.0 (dev)';

  @override
  String get aboutDescription =>
      'Foodiy es tu asistente personal de cocina y recetarios.\\n\\nCrea y sigue recetarios, descubre colecciones de chefs, arma tus propios libros y gestiona listas de compras, todo en un solo lugar.';

  @override
  String aboutCopyright(int year) {
    return '© $year Foodiy. Todos los derechos reservados.';
  }

  @override
  String get homeSectionFailed => 'La sección no se pudo mostrar';

  @override
  String homeSectionErrorDetails(Object tag, Object error) {
    return '[$tag] $error';
  }

  @override
  String homeUiError(Object error) {
    return 'Error de interfaz: $error';
  }

  @override
  String get discoverSearchHint => 'Buscar recetarios o chefs';

  @override
  String get discoverNoCookbooks => 'Aún no hay recetarios públicos';

  @override
  String get discoverPublicBadge => 'Público';

  @override
  String get discoverCategoryBreakfast => 'Desayuno';

  @override
  String get discoverCategoryBrunch => 'Brunch';

  @override
  String get discoverCategoryQuickWeeknightDinners =>
      'Cenas rápidas entre semana';

  @override
  String get discoverCategoryFridayLunch => 'Almuerzo de viernes';

  @override
  String get discoverCategoryComfortFood => 'Comida reconfortante';

  @override
  String get discoverCategoryBakingBasics => 'Fundamentos de repostería';

  @override
  String get discoverCategoryBreadAndDough => 'Pan y masas';

  @override
  String get discoverCategoryPastries => 'Pasteles';

  @override
  String get discoverCategoryCakesAndDesserts => 'Tortas y postres';

  @override
  String get discoverCategoryCookiesAndSmallSweets =>
      'Galletas y dulces pequeños';

  @override
  String get discoverCategoryChocolateLovers => 'Amantes del chocolate';

  @override
  String get discoverCategoryHealthyAndLight => 'Saludable y ligero';

  @override
  String get discoverCategoryHighProtein => 'Alto en proteína';

  @override
  String get discoverCategoryVegetarian => 'Vegetariano';

  @override
  String get discoverCategoryVegan => 'Vegano';

  @override
  String get discoverCategoryGlutenFree => 'Sin gluten';

  @override
  String get discoverCategoryOnePotMeals => 'Platos de una sola olla';

  @override
  String get discoverCategorySoupsAndStews => 'Sopas y guisos';

  @override
  String get discoverCategorySalads => 'Ensaladas';

  @override
  String get discoverCategoryPastaAndRisotto => 'Pasta y risotto';

  @override
  String get discoverCategoryRiceAndGrains => 'Arroz y cereales';

  @override
  String get discoverCategoryMiddleEastern => 'Medio Oriente';

  @override
  String get discoverCategoryItalianClassics => 'Clásicos italianos';

  @override
  String get discoverCategoryAsianInspired => 'Inspirado en Asia';

  @override
  String get discoverCategoryStreetFood => 'Comida callejera';

  @override
  String get discoverCategoryFamilyFavorites => 'Favoritos de la familia';

  @override
  String get discoverCategoryHostingAndHolidays => 'Recepciones y festivos';

  @override
  String get discoverCategoryMealPrep => 'Preparación de comidas';

  @override
  String get discoverCategoryKidsFriendly => 'Apto para niños';

  @override
  String get discoverCategoryLateNightCravings => 'Antojos nocturnos';

  @override
  String get cookbooksLoadError =>
      'Falló la sincronización de recetarios. Intenta de nuevo.';

  @override
  String get cookbooksEmptyTitle => 'Aún no tienes recetarios';

  @override
  String get cookbooksEmptyBody => 'Crea tu primer recetario personal';

  @override
  String get cookbooksUntitled => 'Recetario sin título';

  @override
  String get cookbooksPrivateBadge => 'Privado';

  @override
  String cookbooksRecipeCount(int count) {
    return '$count recetas';
  }

  @override
  String get cookbooksChefCookbookSuffix => 'Recetario de chef';

  @override
  String get cookbooksActionRename => 'Renombrar';

  @override
  String get cookbooksActionShare => 'Compartir';

  @override
  String get cookbooksActionDelete => 'Eliminar';

  @override
  String get cookbooksMissing => 'Este recetario ya no existe';

  @override
  String cookbooksCreateFailed(Object error) {
    return 'No se pudo crear el recetario: $error';
  }

  @override
  String get cookbooksRenameTitle => 'Renombrar recetario';

  @override
  String get cookbooksRenameNewName => 'Nombre nuevo';

  @override
  String get cookbooksNameRequired => 'El nombre es obligatorio';

  @override
  String get cookbooksSave => 'Guardar';

  @override
  String get cookbooksDeleteTitle => 'Eliminar recetario';

  @override
  String cookbooksDeleteMessage(Object name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String cookbooksShareSubject(Object name) {
    return 'Recetario: $name';
  }

  @override
  String get cookbooksCategoryLimit => 'Puedes seleccionar hasta 5 categorías';

  @override
  String get cookbooksCategoryPublicRequired =>
      'Selecciona de 1 a 5 categorías para recetarios públicos';

  @override
  String get cookbooksPublicSubtitle =>
      'Los recetarios públicos son visibles para otros';

  @override
  String get cookbooksBasicsTitle => 'Básicos';

  @override
  String get cookbooksNameLabel => 'Nombre del recetario';

  @override
  String get cookbooksChooseImage => 'Elegir imagen';

  @override
  String get cookbooksCategoriesTitle => 'Categorías';

  @override
  String get cookbooksCategoriesPublicHint =>
      'Selecciona de 1 a 5 categorías para que encuentren tu recetario.';

  @override
  String get cookbooksCategoriesPrivateHint =>
      'Opcional: añade hasta 5 categorías.';

  @override
  String cookbooksCategoriesSelected(int count) {
    return '$count/5 seleccionadas';
  }

  @override
  String get cookbooksCreateTitle => 'Crear recetario';

  @override
  String get cookbooksBack => 'Atrás';

  @override
  String get cookbooksNext => 'Siguiente';

  @override
  String get cookbooksCreate => 'Crear';

  @override
  String get recipeDifficultyMedium => 'Media';

  @override
  String recipeSaveSuccess(Object title) {
    return 'Receta \"$title\" guardada y añadida a Mis recetas';
  }

  @override
  String recipeSaveFailed(Object error) {
    return 'No se pudo guardar/publicar la receta: $error';
  }

  @override
  String get recipeCreateTitle => 'Crear receta';

  @override
  String get recipeEditTitle => 'Editar receta';

  @override
  String get recipeOnlyChefBody =>
      'Solo las cuentas de chef pueden subir recetas.\n\nMejora a un plan de chef para crear recetas.';

  @override
  String get recipeFreePlanLimitBody =>
      'Has alcanzado el límite de carga del plan de chef gratis.\n\nMejora a chef premium para crear más recetas.';

  @override
  String get recipePhotoLabel => 'Foto de la receta';

  @override
  String get recipeTakePhoto => 'Tomar foto';

  @override
  String get recipePhotoLibrary => 'Galería de fotos';

  @override
  String get recipePickFile => 'Archivos';

  @override
  String get recipeUploadLimitBanner =>
      'Plan de chef gratis: carga de recetas limitada.\nMejora a chef premium para quitar el límite.';

  @override
  String get recipeTitleLabel => 'Título de la receta';

  @override
  String get recipeIngredientsTitle => 'Ingredientes';

  @override
  String get recipeIngredientLabel => 'Ingrediente';

  @override
  String get recipeQuantityLabel => 'Cant.';

  @override
  String get recipeUnitLabel => 'Unidad';

  @override
  String get recipeAddIngredient => 'Agregar ingrediente';

  @override
  String get recipeToolsTitle => 'Herramientas / Equipo';

  @override
  String get recipeToolLabel => 'Herramienta';

  @override
  String get recipeAddTool => 'Agregar herramienta';

  @override
  String get recipePreCookingTitle => 'Preparación antes de cocinar';

  @override
  String get recipePreCookingHint =>
      'Ejemplo: precalienta el horno a 200°C, forra la bandeja, remoja los frijoles toda la noche...';

  @override
  String get recipeStepsTitle => 'Pasos';

  @override
  String get recipeAddStep => 'Agregar paso';

  @override
  String get recipePreviewInPlayer => 'Previsualizar en el reproductor';

  @override
  String get recipeUpdateButton => 'Actualizar receta';

  @override
  String get recipeSaveButton => 'Guardar receta';

  @override
  String get recipeStepLabel => 'Paso';

  @override
  String get recipeStepMinutesLabel => 'min';

  @override
  String get recipeRemoveStepTooltip => 'Quitar paso';

  @override
  String get recipeDeleteButton => 'Eliminar receta';

  @override
  String get recipeDeleteStep1Title => '¿Eliminar receta?';

  @override
  String get recipeDeleteStep1Body =>
      '¿Seguro que quieres eliminar esta receta?';

  @override
  String get recipeDeleteStep1Continue => 'Continuar';

  @override
  String get recipeDeleteStep2Title => 'Esto no se puede deshacer';

  @override
  String get recipeDeleteStep2Body =>
      'Eliminar esta receta la quitará de forma permanente.';

  @override
  String get recipeDeleteStep2Delete => 'Eliminar';

  @override
  String recipeDeleteFailed(Object error) {
    return 'No se pudo eliminar la receta: $error';
  }

  @override
  String get importDocTitle => 'Importar receta desde documento';

  @override
  String get importDocHeader => 'Importa una receta desde un documento';

  @override
  String get importDocBody =>
      'Elige un archivo o foto de receta limpio. Mantendremos todo estable mientras lo leemos y creamos la receta para ti.';

  @override
  String get importDocFileReady => 'Archivo listo';

  @override
  String get importDocAddDocument => 'Agregar un documento de receta';

  @override
  String get importDocFormatsShort => 'PDF, DOCX, JPG, PNG, WEBP';

  @override
  String get importDocProcessingNote =>
      'Mantendremos tu carga estable mientras la procesamos.';

  @override
  String get importDocEmptyHelper =>
      'Aún no has elegido archivo. Agrega un archivo o foto clara para continuar.';

  @override
  String get importDocChooseFile => 'Elegir archivo';

  @override
  String get importDocChoosePhoto => 'Elegir foto';

  @override
  String get importDocTakePhoto => 'Tomar foto';

  @override
  String get importDocTipsTitle => 'Consejos para una importación tranquila';

  @override
  String get importDocTip1 =>
      'Usa una foto bien iluminada con la receta completa visible.';

  @override
  String get importDocTip2 =>
      'Permanece en esta pantalla hasta que te llevemos a la receta.';

  @override
  String get importDocTip3 =>
      'Puedes editar los detalles cuando termine la importación.';

  @override
  String get importDocUpload => 'Subir e importar';

  @override
  String get importDocSupportedFooter =>
      'Compatibles: PDF, DOC, DOCX, JPG, PNG, WEBP. Los archivos grandes pueden tardar más en procesarse.';
}
