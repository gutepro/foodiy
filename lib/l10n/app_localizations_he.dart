// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get homeTitle => 'דף הבית';

  @override
  String get myRecipesTitle => 'המתכונים שלי';

  @override
  String get backToHomeButton => 'חזרה לדף הבית';

  @override
  String get homeLoadErrorTitle => 'היו לנו בעיות בטעינת מתכונים.';

  @override
  String get untitledRecipe => 'מתכון ללא שם';

  @override
  String get deleteRecipeTooltip => 'מחק מתכון';

  @override
  String get noRecipesYet => 'אין מתכונים עדיין';

  @override
  String get homeLoadErrorHeadline => 'היו לנו בעיות בטעינת התוכן שלך.';

  @override
  String get homeLoadErrorDescription =>
      'המתכונים והספרים שלך בטוחים. אפשר לנסות שוב או לחזור לדף הבית.';

  @override
  String get tryAgain => 'נסה שוב';

  @override
  String get homeChefPlaceholder => 'שף';

  @override
  String homeGreetingChef(Object name) {
    return 'היי $name, מוכן לבשל?';
  }

  @override
  String homeGreetingUser(Object name) {
    return 'היי $name, ברוך הבא';
  }

  @override
  String get homeUploadPromptChef =>
      'העלה מתכון והפוך אותו לחוויה רגועה, שלב-אחר-שלב.';

  @override
  String get homeUploadPromptUser =>
      'גלה מתכונים וספרים. העלאות מיועדות לשפים.';

  @override
  String get homeUploadRecipe => 'העלה מתכון';

  @override
  String get homeCreateManual => 'צור ידנית';

  @override
  String homeFreeChefLimit(int limit) {
    return 'שפים חינמיים יכולים לפרסם עד $limit מתכונים.';
  }

  @override
  String get homeUpgradeToChef => 'הפוך לשף כדי להעלות';

  @override
  String get homeShoppingListTooltip => 'רשימת קניות';

  @override
  String get homeSearchTooltip => 'חיפוש';

  @override
  String get homeResumeCookingTitle => 'המשך בישול';

  @override
  String get homeNotNow => 'לא עכשיו';

  @override
  String homeStepRemaining(int step, Object time) {
    return 'שלב $step • נותרו $time';
  }

  @override
  String get homeResumeButton => 'המשך';

  @override
  String get homeMyCookbooks => 'ספרי הבישול שלי';

  @override
  String get homeSeeAll => 'הצג הכל';

  @override
  String get homeNoCookbooks => 'אין ספרי בישול עדיין';

  @override
  String get homeLoadingRecipesTimeout => 'טעינת מתכונים חרגה מהזמן.';

  @override
  String get homeUploadsForChefsTitle => 'העלאות מיועדות לשפים';

  @override
  String get homeUploadsForChefsBody =>
      'הפוך לשף כדי להוסיף ולארגן מתכונים משלך.';

  @override
  String get homeBecomeChefButton => 'הפוך לשף';

  @override
  String get homeUploadDocBody =>
      'העלה מסמך מתכון כדי להתחיל את ספר המתכונים האישי.';

  @override
  String get homeUploadsForChefsSnackbar =>
      'העלאות מיועדות לשפים. הפוך לשף כדי להוסיף מתכונים.';

  @override
  String get homeDeleteRecipeTitle => 'מחק מתכון';

  @override
  String homeDeleteRecipeMessage(Object title) {
    return 'האם למחוק את \"$title\"? לא ניתן לבטל.';
  }

  @override
  String get homeCancel => 'בטל';

  @override
  String get homeDelete => 'מחק';

  @override
  String get homeRecipeDeleted => 'המתכון נמחק';

  @override
  String homeDeleteRecipeFailed(Object error) {
    return 'מחיקת המתכון נכשלה: $error';
  }

  @override
  String get profileTitle => 'פרופיל';

  @override
  String get profileAnonymousUser => 'משתמש אנונימי';

  @override
  String get profileNoEmail => 'אין אימייל';

  @override
  String get profileEditChefProfile => 'עריכת פרופיל שף';

  @override
  String get profileAccountTypeChef => 'חשבון שף';

  @override
  String get profileAccountTypeUser => 'חשבון משתמש רגיל';

  @override
  String get profilePlanBillingTitle => 'תוכנית וחיוב';

  @override
  String get profileSubscriptionTitle => 'צפה במנוי שלי';

  @override
  String get profileSubscriptionSubtitle =>
      'ראה את התוכנית הנוכחית ואפשרויות השדרוג';

  @override
  String get profileChefToolsTitle => 'כלי שף';

  @override
  String get profileRecentActivityTitle => 'פעילות אחרונה';

  @override
  String get profileSeeAll => 'הצג הכל';

  @override
  String get profileNoRecentActivity => 'אין פעילות אחרונה עדיין';

  @override
  String get profileSettingsTitle => 'הגדרות';

  @override
  String get profileOpenSettings => 'פתח הגדרות';

  @override
  String get profileOpenSettingsSubtitle => 'חשבון, העדפות ועוד';

  @override
  String get profileUserTypeFreeUser => 'משתמש חינם';

  @override
  String get profileUserTypePremiumUser => 'משתמש פרימיום';

  @override
  String get profileUserTypeFreeChef => 'שף חינם';

  @override
  String get profileUserTypePremiumChef => 'שף פרימיום';

  @override
  String get profileChefDashboardUnavailable =>
      'לוח הבקרה לשף זמין לחשבונות שף.';

  @override
  String get profileChefDashboardTitle => 'לוח בקרה לשף';

  @override
  String get profileChefDashboardSubtitle => 'נהל את התוכן שלך ב-Foodiy';

  @override
  String get profileUploadRecipe => 'העלה מתכון';

  @override
  String get profileCreateCookbook => 'צור ספר מתכונים';

  @override
  String get profileChefInsights => 'תובנות שף';

  @override
  String profileFreeChefLimitMessage(int limit, int current) {
    return 'שפים חינמיים יכולים לפרסם עד $limit מתכונים.\\nמתכונים: $current / $limit';
  }

  @override
  String get profileUpgradeToPremiumChef => 'שדרג לשף פרימיום';

  @override
  String get profileStatMyRecipes => 'המתכונים שלי';

  @override
  String get profileStatMyCookbooks => 'ספרי המתכונים שלי';

  @override
  String get profileStatFollowers => 'עוקבים';

  @override
  String get profileStatChefInsights => 'תובנות שף';

  @override
  String get profileInsightsDescription => 'התוכן שלך גלוי ונמצא ב-Foodiy.';

  @override
  String get profileInsightsRecipes => 'מתכונים';

  @override
  String get profileInsightsCookbooks => 'ספרי מתכונים';

  @override
  String get profileInsightsFollowers => 'עוקבים';

  @override
  String get profileInsightsPremiumNote =>
      'שפים פרימיום נהנים מפחות מגבלות וחוויה נקייה יותר.';

  @override
  String get profileInsightsClose => 'סגור';

  @override
  String profileStepsCount(int count) {
    return '$count שלבים';
  }

  @override
  String get navHome => 'דף הבית';

  @override
  String get navDiscover => 'גילוי';

  @override
  String get navCookbooks => 'ספרי בישול';

  @override
  String get navProfile => 'פרופיל';

  @override
  String get settingsTitle => 'הגדרות';

  @override
  String get settingsPlayTimerSound => 'נגן צליל כשהטיימר מסתיים';

  @override
  String get settingsNotificationsSection => 'התראות';

  @override
  String get settingsNotificationSettings => 'הגדרות התראות';

  @override
  String get settingsNotificationSettingsSubtitle => 'בחר אילו התראות לקבל';

  @override
  String get settingsAccountSection => 'חשבון';

  @override
  String get settingsEditPersonalDetails => 'ערוך פרטים אישיים';

  @override
  String get settingsChangePassword => 'שינוי סיסמה';

  @override
  String get settingsLogout => 'התנתק';

  @override
  String get settingsLogoutFail => 'ההתנתקות נכשלה. נסה שוב.';

  @override
  String get settingsDeleteAccount => 'מחק חשבון';

  @override
  String get settingsPreferencesSection => 'העדפות אפליקציה';

  @override
  String get settingsLanguageUnits => 'שפה ויחידות';

  @override
  String get settingsLanguageUnitsSubtitle => 'בחר שפת אפליקציה ויחידות מידה';

  @override
  String get settingsLegalSection => 'מידע משפטי';

  @override
  String get settingsTermsOfUse => 'תנאי שימוש';

  @override
  String get settingsPrivacyPolicy => 'מדיניות פרטיות';

  @override
  String get settingsAboutSection => 'אודות';

  @override
  String get settingsAboutApp => 'אודות Foodiy';

  @override
  String get settingsAboutAppSubtitle => 'למד עוד על האפליקציה';

  @override
  String get languageUnitsTitle => 'שפה ויחידות';

  @override
  String get languageSectionTitle => 'שפה';

  @override
  String get languagePickerLabel => 'שפת האפליקציה';

  @override
  String get languageSystemDefault => 'ברירת מחדל של המכשיר';

  @override
  String get languageEnglish => 'אנגלית';

  @override
  String get languageHebrew => 'עברית';

  @override
  String get languageSpanish => 'ספרדית';

  @override
  String get languageFrench => 'צרפתית';

  @override
  String get languageArabic => 'ערבית';

  @override
  String get languageChinese => 'סינית';

  @override
  String get languageJapanese => 'יפנית';

  @override
  String get languageItalian => 'איטלקית';

  @override
  String get unitsSectionTitle => 'יחידות';

  @override
  String get unitsMetric => 'מטרי (גרמים, צלזיוס)';

  @override
  String get unitsImperial => 'אימפריאלי (כוסות, פרנהייט)';

  @override
  String get notificationTitle => 'התראות';

  @override
  String get notificationPreferencesTitle => 'העדפות התראות';

  @override
  String get notificationNewChefRecipesTitle => 'מתכונים חדשים משפים';

  @override
  String get notificationNewChefRecipesSubtitle =>
      'קבל התראות כשהשפים מפרסמים מתכונים חדשים';

  @override
  String get notificationPlaylistSuggestionsTitle => 'המלצות לפלייליסטים';

  @override
  String get notificationPlaylistSuggestionsSubtitle =>
      'קבל הצעות לפלייליסטים שאולי תאהב';

  @override
  String get notificationAppTipsTitle => 'טיפים ועדכוני אפליקציה';

  @override
  String get privacyTitle => 'מדיניות פרטיות';

  @override
  String get privacyPlaceholder =>
      'זהו טקסט זמני למדיניות הפרטיות של Foodiy.\\n\\nכאן יתואר כיצד נתוני משתמשים נשמרים ומוגנים.\\nבהמשך נחליף את הטקסט הזה במדיניות האמיתית.';

  @override
  String get termsTitle => 'תנאי שימוש';

  @override
  String get termsPlaceholder =>
      'זהו טקסט זמני לתנאי השימוש של Foodiy.\\n\\nכאן יתוארו כללי השימוש באפליקציה והגבלת אחריות.\\nבהמשך נחליף טקסט זה בתנאים האמיתיים.';

  @override
  String get aboutTitle => 'אודות Foodiy';

  @override
  String get aboutAppName => 'Foodiy';

  @override
  String get aboutVersion => 'גרסה 0.1.0 (dev)';

  @override
  String get aboutDescription =>
      'Foodiy היא החבר שלך לבישול ולספרי מתכונים.\\n\\nצור ועקוב אחר ספרי מתכונים, גלה אוספי שפים, בנה ספרים משלך ונהל רשימות קניות – הכל במקום אחד.';

  @override
  String aboutCopyright(int year) {
    return '© $year Foodiy. כל הזכויות שמורות.';
  }

  @override
  String get homeSectionFailed => 'הקטע נכשל בטעינה';

  @override
  String homeSectionErrorDetails(Object tag, Object error) {
    return '[$tag] $error';
  }

  @override
  String homeUiError(Object error) {
    return 'שגיאת ממשק: $error';
  }

  @override
  String get discoverSearchHint => 'חיפוש ספרי מתכונים או שפים';

  @override
  String get discoverNoCookbooks => 'אין עדיין ספרי מתכונים ציבוריים';

  @override
  String get discoverPublicBadge => 'ציבורי';

  @override
  String get discoverCategoryBreakfast => 'ארוחת בוקר';

  @override
  String get discoverCategoryBrunch => 'בראנץ\'';

  @override
  String get discoverCategoryQuickWeeknightDinners =>
      'ארוחות ערב מהירות באמצע שבוע';

  @override
  String get discoverCategoryFridayLunch => 'ארוחת צהריים של שישי';

  @override
  String get discoverCategoryComfortFood => 'אוכל מנחם';

  @override
  String get discoverCategoryBakingBasics => 'יסודות אפייה';

  @override
  String get discoverCategoryBreadAndDough => 'לחם ובצקים';

  @override
  String get discoverCategoryPastries => 'מאפים';

  @override
  String get discoverCategoryCakesAndDesserts => 'עוגות וקינוחים';

  @override
  String get discoverCategoryCookiesAndSmallSweets => 'עוגיות ומתוקים קטנים';

  @override
  String get discoverCategoryChocolateLovers => 'חובבי שוקולד';

  @override
  String get discoverCategoryHealthyAndLight => 'בריא וקליל';

  @override
  String get discoverCategoryHighProtein => 'עשיר בחלבון';

  @override
  String get discoverCategoryVegetarian => 'צמחוני';

  @override
  String get discoverCategoryVegan => 'טבעוני';

  @override
  String get discoverCategoryGlutenFree => 'ללא גלוטן';

  @override
  String get discoverCategoryOnePotMeals => 'ארוחות סיר אחד';

  @override
  String get discoverCategorySoupsAndStews => 'מרקים ותבשילים';

  @override
  String get discoverCategorySalads => 'סלטים';

  @override
  String get discoverCategoryPastaAndRisotto => 'פסטה וריזוטו';

  @override
  String get discoverCategoryRiceAndGrains => 'אורז ודגנים';

  @override
  String get discoverCategoryMiddleEastern => 'מטבח מזרח תיכון';

  @override
  String get discoverCategoryItalianClassics => 'קלאסיקות איטלקיות';

  @override
  String get discoverCategoryAsianInspired => 'בהשראה אסייתית';

  @override
  String get discoverCategoryStreetFood => 'אוכל רחוב';

  @override
  String get discoverCategoryFamilyFavorites => 'מועדפי המשפחה';

  @override
  String get discoverCategoryHostingAndHolidays => 'אירוח וחגים';

  @override
  String get discoverCategoryMealPrep => 'הכנת אוכל מראש';

  @override
  String get discoverCategoryKidsFriendly => 'ידידותי לילדים';

  @override
  String get discoverCategoryLateNightCravings => 'נשנושי לילה';

  @override
  String get cookbooksLoadError => 'סנכרון ספרי המתכונים נכשל. נסה שוב.';

  @override
  String get cookbooksEmptyTitle => 'אין לך עדיין ספרי מתכונים';

  @override
  String get cookbooksEmptyBody => 'צור את ספר המתכונים הראשון שלך';

  @override
  String get cookbooksUntitled => 'ספר מתכונים ללא שם';

  @override
  String get cookbooksPrivateBadge => 'פרטי';

  @override
  String cookbooksRecipeCount(int count) {
    return '$count מתכונים';
  }

  @override
  String get cookbooksChefCookbookSuffix => 'ספר שף';

  @override
  String get cookbooksActionRename => 'שנה שם';

  @override
  String get cookbooksActionShare => 'שתף';

  @override
  String get cookbooksActionDelete => 'מחק';

  @override
  String get cookbooksMissing => 'ספר מתכונים זה כבר לא קיים';

  @override
  String cookbooksCreateFailed(Object error) {
    return 'לא ניתן ליצור ספר מתכונים: $error';
  }

  @override
  String get cookbooksRenameTitle => 'שינוי שם לספר';

  @override
  String get cookbooksRenameNewName => 'שם חדש';

  @override
  String get cookbooksNameRequired => 'חובה להזין שם';

  @override
  String get cookbooksSave => 'שמור';

  @override
  String get cookbooksDeleteTitle => 'מחיקת ספר';

  @override
  String cookbooksDeleteMessage(Object name) {
    return 'למחוק את \"$name\"?';
  }

  @override
  String cookbooksShareSubject(Object name) {
    return 'ספר מתכונים: $name';
  }

  @override
  String get cookbooksCategoryLimit => 'אפשר לבחור עד 5 קטגוריות';

  @override
  String get cookbooksCategoryPublicRequired =>
      'בחר 1-5 קטגוריות לספרי מתכונים ציבוריים';

  @override
  String get cookbooksPublicSubtitle => 'ספרי מתכונים ציבוריים גלויים לאחרים';

  @override
  String get cookbooksBasicsTitle => 'יסודות';

  @override
  String get cookbooksNameLabel => 'שם ספר המתכונים';

  @override
  String get cookbooksChooseImage => 'בחר תמונה';

  @override
  String get cookbooksCategoriesTitle => 'קטגוריות';

  @override
  String get cookbooksCategoriesPublicHint =>
      'בחר 1-5 קטגוריות כדי שאחרים ימצאו את הספר שלך.';

  @override
  String get cookbooksCategoriesPrivateHint => 'רשות: הוסף עד 5 קטגוריות.';

  @override
  String cookbooksCategoriesSelected(int count) {
    return '$count/5 נבחרו';
  }

  @override
  String get cookbooksCreateTitle => 'צור ספר מתכונים';

  @override
  String get cookbooksBack => 'חזרה';

  @override
  String get cookbooksNext => 'הבא';

  @override
  String get cookbooksCreate => 'צור';

  @override
  String get recipeDifficultyMedium => 'בינונית';

  @override
  String recipeSaveSuccess(Object title) {
    return 'המתכון \"$title\" נשמר והתווסף למתכונים שלי';
  }

  @override
  String recipeSaveFailed(Object error) {
    return 'הפעולה נכשלה: $error';
  }

  @override
  String get recipeCreateTitle => 'צור מתכון';

  @override
  String get recipeEditTitle => 'ערוך מתכון';

  @override
  String get recipeOnlyChefBody =>
      'רק חשבונות שף יכולים להעלות מתכונים.\n\nשדרג לתוכנית שף כדי להתחיל ליצור מתכונים.';

  @override
  String get recipeFreePlanLimitBody =>
      'הגעת למגבלת ההעלאה בתוכנית שף חינמית.\n\nשדרג לשף פרימיום כדי ליצור עוד מתכונים.';

  @override
  String get recipePhotoLabel => 'תמונת מתכון';

  @override
  String get recipeTakePhoto => 'צלם תמונה';

  @override
  String get recipePhotoLibrary => 'ספריית תמונות';

  @override
  String get recipePickFile => 'קבצים';

  @override
  String get recipeUploadLimitBanner =>
      'תוכנית שף חינמית - העלאת מתכונים מוגבלת.\nשדרג לשף פרימיום כדי להסיר מגבלה זו.';

  @override
  String get recipeTitleLabel => 'כותרת מתכון';

  @override
  String get recipeIngredientsTitle => 'מרכיבים';

  @override
  String get recipeIngredientLabel => 'מרכיב';

  @override
  String get recipeQuantityLabel => 'כמות';

  @override
  String get recipeUnitLabel => 'יחידה';

  @override
  String get recipeAddIngredient => 'הוסף מרכיב';

  @override
  String get recipeToolsTitle => 'כלים / ציוד';

  @override
  String get recipeToolLabel => 'כלי';

  @override
  String get recipeAddTool => 'הוסף כלי';

  @override
  String get recipePreCookingTitle => 'הכנה לפני הבישול';

  @override
  String get recipePreCookingHint =>
      'לדוגמה: חמם תנור ל-200C, רפד את התבנית, השריית שעועית לילה...';

  @override
  String get recipeStepsTitle => 'שלבים';

  @override
  String get recipeAddStep => 'הוסף שלב';

  @override
  String get recipePreviewInPlayer => 'תצוגה מקדימה בנגן';

  @override
  String get recipeUpdateButton => 'עדכן מתכון';

  @override
  String get recipeSaveButton => 'שמור מתכון';

  @override
  String get recipeStepLabel => 'שלב';

  @override
  String get recipeStepMinutesLabel => 'דק\'';

  @override
  String get recipeRemoveStepTooltip => 'הסר שלב';

  @override
  String get recipeDeleteButton => 'מחק מתכון';

  @override
  String get recipeDeleteStep1Title => 'למחוק את המתכון?';

  @override
  String get recipeDeleteStep1Body => 'האם אתה בטוח שברצונך למחוק את המתכון?';

  @override
  String get recipeDeleteStep1Continue => 'המשך';

  @override
  String get recipeDeleteStep2Title => 'הפעולה אינה הפיכה';

  @override
  String get recipeDeleteStep2Body => 'מחיקת מתכון זה תסיר אותו לצמיתות.';

  @override
  String get recipeDeleteStep2Delete => 'מחק';

  @override
  String recipeDeleteFailed(Object error) {
    return 'המחיקה נכשלה: $error';
  }

  @override
  String get importDocTitle => 'ייבוא מתכון ממסמך';

  @override
  String get importDocHeader => 'ייבוא מתכון מתוך מסמך';

  @override
  String get importDocBody =>
      'בחר קובץ או צילום מתכון נקי. נשמור על יציבות בזמן הקריאה והיצירה של המתכון עבורך.';

  @override
  String get importDocFileReady => 'הקובץ מוכן';

  @override
  String get importDocAddDocument => 'הוסף מסמך מתכון';

  @override
  String get importDocFormatsShort => 'PDF, DOCX, JPG, PNG, WEBP';

  @override
  String get importDocProcessingNote => 'נשמור על ההעלאה יציבה בזמן העיבוד.';

  @override
  String get importDocEmptyHelper =>
      'לא נבחר קובץ עדיין. הוסף קובץ או צילום ברור כדי להמשיך.';

  @override
  String get importDocChooseFile => 'בחר קובץ';

  @override
  String get importDocChoosePhoto => 'בחר תמונה';

  @override
  String get importDocTakePhoto => 'צלם תמונה';

  @override
  String get importDocTipsTitle => 'טיפים ליבוא רגוע';

  @override
  String get importDocTip1 => 'השתמש בתמונה מוארת היטב עם כל המתכון גלוי.';

  @override
  String get importDocTip2 => 'הישאר במסך זה עד שנעביר אותך למתכון.';

  @override
  String get importDocTip3 => 'תוכל לערוך פרטים לאחר סיום היבוא.';

  @override
  String get importDocUpload => 'העלה וייבא';

  @override
  String get importDocSupportedFooter =>
      'נתמך: PDF, DOC, DOCX, JPG, PNG, WEBP. קבצים גדולים עשויים לקחת זמן רב יותר לעיבוד.';

  @override
  String get addButton => 'הוסף';

  @override
  String get addSelected => 'הוסף נבחרים';

  @override
  String get backButton => 'חזרה';

  @override
  String get cancel => 'ביטול';

  @override
  String chefByLine(Object name) {
    return 'מאת $name';
  }

  @override
  String get chefFollowLabel => 'עקוב';

  @override
  String get chefFollowSignInRequired => 'התחבר כדי לעקוב אחרי שפים';

  @override
  String chefFollowUpdateFailed(Object error) {
    return 'עדכון מעקב נכשל: $error';
  }

  @override
  String get chefFollowingLabel => 'עוקב';

  @override
  String get chefMyRecipesSubtitle => 'נהל את המתכונים שלך';

  @override
  String get chefNoCookbooks => 'אין ספרי בישול עדיין';

  @override
  String get chefNotEnabledBody => 'כלי השף זמינים רק לחשבונות שף.';

  @override
  String get chefNotEnabledTitle => 'כלי שף אינם זמינים';

  @override
  String get chefNotFound => 'שף לא נמצא';

  @override
  String get chefPremiumFeaturesBody =>
      'שדרג לשף פרימיום כדי לפתוח פרסום, ספרי בישול ותובנות.';

  @override
  String get chefPremiumFeaturesTitle => 'תכונות פרימיום';

  @override
  String get chefPublicCookbook => 'ציבורי';

  @override
  String get chefUploadNewRecipe => 'העלה מתכון חדש';

  @override
  String get chefUploadNewRecipeSubtitle => 'ייבא מסמך מתכון או צור ידנית.';

  @override
  String cookbooksAddRecipeFailed(Object error) {
    return 'הוספת מתכון נכשלה: $error';
  }

  @override
  String get cookbooksAddRecipes => 'הוסף מתכונים';

  @override
  String get cookbooksAddingRecipes => 'מוסיף מתכונים...';

  @override
  String get cookbooksCoverImage => 'תמונת עטיפה';

  @override
  String get cookbooksDeleteWarning =>
      'למחוק את ספר הבישול? פעולה זו אינה ניתנת לביטול.';

  @override
  String get cookbooksDescriptionLabel => 'תיאור';

  @override
  String get cookbooksEditTitle => 'ערוך ספר בישול';

  @override
  String cookbooksLoadRecipesFailed(Object error) {
    return 'טעינת מתכונים נכשלה: $error';
  }

  @override
  String get cookbooksLoadRecipesFailedDetail =>
      'טעינת מתכונים נכשלה. נסה שוב.';

  @override
  String get cookbooksLoadRecipesFailedSimple => 'טעינת מתכונים נכשלה';

  @override
  String get cookbooksNoRecipesAvailable =>
      'אין מתכונים זמינים בספר הבישול הזה.';

  @override
  String get cookbooksNoRecipesToAdd => 'אין מתכונים זמינים להוספה.';

  @override
  String get cookbooksNoRecipesYet => 'עדיין אין מתכונים בספר הבישול הזה.';

  @override
  String get cookbooksPlaylistTitleLabel => 'כותרת פלייליסט';

  @override
  String get cookbooksPlaylistTitleRequired => 'נא להזין כותרת פלייליסט';

  @override
  String get cookbooksPublicCreateTitle => 'צור ספר בישול ציבורי';

  @override
  String get cookbooksPublicCreated => 'פלייליסט ציבורי נוצר';

  @override
  String get cookbooksPublicLabel => 'ציבורי';

  @override
  String get cookbooksPublicNoRecipesBody =>
      'אין לך מתכונים להוספה עדיין.\nהעלה מתכונים כדי ליצור ספר בישול ציבורי.';

  @override
  String get cookbooksRecipesAdded => 'המתכונים נוספו לספר הבישול';

  @override
  String get cookbooksSaveChanges => 'שמור שינויים';

  @override
  String cookbooksSaveFailed(Object error) {
    return 'השמירה נכשלה: $error';
  }

  @override
  String get cookbooksSaveToMy => 'שמור בספרי הבישול שלי';

  @override
  String cookbooksSavedToMy(Object name) {
    return 'שמרת את $name בספרי הבישול שלך';
  }

  @override
  String get cookbooksSelectAtLeastOneRecipe => 'בחר לפחות מתכון אחד';

  @override
  String get cookbooksSelectRecipes => 'בחר מתכונים';

  @override
  String get cookbooksSelectRecipesToInclude => 'בחר מתכונים לכלול';

  @override
  String get cookbooksUpdated => 'ספר הבישול עודכן';

  @override
  String get discoverChefsToFollow => 'שפים לעקוב אחריהם';

  @override
  String discoverFollowersCount(int count) {
    return '$count עוקבים';
  }

  @override
  String get discoverNoChefsYet => 'אין שפים לעקוב אחריהם עדיין';

  @override
  String durationHours(int hours) {
    return '$hours שעות';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours שעות $minutes דק׳';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes דק׳';
  }

  @override
  String get goHomeButton => 'לדף הבית';

  @override
  String get importDocEmptyFile => 'הקובץ ריק. בחר קובץ אחר.';

  @override
  String get importDocOverlayErrorTitle => 'לא הצלחנו לעבד את הקובץ';

  @override
  String get importDocOverlayProcessing => 'מעבד...';

  @override
  String get importDocOverlayUploading => 'מעלה...';

  @override
  String importDocPickPhotoFailed(Object error) {
    return 'בחירת תמונה נכשלה: $error';
  }

  @override
  String importDocReadBytesFailed(Object error) {
    return 'קריאת הקובץ נכשלה: $error';
  }

  @override
  String get importDocSignInRequired => 'התחבר כדי להעלות מתכונים.';

  @override
  String get importDocStepSaving => 'שומר מתכון';

  @override
  String get importDocStepUnderstanding => 'מבין את המתכון';

  @override
  String get importDocStepUploading => 'מעלה קובץ';

  @override
  String importDocTakePhotoFailed(Object error) {
    return 'צילום נכשל: $error';
  }

  @override
  String get importDocUploadFailed => 'ההעלאה נכשלה';

  @override
  String importDocUploadFailedCode(Object code) {
    return 'ההעלאה נכשלה ($code)';
  }

  @override
  String importDocUploadFailedWithError(Object error) {
    return 'ההעלאה נכשלה: $error';
  }

  @override
  String get importDocUploaded => 'ההעלאה הושלמה';

  @override
  String get importedRecipeTitle => 'מתכון מיובא';

  @override
  String get playlistPlayAll => 'נגן הכל';

  @override
  String get playlistPlayAllNotImplemented => 'נגן הכל עדיין לא נתמך';

  @override
  String playlistPlayerTitle(Object title) {
    return 'פלייליסט - $title';
  }

  @override
  String get playlistStepCookFirstRecipe =>
      'בשל את המתכון הראשון לפי ההוראות שלו.';

  @override
  String get playlistStepCookRemaining => 'בשל את שאר הפלייליסט.';

  @override
  String get playlistStepPrepIngredients => 'הכן מרכיבים למתכון הראשון.';

  @override
  String get playlistStepPrepNextRecipe => 'הכן את המתכון הבא בפלייליסט.';

  @override
  String get recipeAddIngredientsToCart => 'הוסף מרכיבים לעגלה';

  @override
  String get recipeAddToCartFailed => 'ההוספה לעגלה נכשלה';

  @override
  String get recipeAddToCookbook => 'הוסף לספר בישול';

  @override
  String recipeAddToCookbookFailed(Object error) {
    return 'הוספה לספר בישול נכשלה: $error';
  }

  @override
  String get recipeAddToCookbooksTitle => 'הוסף לספרי בישול';

  @override
  String get recipeAddToFavorites => 'הוסף למועדפים';

  @override
  String recipeAddedToCart(int count) {
    return 'נוספו $count פריטים לעגלה';
  }

  @override
  String get recipeAddedToCookbooks => 'נוסף לספרי בישול';

  @override
  String get recipeAddedToFavorites => 'נוסף למועדפים';

  @override
  String get recipeAttachDialogFailed => 'לא ניתן לטעון ספרי בישול';

  @override
  String get recipeCookbooksLoadFailed => 'טעינת ספרי בישול נכשלה';

  @override
  String recipeCoverUploadFailed(Object error) {
    return 'העלאת תמונת עטיפה נכשלה: $error';
  }

  @override
  String get recipeCreateCookbookFirst => 'צור ספר בישול קודם';

  @override
  String get recipeDifficultyEasy => 'קל';

  @override
  String get recipeEditButton => 'ערוך';

  @override
  String get recipeImportFailedBody =>
      'לא הצלחנו לייבא את המתכון. נסה שוב או חזור לדף הבית.';

  @override
  String get recipeImportFailedScreenTitle => 'הייבוא נכשל';

  @override
  String get recipeImportFailedTitle => 'הייבוא נכשל';

  @override
  String get recipeImportNeedsReviewBody =>
      'ייבאנו את המתכון אך הוא דורש בדיקה. אפשר לערוך עכשיו.';

  @override
  String get recipeImportNeedsReviewTitle => 'דורש בדיקה';

  @override
  String get recipeImportProcessingTitle => 'עדיין עובדים על זה';

  @override
  String get recipeImportStepExtractingText => 'מחלץ טקסט';

  @override
  String get recipeImportStepFinalizing => 'מסיים';

  @override
  String get recipeImportStepUnderstanding => 'מבין את המתכון';

  @override
  String get recipeImportStepUploadComplete => 'ההעלאה הושלמה';

  @override
  String get recipeImportTimeoutBody =>
      'זה לוקח יותר זמן מהצפוי. אפשר לנסות שוב או לחזור לדף הבית.';

  @override
  String get recipeImportTimeoutTitle => 'זמן הייבוא פג';

  @override
  String get recipeImportUnknownError => 'שגיאה לא ידועה בייבוא';

  @override
  String get recipeNoIngredients => 'אין מרכיבים עדיין';

  @override
  String get recipeNoIngredientsToAdd => 'אין מרכיבים להוספה';

  @override
  String get recipeNoSteps => 'אין שלבים עדיין';

  @override
  String get recipeNoTools => 'אין כלים רשומים';

  @override
  String get recipeNotFoundBody => 'לא הצלחנו למצוא את המתכון הזה.';

  @override
  String get recipeNotFoundTitle => 'המתכון לא נמצא';

  @override
  String get recipeOcrPreviewLabel => 'תצוגה מקדימה של OCR';

  @override
  String get recipeOriginalLanguageLabel => 'מקורי';

  @override
  String get recipePlayerHandsFreeMode => 'מצב ידיים חופשיות';

  @override
  String get recipePlayerHandsFreeOn => 'מצב ידיים חופשיות פועל';

  @override
  String get recipePlayerNoSteps => 'אין שלבים זמינים';

  @override
  String recipePlayerStepOf(int current, int total) {
    return 'שלב $current מתוך $total';
  }

  @override
  String recipePlayerStepPlaceholder(int number) {
    return 'שלב $number';
  }

  @override
  String get recipePlayerVoiceControl => 'שליטה קולית';

  @override
  String get recipeProcessing => 'מעבד';

  @override
  String get recipeRemoveFromFavorites => 'הסר מהמועדפים';

  @override
  String get recipeRemovedFromFavorites => 'הוסר מהמועדפים';

  @override
  String get recipeSignInToSave => 'התחבר כדי לשמור מתכונים.';

  @override
  String get recipeStartCooking => 'התחל לבשל';

  @override
  String get recipeStepRequired => 'יש למלא שלב';

  @override
  String get recipeTitleRequired => 'יש למלא כותרת';

  @override
  String get recipeTranslateToEnglish => 'תרגם לאנגלית';

  @override
  String recipeTranslatedFrom(Object language) {
    return 'תורגם מ-$language';
  }

  @override
  String get recipeTranslating => 'מתרגם';

  @override
  String get recipeTranslationUnavailable => 'תרגום אינו זמין';

  @override
  String get recipeUnavailableBody => 'המתכון הזה אינו זמין כרגע.';

  @override
  String get recipeUnavailableTitle => 'מתכון לא זמין';

  @override
  String get recipeViewChef => 'צפה בשף';

  @override
  String get recipeViewOriginal => 'צפה במקור';

  @override
  String get recipesLabel => 'מתכונים';

  @override
  String get chefSaveFailed => 'שמירת הפרופיל נכשלה';

  @override
  String get chefEditOwnOnly => 'אפשר לערוך רק את הפרופיל שלך.';

  @override
  String get chefEditAvatarLabel => 'תמונת פרופיל';

  @override
  String get chefEditChangePhoto => 'החלף תמונה';

  @override
  String get chefEditBioLabel => 'ביוגרפיה';

  @override
  String get chefEditBioHint =>
      'ספר לעוקבים על סגנון הבישול, ההתמחויות וההשראות שלך.';

  @override
  String get chefEditMakeChangeToSave => 'בצע שינוי כדי לאפשר שמירה.';

  @override
  String get chefNoRecipesYet => 'עדיין לא פרסמת מתכונים';

  @override
  String get chefLoadRecipesFailed => 'טעינת המתכונים נכשלה. נסה שוב.';

  @override
  String chefRecipeStats(int views, int saves) {
    return 'צפיות: $views • שמירות: $saves';
  }

  @override
  String chefRecipeDeleted(Object title) {
    return 'המתכון \"$title\" נמחק';
  }

  @override
  String get discoverFeaturedCookbooks => 'ספרי בישול מובילים';

  @override
  String get discoverCookbookLoadFailed => 'טעינת ספר הבישול נכשלה';

  @override
  String get discoverCookbookNotFound => 'ספר הבישול לא נמצא';

  @override
  String get discoverCookbookNoRecipes => 'עדיין אין מתכונים בספר הבישול הזה.';

  @override
  String get discoverCookbookNoRecipesAvailable => 'אין מתכונים זמינים.';

  @override
  String get discoverRecipesLoadFailed => 'טעינת מתכונים נכשלה';
}
