// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get homeTitle => 'الصفحة الرئيسية';

  @override
  String get myRecipesTitle => 'وصفاتي';

  @override
  String get backToHomeButton => 'العودة إلى الصفحة الرئيسية';

  @override
  String get homeLoadErrorTitle => 'واجهنا مشكلة في تحميل الوصفات.';

  @override
  String get untitledRecipe => 'وصفة بدون اسم';

  @override
  String get deleteRecipeTooltip => 'حذف الوصفة';

  @override
  String get noRecipesYet => 'لا توجد وصفات بعد';

  @override
  String get homeLoadErrorHeadline => 'واجهنا مشكلة في تحميل المحتوى الخاص بك.';

  @override
  String get homeLoadErrorDescription =>
      'وصفاتك وكتب الطبخ آمنة. يمكنك المحاولة مرة أخرى أو العودة إلى الصفحة الرئيسية.';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get homeChefPlaceholder => 'شيف';

  @override
  String homeGreetingChef(Object name) {
    return 'مرحباً $name، جاهز للطبخ؟';
  }

  @override
  String homeGreetingUser(Object name) {
    return 'مرحباً $name، مرحباً بعودتك';
  }

  @override
  String get homeUploadPromptChef =>
      'ارفع وصفة وحولها لتجربة هادئة خطوة بخطوة.';

  @override
  String get homeUploadPromptUser => 'اكتشف وصفات وكتب طبخ. الرفع مخصص للشيف.';

  @override
  String get homeUploadRecipe => 'رفع وصفة';

  @override
  String get homeCreateManual => 'إنشاء يدوي';

  @override
  String homeFreeChefLimit(int limit) {
    return 'الشيف المجاني يمكنه نشر حتى $limit وصفات.';
  }

  @override
  String get homeUpgradeToChef => 'كن شيف لرفع الوصفات';

  @override
  String get homeShoppingListTooltip => 'قائمة التسوق';

  @override
  String get homeSearchTooltip => 'بحث';

  @override
  String get homeResumeCookingTitle => 'متابعة الطبخ';

  @override
  String get homeNotNow => 'ليس الآن';

  @override
  String homeStepRemaining(int step, Object time) {
    return 'الخطوة $step • متبقي $time';
  }

  @override
  String get homeResumeButton => 'متابعة';

  @override
  String get homeMyCookbooks => 'كتب الطبخ الخاصة بي';

  @override
  String get homeSeeAll => 'عرض الكل';

  @override
  String get homeNoCookbooks => 'لا توجد كتب طبخ بعد';

  @override
  String get homeLoadingRecipesTimeout => 'انتهى وقت تحميل الوصفات.';

  @override
  String get homeUploadsForChefsTitle => 'الرفع مخصص للشيف';

  @override
  String get homeUploadsForChefsBody => 'كن شيفاً لإضافة وتنظيم وصفاتك الخاصة.';

  @override
  String get homeBecomeChefButton => 'كن شيفاً';

  @override
  String get homeUploadDocBody => 'ارفع مستند وصفة لبدء كتابك الشخصي.';

  @override
  String get homeUploadsForChefsSnackbar =>
      'الرفع مخصص للشيف. كن شيفاً لإضافة وصفات.';

  @override
  String get homeDeleteRecipeTitle => 'حذف الوصفة';

  @override
  String homeDeleteRecipeMessage(Object title) {
    return 'هل تريد حذف \"$title\"؟ لا يمكن التراجع.';
  }

  @override
  String get homeCancel => 'إلغاء';

  @override
  String get homeDelete => 'حذف';

  @override
  String get homeRecipeDeleted => 'تم حذف الوصفة';

  @override
  String homeDeleteRecipeFailed(Object error) {
    return 'فشل حذف الوصفة: $error';
  }

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileAnonymousUser => 'مستخدم مجهول';

  @override
  String get profileNoEmail => 'لا يوجد بريد إلكتروني';

  @override
  String get profileEditChefProfile => 'تعديل ملف الشيف';

  @override
  String get profileAccountTypeChef => 'حساب شيف';

  @override
  String get profileAccountTypeUser => 'حساب مستخدم عادي';

  @override
  String get profilePlanBillingTitle => 'الخطة والفوترة';

  @override
  String get profileSubscriptionTitle => 'عرض اشتراكي';

  @override
  String get profileSubscriptionSubtitle =>
      'اطلع على خطتك الحالية وخيارات الترقية';

  @override
  String get profileChefToolsTitle => 'أدوات الشيف';

  @override
  String get profileRecentActivityTitle => 'النشاط الأخير';

  @override
  String get profileSeeAll => 'عرض الكل';

  @override
  String get profileNoRecentActivity => 'لا يوجد نشاط حديث بعد';

  @override
  String get profileSettingsTitle => 'الإعدادات';

  @override
  String get profileOpenSettings => 'فتح الإعدادات';

  @override
  String get profileOpenSettingsSubtitle => 'الحساب، التفضيلات والمزيد';

  @override
  String get profileUserTypeFreeUser => 'مستخدم مجاني';

  @override
  String get profileUserTypePremiumUser => 'مستخدم بريميوم';

  @override
  String get profileUserTypeFreeChef => 'شيف مجاني';

  @override
  String get profileUserTypePremiumChef => 'شيف بريميوم';

  @override
  String get profileChefDashboardUnavailable =>
      'لوحة الشيف متاحة لحسابات الشيف فقط.';

  @override
  String get profileChefDashboardTitle => 'لوحة الشيف';

  @override
  String get profileChefDashboardSubtitle => 'إدارة محتواك على Foodiy';

  @override
  String get profileUploadRecipe => 'رفع وصفة';

  @override
  String get profileCreateCookbook => 'إنشاء كتاب طبخ';

  @override
  String get profileChefInsights => 'إحصائيات الشيف';

  @override
  String profileFreeChefLimitMessage(int limit, int current) {
    return 'يمكن للشيف المجاني نشر ما يصل إلى $limit وصفات.\\nالوصفات: $current / $limit';
  }

  @override
  String get profileUpgradeToPremiumChef => 'الترقية إلى شيف بريميوم';

  @override
  String get profileStatMyRecipes => 'وصفاتي';

  @override
  String get profileStatMyCookbooks => 'كتب الطبخ الخاصة بي';

  @override
  String get profileStatFollowers => 'متابعون';

  @override
  String get profileStatChefInsights => 'إحصائيات الشيف';

  @override
  String get profileInsightsDescription =>
      'محتواك ظاهر وقابل للاكتشاف على Foodiy.';

  @override
  String get profileInsightsRecipes => 'وصفات';

  @override
  String get profileInsightsCookbooks => 'كتب طبخ';

  @override
  String get profileInsightsFollowers => 'متابعون';

  @override
  String get profileInsightsPremiumNote =>
      'يتمتع الشيف البريميوم بقيود أقل وتجربة أنظف.';

  @override
  String get profileInsightsClose => 'إغلاق';

  @override
  String profileStepsCount(int count) {
    return '$count خطوة';
  }

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navDiscover => 'استكشاف';

  @override
  String get navCookbooks => 'كتب الطبخ';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsPlayTimerSound => 'تشغيل صوت عند انتهاء المؤقت';

  @override
  String get settingsNotificationsSection => 'الإشعارات';

  @override
  String get settingsNotificationSettings => 'إعدادات الإشعارات';

  @override
  String get settingsNotificationSettingsSubtitle =>
      'اختر الإشعارات التي تريد استلامها';

  @override
  String get settingsAccountSection => 'الحساب';

  @override
  String get settingsEditPersonalDetails => 'تعديل التفاصيل الشخصية';

  @override
  String get settingsChangePassword => 'تغيير كلمة المرور';

  @override
  String get settingsLogout => 'تسجيل الخروج';

  @override
  String get settingsLogoutFail => 'فشل تسجيل الخروج. حاول مرة أخرى.';

  @override
  String get settingsDeleteAccount => 'حذف الحساب';

  @override
  String get settingsPreferencesSection => 'تفضيلات التطبيق';

  @override
  String get settingsLanguageUnits => 'اللغة والوحدات';

  @override
  String get settingsLanguageUnitsSubtitle => 'اختر لغة التطبيق ووحدات القياس';

  @override
  String get settingsLegalSection => 'بنود قانونية';

  @override
  String get settingsTermsOfUse => 'شروط الاستخدام';

  @override
  String get settingsPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get settingsAboutSection => 'حول';

  @override
  String get settingsAboutApp => 'حول Foodiy';

  @override
  String get settingsAboutAppSubtitle => 'تعرف أكثر على هذا التطبيق';

  @override
  String get languageUnitsTitle => 'اللغة والوحدات';

  @override
  String get languageSectionTitle => 'اللغة';

  @override
  String get languagePickerLabel => 'لغة التطبيق';

  @override
  String get languageSystemDefault => 'إعدادات النظام';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageHebrew => 'العبرية';

  @override
  String get languageSpanish => 'الإسبانية';

  @override
  String get languageFrench => 'الفرنسية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageChinese => 'الصينية';

  @override
  String get languageJapanese => 'اليابانية';

  @override
  String get languageItalian => 'الإيطالية';

  @override
  String get unitsSectionTitle => 'الوحدات';

  @override
  String get unitsMetric => 'متري (غرام، سيلسيوس)';

  @override
  String get unitsImperial => 'إنجليزي (أكواب، فهرنهايت)';

  @override
  String get notificationTitle => 'الإشعارات';

  @override
  String get notificationPreferencesTitle => 'تفضيلات الإشعارات';

  @override
  String get notificationNewChefRecipesTitle => 'وصفات جديدة من الشيف';

  @override
  String get notificationNewChefRecipesSubtitle =>
      'الحصول على إشعار عندما ينشر الشيف وصفات جديدة';

  @override
  String get notificationPlaylistSuggestionsTitle => 'اقتراحات القوائم';

  @override
  String get notificationPlaylistSuggestionsSubtitle =>
      'تلقي اقتراحات لقوائم قد تعجبك';

  @override
  String get notificationAppTipsTitle => 'نصائح وتحديثات التطبيق';

  @override
  String get privacyTitle => 'سياسة الخصوصية';

  @override
  String get privacyPlaceholder =>
      'هذا نص مؤقت لسياسة الخصوصية في Foodiy.\\n\\nهنا سيُشرح كيف تُستخدم بيانات المستخدم وتُحفظ وتُحمى.\\nلاحقاً سنستبدل هذا النص بالسياسة الفعلية.';

  @override
  String get termsTitle => 'شروط الاستخدام';

  @override
  String get termsPlaceholder =>
      'هذا نص مؤقت لشروط الاستخدام في Foodiy.\\n\\nهنا ستُشرح قواعد الاستخدام وحدود المسؤولية وغيرها من التفاصيل القانونية.\\nلاحقاً سنستبدل هذا النص بالشروط الفعلية.';

  @override
  String get aboutTitle => 'حول Foodiy';

  @override
  String get aboutAppName => 'Foodiy';

  @override
  String get aboutVersion => 'الإصدار 0.1.0 (dev)';

  @override
  String get aboutDescription =>
      'Foodiy هو رفيقك الشخصي للطبخ وكتب الوصفات.\\n\\nأنشئ وتابع كتب الوصفات، واكتشف مجموعات الشيف، وابنِ كتبك الخاصة وأدر قوائم التسوق في مكان واحد.';

  @override
  String aboutCopyright(int year) {
    return '© $year Foodiy. كل الحقوق محفوظة.';
  }

  @override
  String get homeSectionFailed => 'فشل عرض القسم';

  @override
  String homeSectionErrorDetails(Object tag, Object error) {
    return '[$tag] $error';
  }

  @override
  String homeUiError(Object error) {
    return 'خطأ في الواجهة: $error';
  }

  @override
  String get discoverSearchHint => 'ابحث عن كتب طبخ أو شيف';

  @override
  String get discoverNoCookbooks => 'لا توجد كتب طبخ عامة بعد';

  @override
  String get discoverPublicBadge => 'عام';

  @override
  String get discoverCategoryBreakfast => 'فطور';

  @override
  String get discoverCategoryBrunch => 'فطور متأخر';

  @override
  String get discoverCategoryQuickWeeknightDinners => 'عشاء سريع لأيام الأسبوع';

  @override
  String get discoverCategoryFridayLunch => 'غداء الجمعة';

  @override
  String get discoverCategoryComfortFood => 'طعام مريح';

  @override
  String get discoverCategoryBakingBasics => 'أساسيات الخَبز';

  @override
  String get discoverCategoryBreadAndDough => 'خبز وعجائن';

  @override
  String get discoverCategoryPastries => 'معجنات';

  @override
  String get discoverCategoryCakesAndDesserts => 'كيك وحلويات';

  @override
  String get discoverCategoryCookiesAndSmallSweets => 'بسكويت وحلويات صغيرة';

  @override
  String get discoverCategoryChocolateLovers => 'عشاق الشوكولاتة';

  @override
  String get discoverCategoryHealthyAndLight => 'صحي وخفيف';

  @override
  String get discoverCategoryHighProtein => 'عالي البروتين';

  @override
  String get discoverCategoryVegetarian => 'نباتي';

  @override
  String get discoverCategoryVegan => 'نباتي صارم';

  @override
  String get discoverCategoryGlutenFree => 'خالٍ من الغلوتين';

  @override
  String get discoverCategoryOnePotMeals => 'وجبات بقدر واحد';

  @override
  String get discoverCategorySoupsAndStews => 'شوربات ويخنات';

  @override
  String get discoverCategorySalads => 'سلطات';

  @override
  String get discoverCategoryPastaAndRisotto => 'معكرونة وريزوتو';

  @override
  String get discoverCategoryRiceAndGrains => 'أرز وحبوب';

  @override
  String get discoverCategoryMiddleEastern => 'مطبخ شرق أوسطي';

  @override
  String get discoverCategoryItalianClassics => 'كلاسيكيات إيطالية';

  @override
  String get discoverCategoryAsianInspired => 'مستوحى من آسيا';

  @override
  String get discoverCategoryStreetFood => 'أكل شارع';

  @override
  String get discoverCategoryFamilyFavorites => 'مفضلات العائلة';

  @override
  String get discoverCategoryHostingAndHolidays => 'ضيافة وأعياد';

  @override
  String get discoverCategoryMealPrep => 'تحضير وجبات مسبقاً';

  @override
  String get discoverCategoryKidsFriendly => 'مناسب للأطفال';

  @override
  String get discoverCategoryLateNightCravings => 'رغبات ليلية';

  @override
  String get cookbooksLoadError => 'فشل مزامنة كتب الطبخ. حاول مرة أخرى.';

  @override
  String get cookbooksEmptyTitle => 'ليس لديك كتب طبخ بعد';

  @override
  String get cookbooksEmptyBody => 'أنشئ أول كتاب طبخ شخصي';

  @override
  String get cookbooksUntitled => 'كتاب طبخ بدون اسم';

  @override
  String get cookbooksPrivateBadge => 'خاص';

  @override
  String cookbooksRecipeCount(int count) {
    return '$count وصفات';
  }

  @override
  String get cookbooksChefCookbookSuffix => 'كتاب شيف';

  @override
  String get cookbooksActionRename => 'إعادة تسمية';

  @override
  String get cookbooksActionShare => 'مشاركة';

  @override
  String get cookbooksActionDelete => 'حذف';

  @override
  String get cookbooksMissing => 'هذا الكتاب لم يعد موجوداً';

  @override
  String cookbooksCreateFailed(Object error) {
    return 'تعذر إنشاء كتاب الطبخ: $error';
  }

  @override
  String get cookbooksRenameTitle => 'إعادة تسمية كتاب';

  @override
  String get cookbooksRenameNewName => 'اسم جديد';

  @override
  String get cookbooksNameRequired => 'الاسم مطلوب';

  @override
  String get cookbooksSave => 'حفظ';

  @override
  String get cookbooksDeleteTitle => 'حذف كتاب';

  @override
  String cookbooksDeleteMessage(Object name) {
    return 'حذف \"$name\"؟';
  }

  @override
  String cookbooksShareSubject(Object name) {
    return 'كتاب طبخ: $name';
  }

  @override
  String get cookbooksCategoryLimit => 'يمكنك اختيار حتى 5 فئات';

  @override
  String get cookbooksCategoryPublicRequired =>
      'اختر 1-5 فئات لكتب الطبخ العامة';

  @override
  String get cookbooksPublicSubtitle => 'كتب الطبخ العامة مرئية للآخرين';

  @override
  String get cookbooksBasicsTitle => 'الأساسيات';

  @override
  String get cookbooksNameLabel => 'اسم كتاب الطبخ';

  @override
  String get cookbooksChooseImage => 'اختر صورة';

  @override
  String get cookbooksCategoriesTitle => 'الفئات';

  @override
  String get cookbooksCategoriesPublicHint =>
      'اختر 1-5 فئات ليتمكن الآخرون من العثور على كتابك.';

  @override
  String get cookbooksCategoriesPrivateHint => 'اختياري: أضف حتى 5 فئات.';

  @override
  String cookbooksCategoriesSelected(int count) {
    return '$count/5 محددة';
  }

  @override
  String get cookbooksCreateTitle => 'إنشاء كتاب طبخ';

  @override
  String get cookbooksBack => 'رجوع';

  @override
  String get cookbooksNext => 'التالي';

  @override
  String get cookbooksCreate => 'إنشاء';

  @override
  String get recipeDifficultyMedium => 'متوسطة';

  @override
  String recipeSaveSuccess(Object title) {
    return 'تم حفظ الوصفة \"$title\" وإضافتها إلى وصفاتي';
  }

  @override
  String recipeSaveFailed(Object error) {
    return 'تعذر حفظ/نشر الوصفة: $error';
  }

  @override
  String get recipeCreateTitle => 'إنشاء وصفة';

  @override
  String get recipeEditTitle => 'تعديل وصفة';

  @override
  String get recipeOnlyChefBody =>
      'فقط حسابات الشيف يمكنها رفع الوصفات.\n\nقم بالترقية إلى خطة شيف لبدء إنشاء الوصفات.';

  @override
  String get recipeFreePlanLimitBody =>
      'لقد وصلت إلى حد الرفع في خطة الشيف المجانية.\n\nقم بالترقية إلى شيف مميز لإنشاء المزيد من الوصفات.';

  @override
  String get recipePhotoLabel => 'صورة الوصفة';

  @override
  String get recipeTakePhoto => 'التقاط صورة';

  @override
  String get recipePhotoLibrary => 'معرض الصور';

  @override
  String get recipePickFile => 'الملفات';

  @override
  String get recipeUploadLimitBanner =>
      'خطة الشيف المجانية - رفع الوصفات محدود.\nقم بالترقية إلى شيف مميز لإزالة الحد.';

  @override
  String get recipeTitleLabel => 'عنوان الوصفة';

  @override
  String get recipeIngredientsTitle => 'المكونات';

  @override
  String get recipeIngredientLabel => 'مكون';

  @override
  String get recipeQuantityLabel => 'الكمية';

  @override
  String get recipeUnitLabel => 'الوحدة';

  @override
  String get recipeAddIngredient => 'إضافة مكون';

  @override
  String get recipeToolsTitle => 'أدوات / معدات';

  @override
  String get recipeToolLabel => 'أداة';

  @override
  String get recipeAddTool => 'إضافة أداة';

  @override
  String get recipePreCookingTitle => 'التحضير قبل الطهي';

  @override
  String get recipePreCookingHint =>
      'مثال: سخّن الفرن إلى 200 م°, غطِّ الصينية، انقع الفاصوليا طوال الليل...';

  @override
  String get recipeStepsTitle => 'الخطوات';

  @override
  String get recipeAddStep => 'إضافة خطوة';

  @override
  String get recipePreviewInPlayer => 'معاينة في المشغل';

  @override
  String get recipeUpdateButton => 'تحديث الوصفة';

  @override
  String get recipeSaveButton => 'حفظ الوصفة';

  @override
  String get recipeStepLabel => 'خطوة';

  @override
  String get recipeStepMinutesLabel => 'دقيقة';

  @override
  String get recipeRemoveStepTooltip => 'إزالة الخطوة';

  @override
  String get recipeDeleteButton => 'حذف الوصفة';

  @override
  String get recipeDeleteStep1Title => 'حذف الوصفة؟';

  @override
  String get recipeDeleteStep1Body => 'هل أنت متأكد أنك تريد حذف هذه الوصفة؟';

  @override
  String get recipeDeleteStep1Continue => 'متابعة';

  @override
  String get recipeDeleteStep2Title => 'لا يمكن التراجع عن ذلك';

  @override
  String get recipeDeleteStep2Body => 'حذف هذه الوصفة سيزيلها بشكل دائم.';

  @override
  String get recipeDeleteStep2Delete => 'حذف';

  @override
  String recipeDeleteFailed(Object error) {
    return 'فشل حذف الوصفة: $error';
  }

  @override
  String get importDocTitle => 'استيراد وصفة من مستند';

  @override
  String get importDocHeader => 'استيراد وصفة من مستند';

  @override
  String get importDocBody =>
      'اختر ملف وصفة أو صورة واضحة. سنحافظ على ثبات العملية أثناء القراءة وإنشاء الوصفة لك.';

  @override
  String get importDocFileReady => 'الملف جاهز';

  @override
  String get importDocAddDocument => 'أضف مستند وصفة';

  @override
  String get importDocFormatsShort => 'PDF, DOCX, JPG, PNG, WEBP';

  @override
  String get importDocProcessingNote =>
      'سنحافظ على استقرار الرفع أثناء المعالجة.';

  @override
  String get importDocEmptyHelper =>
      'لم يتم اختيار ملف بعد. أضف ملفاً أو صورة واضحة للمتابعة.';

  @override
  String get importDocChooseFile => 'اختر ملفاً';

  @override
  String get importDocChoosePhoto => 'اختر صورة';

  @override
  String get importDocTakePhoto => 'التقط صورة';

  @override
  String get importDocTipsTitle => 'نصائح لاستيراد هادئ';

  @override
  String get importDocTip1 => 'استخدم صورة مضيئة جيداً مع ظهور الوصفة كاملة.';

  @override
  String get importDocTip2 => 'ابقَ على هذه الشاشة حتى نأخذك إلى الوصفة.';

  @override
  String get importDocTip3 => 'يمكنك تعديل التفاصيل بعد اكتمال الاستيراد.';

  @override
  String get importDocUpload => 'رفع واستيراد';

  @override
  String get importDocSupportedFooter =>
      'مدعوم: PDF, DOC, DOCX, JPG, PNG, WEBP. قد تستغرق الملفات الكبيرة وقتاً أطول للمعالجة.';
}
