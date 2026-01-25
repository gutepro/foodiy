// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get homeTitle => '首页';

  @override
  String get myRecipesTitle => '我的食谱';

  @override
  String get backToHomeButton => '返回首页';

  @override
  String get homeLoadErrorTitle => '加载食谱时遇到问题。';

  @override
  String get untitledRecipe => '未命名的食谱';

  @override
  String get deleteRecipeTooltip => '删除食谱';

  @override
  String get noRecipesYet => '还没有食谱';

  @override
  String get homeLoadErrorHeadline => '加载内容时遇到问题。';

  @override
  String get homeLoadErrorDescription => '你的食谱和食谱本很安全。你可以重试，或返回首页。';

  @override
  String get tryAgain => '重试';

  @override
  String get homeChefPlaceholder => '主厨';

  @override
  String homeGreetingChef(Object name) {
    return '嗨，$name，准备好做饭了吗？';
  }

  @override
  String homeGreetingUser(Object name) {
    return '嗨，$name，欢迎回来';
  }

  @override
  String get homeUploadPromptChef => '上传食谱，将其变成轻松的分步体验。';

  @override
  String get homeUploadPromptUser => '探索食谱和食谱集。上传仅限主厨。';

  @override
  String get homeUploadRecipe => '上传食谱';

  @override
  String get homeCreateManual => '手动创建';

  @override
  String homeFreeChefLimit(int limit) {
    return '免费主厨最多可发布 $limit 个食谱。';
  }

  @override
  String get homeUpgradeToChef => '成为主厨以便上传';

  @override
  String get homeShoppingListTooltip => '购物清单';

  @override
  String get homeSearchTooltip => '搜索';

  @override
  String get homeResumeCookingTitle => '继续烹饪';

  @override
  String get homeNotNow => '暂不';

  @override
  String homeStepRemaining(int step, Object time) {
    return '第 $step 步 • 剩余 $time';
  }

  @override
  String get homeResumeButton => '继续';

  @override
  String get homeMyCookbooks => '我的食谱集';

  @override
  String get homeSeeAll => '查看全部';

  @override
  String get homeNoCookbooks => '还没有食谱集';

  @override
  String get homeLoadingRecipesTimeout => '加载食谱超时。';

  @override
  String get homeUploadsForChefsTitle => '上传仅限主厨';

  @override
  String get homeUploadsForChefsBody => '成为主厨以添加和整理你的食谱。';

  @override
  String get homeBecomeChefButton => '成为主厨';

  @override
  String get homeUploadDocBody => '上传食谱文档以开始你的个人食谱集。';

  @override
  String get homeUploadsForChefsSnackbar => '上传仅限主厨。成为主厨以添加食谱。';

  @override
  String get homeDeleteRecipeTitle => '删除食谱';

  @override
  String homeDeleteRecipeMessage(Object title) {
    return '确定删除“$title”吗？此操作无法撤销。';
  }

  @override
  String get homeCancel => '取消';

  @override
  String get homeDelete => '删除';

  @override
  String get homeRecipeDeleted => '食谱已删除';

  @override
  String homeDeleteRecipeFailed(Object error) {
    return '删除食谱失败：$error';
  }

  @override
  String get profileTitle => '个人资料';

  @override
  String get profileAnonymousUser => '匿名用户';

  @override
  String get profileNoEmail => '无邮箱';

  @override
  String get profileEditChefProfile => '编辑厨师资料';

  @override
  String get profileAccountTypeChef => '厨师账户';

  @override
  String get profileAccountTypeUser => '普通用户账户';

  @override
  String get profilePlanBillingTitle => '套餐与账单';

  @override
  String get profileSubscriptionTitle => '查看我的订阅';

  @override
  String get profileSubscriptionSubtitle => '查看你当前的套餐和升级选项';

  @override
  String get profileChefToolsTitle => '厨师工具';

  @override
  String get profileRecentActivityTitle => '最近活动';

  @override
  String get profileSeeAll => '查看全部';

  @override
  String get profileNoRecentActivity => '暂无最近活动';

  @override
  String get profileSettingsTitle => '设置';

  @override
  String get profileOpenSettings => '打开设置';

  @override
  String get profileOpenSettingsSubtitle => '账户、偏好等';

  @override
  String get profileUserTypeFreeUser => '免费用户';

  @override
  String get profileUserTypePremiumUser => '高级用户';

  @override
  String get profileUserTypeFreeChef => '免费厨师';

  @override
  String get profileUserTypePremiumChef => '高级厨师';

  @override
  String get profileChefDashboardUnavailable => '厨师面板仅对厨师账户开放。';

  @override
  String get profileChefDashboardTitle => '厨师面板';

  @override
  String get profileChefDashboardSubtitle => '管理你在Foodiy的内容';

  @override
  String get profileUploadRecipe => '上传食谱';

  @override
  String get profileCreateCookbook => '创建食谱集';

  @override
  String get profileChefInsights => '厨师洞察';

  @override
  String profileFreeChefLimitMessage(int limit, int current) {
    return '免费厨师最多可发布 $limit 个食谱。\\n食谱：$current / $limit';
  }

  @override
  String get profileUpgradeToPremiumChef => '升级为高级厨师';

  @override
  String get profileStatMyRecipes => '我的食谱';

  @override
  String get profileStatMyCookbooks => '我的食谱集';

  @override
  String get profileStatFollowers => '关注者';

  @override
  String get profileStatChefInsights => '厨师洞察';

  @override
  String get profileInsightsDescription => '你的内容在Foodiy上可见且可被发现。';

  @override
  String get profileInsightsRecipes => '食谱';

  @override
  String get profileInsightsCookbooks => '食谱集';

  @override
  String get profileInsightsFollowers => '关注者';

  @override
  String get profileInsightsPremiumNote => '高级厨师享受更少限制和更流畅的体验。';

  @override
  String get profileInsightsClose => '关闭';

  @override
  String profileStepsCount(int count) {
    return '$count 步';
  }

  @override
  String get navHome => '首页';

  @override
  String get navDiscover => '发现';

  @override
  String get navCookbooks => '食谱集';

  @override
  String get navProfile => '个人资料';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsPlayTimerSound => '计时结束时播放声音';

  @override
  String get settingsNotificationsSection => '通知';

  @override
  String get settingsNotificationSettings => '通知设置';

  @override
  String get settingsNotificationSettingsSubtitle => '选择你想接收的通知';

  @override
  String get settingsAccountSection => '账户';

  @override
  String get settingsEditPersonalDetails => '编辑个人信息';

  @override
  String get settingsChangePassword => '更改密码';

  @override
  String get settingsLogout => '退出登录';

  @override
  String get settingsLogoutFail => '退出失败，请重试。';

  @override
  String get settingsDeleteAccount => '删除账户';

  @override
  String get settingsPreferencesSection => '应用偏好';

  @override
  String get settingsLanguageUnits => '语言和单位';

  @override
  String get settingsLanguageUnitsSubtitle => '选择应用语言和度量单位';

  @override
  String get settingsLegalSection => '法律';

  @override
  String get settingsTermsOfUse => '使用条款';

  @override
  String get settingsPrivacyPolicy => '隐私政策';

  @override
  String get settingsAboutSection => '关于';

  @override
  String get settingsAboutApp => '关于 Foodiy';

  @override
  String get settingsAboutAppSubtitle => '了解更多关于此应用';

  @override
  String get languageUnitsTitle => '语言和单位';

  @override
  String get languageSectionTitle => '语言';

  @override
  String get languagePickerLabel => '应用语言';

  @override
  String get languageSystemDefault => '系统默认';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageHebrew => '希伯来语';

  @override
  String get languageSpanish => '西班牙语';

  @override
  String get languageFrench => '法语';

  @override
  String get languageArabic => '阿拉伯语';

  @override
  String get languageChinese => '中文';

  @override
  String get languageJapanese => '日语';

  @override
  String get languageItalian => '意大利语';

  @override
  String get unitsSectionTitle => '单位';

  @override
  String get unitsMetric => '公制（克，摄氏度）';

  @override
  String get unitsImperial => '英制（杯，华氏度）';

  @override
  String get notificationTitle => '通知';

  @override
  String get notificationPreferencesTitle => '通知偏好';

  @override
  String get notificationNewChefRecipesTitle => '厨师新食谱';

  @override
  String get notificationNewChefRecipesSubtitle => '当厨师发布新食谱时获取通知';

  @override
  String get notificationPlaylistSuggestionsTitle => '列表推荐';

  @override
  String get notificationPlaylistSuggestionsSubtitle => '接收可能喜欢的列表推荐';

  @override
  String get notificationAppTipsTitle => '应用提示和更新';

  @override
  String get privacyTitle => '隐私政策';

  @override
  String get privacyPlaceholder =>
      '这是 Foodiy 隐私政策的占位文本。\\n\\n这里将描述用户数据如何使用、存储和保护。\\n稍后我们会用正式的政策替换此文本。';

  @override
  String get termsTitle => '使用条款';

  @override
  String get termsPlaceholder =>
      '这是 Foodiy 使用条款的占位文本。\\n\\n这里将描述应用使用规则、责任限制等法律细节。\\n稍后会用正式条款替换此文本。';

  @override
  String get aboutTitle => '关于 Foodiy';

  @override
  String get aboutAppName => 'Foodiy';

  @override
  String get aboutVersion => '版本 0.1.0 (dev)';

  @override
  String get aboutDescription =>
      'Foodiy 是你的私人烹饪与食谱助手。\\n\\n创建和关注食谱集，发现厨师合集，构建自己的食谱本并管理购物清单，一站搞定。';

  @override
  String aboutCopyright(int year) {
    return '© $year Foodiy。保留所有权利。';
  }

  @override
  String get homeSectionFailed => '部分内容无法显示';

  @override
  String homeSectionErrorDetails(Object tag, Object error) {
    return '[$tag] $error';
  }

  @override
  String homeUiError(Object error) {
    return '界面错误：$error';
  }

  @override
  String get discoverSearchHint => '搜索食谱集或厨师';

  @override
  String get discoverNoCookbooks => '暂无公开的食谱集';

  @override
  String get discoverPublicBadge => '公开';

  @override
  String get discoverCategoryBreakfast => '早餐';

  @override
  String get discoverCategoryBrunch => '早午餐';

  @override
  String get discoverCategoryQuickWeeknightDinners => '工作日晚餐速成';

  @override
  String get discoverCategoryFridayLunch => '周五午餐';

  @override
  String get discoverCategoryComfortFood => '安慰食物';

  @override
  String get discoverCategoryBakingBasics => '烘焙基础';

  @override
  String get discoverCategoryBreadAndDough => '面包与面团';

  @override
  String get discoverCategoryPastries => '酥点';

  @override
  String get discoverCategoryCakesAndDesserts => '蛋糕与甜点';

  @override
  String get discoverCategoryCookiesAndSmallSweets => '曲奇与小甜点';

  @override
  String get discoverCategoryChocolateLovers => '巧克力爱好者';

  @override
  String get discoverCategoryHealthyAndLight => '健康清淡';

  @override
  String get discoverCategoryHighProtein => '高蛋白';

  @override
  String get discoverCategoryVegetarian => '素食';

  @override
  String get discoverCategoryVegan => '纯素';

  @override
  String get discoverCategoryGlutenFree => '无麸质';

  @override
  String get discoverCategoryOnePotMeals => '一锅料理';

  @override
  String get discoverCategorySoupsAndStews => '汤与炖菜';

  @override
  String get discoverCategorySalads => '沙拉';

  @override
  String get discoverCategoryPastaAndRisotto => '意面与烩饭';

  @override
  String get discoverCategoryRiceAndGrains => '米饭与全谷';

  @override
  String get discoverCategoryMiddleEastern => '中东风味';

  @override
  String get discoverCategoryItalianClassics => '经典意大利';

  @override
  String get discoverCategoryAsianInspired => '亚洲风味';

  @override
  String get discoverCategoryStreetFood => '街头小吃';

  @override
  String get discoverCategoryFamilyFavorites => '家庭最爱';

  @override
  String get discoverCategoryHostingAndHolidays => '聚会与节日';

  @override
  String get discoverCategoryMealPrep => '备餐';

  @override
  String get discoverCategoryKidsFriendly => '适合孩子';

  @override
  String get discoverCategoryLateNightCravings => '宵夜解馋';

  @override
  String get cookbooksLoadError => '同步食谱集失败，请重试。';

  @override
  String get cookbooksEmptyTitle => '你还没有任何食谱集';

  @override
  String get cookbooksEmptyBody => '创建你的第一个个人食谱集';

  @override
  String get cookbooksUntitled => '未命名食谱集';

  @override
  String get cookbooksPrivateBadge => '私有';

  @override
  String cookbooksRecipeCount(int count) {
    return '$count 道食谱';
  }

  @override
  String get cookbooksChefCookbookSuffix => '厨师食谱集';

  @override
  String get cookbooksActionRename => '重命名';

  @override
  String get cookbooksActionShare => '分享';

  @override
  String get cookbooksActionDelete => '删除';

  @override
  String get cookbooksMissing => '该食谱集已不存在';

  @override
  String cookbooksCreateFailed(Object error) {
    return '无法创建食谱集：$error';
  }

  @override
  String get cookbooksRenameTitle => '重命名食谱集';

  @override
  String get cookbooksRenameNewName => '新名称';

  @override
  String get cookbooksNameRequired => '名称必填';

  @override
  String get cookbooksSave => '保存';

  @override
  String get cookbooksDeleteTitle => '删除食谱集';

  @override
  String cookbooksDeleteMessage(Object name) {
    return '删除“$name”？';
  }

  @override
  String cookbooksShareSubject(Object name) {
    return '食谱集：$name';
  }

  @override
  String get cookbooksCategoryLimit => '最多可选择 5 个类别';

  @override
  String get cookbooksCategoryPublicRequired => '公共食谱集需选择 1-5 个类别';

  @override
  String get cookbooksPublicSubtitle => '公开的食谱集对他人可见';

  @override
  String get cookbooksBasicsTitle => '基础';

  @override
  String get cookbooksNameLabel => '食谱集名称';

  @override
  String get cookbooksChooseImage => '选择图片';

  @override
  String get cookbooksCategoriesTitle => '类别';

  @override
  String get cookbooksCategoriesPublicHint => '选择 1-5 个类别，便于他人找到你的食谱集。';

  @override
  String get cookbooksCategoriesPrivateHint => '可选：添加最多 5 个类别。';

  @override
  String cookbooksCategoriesSelected(int count) {
    return '$count/5 已选';
  }

  @override
  String get cookbooksCreateTitle => '创建食谱集';

  @override
  String get cookbooksBack => '返回';

  @override
  String get cookbooksNext => '下一步';

  @override
  String get cookbooksCreate => '创建';

  @override
  String get recipeDifficultyMedium => '中等';

  @override
  String recipeSaveSuccess(Object title) {
    return '食谱“$title”已保存并添加到我的食谱';
  }

  @override
  String recipeSaveFailed(Object error) {
    return '无法保存/发布食谱：$error';
  }

  @override
  String get recipeCreateTitle => '创建食谱';

  @override
  String get recipeEditTitle => '编辑食谱';

  @override
  String get recipeOnlyChefBody => '只有厨师账号可以上传食谱。\n\n升级到厨师计划开始创建食谱。';

  @override
  String get recipeFreePlanLimitBody => '你已达到免费厨师计划的上传上限。\n\n升级到高级厨师以创建更多食谱。';

  @override
  String get recipePhotoLabel => '食谱照片';

  @override
  String get recipeTakePhoto => '拍照';

  @override
  String get recipePhotoLibrary => '照片库';

  @override
  String get recipePickFile => '文件';

  @override
  String get recipeUploadLimitBanner => '免费厨师计划——上传食谱有限制。\n升级到高级厨师可移除此限制。';

  @override
  String get recipeTitleLabel => '食谱标题';

  @override
  String get recipeIngredientsTitle => '食材';

  @override
  String get recipeIngredientLabel => '食材';

  @override
  String get recipeQuantityLabel => '数量';

  @override
  String get recipeUnitLabel => '单位';

  @override
  String get recipeAddIngredient => '添加食材';

  @override
  String get recipeToolsTitle => '工具 / 设备';

  @override
  String get recipeToolLabel => '工具';

  @override
  String get recipeAddTool => '添加工具';

  @override
  String get recipePreCookingTitle => '烹饪前准备';

  @override
  String get recipePreCookingHint => '例如：预热烤箱至 200°C，铺好烤盘，豆子浸泡过夜……';

  @override
  String get recipeStepsTitle => '步骤';

  @override
  String get recipeAddStep => '添加步骤';

  @override
  String get recipePreviewInPlayer => '在播放器中预览';

  @override
  String get recipeUpdateButton => '更新食谱';

  @override
  String get recipeSaveButton => '保存食谱';

  @override
  String get recipeStepLabel => '步骤';

  @override
  String get recipeStepMinutesLabel => '分钟';

  @override
  String get recipeRemoveStepTooltip => '移除步骤';

  @override
  String get recipeDeleteButton => '删除食谱';

  @override
  String get recipeDeleteStep1Title => '删除这道食谱？';

  @override
  String get recipeDeleteStep1Body => '确定要删除这道食谱吗？';

  @override
  String get recipeDeleteStep1Continue => '继续';

  @override
  String get recipeDeleteStep2Title => '此操作无法撤销';

  @override
  String get recipeDeleteStep2Body => '删除这道食谱将永久移除它。';

  @override
  String get recipeDeleteStep2Delete => '删除';

  @override
  String recipeDeleteFailed(Object error) {
    return '删除食谱失败：$error';
  }

  @override
  String get importDocTitle => '从文档导入食谱';

  @override
  String get importDocHeader => '从文档导入食谱';

  @override
  String get importDocBody => '选择清晰的食谱文件或照片。我们会保持过程稳定，读取并为你创建食谱。';

  @override
  String get importDocFileReady => '文件就绪';

  @override
  String get importDocAddDocument => '添加食谱文档';

  @override
  String get importDocFormatsShort => 'PDF, DOCX, JPG, PNG, WEBP';

  @override
  String get importDocProcessingNote => '处理时会保持上传稳定。';

  @override
  String get importDocEmptyHelper => '尚未选择文件。请添加清晰的食谱文件或照片以继续。';

  @override
  String get importDocChooseFile => '选择文件';

  @override
  String get importDocChoosePhoto => '选择照片';

  @override
  String get importDocTakePhoto => '拍照';

  @override
  String get importDocTipsTitle => '平稳导入的提示';

  @override
  String get importDocTip1 => '使用光线充足、完整显示食谱的照片。';

  @override
  String get importDocTip2 => '停留在此屏幕，直到带你进入食谱。';

  @override
  String get importDocTip3 => '导入完成后你可以编辑细节。';

  @override
  String get importDocUpload => '上传并导入';

  @override
  String get importDocSupportedFooter =>
      '支持：PDF、DOC、DOCX、JPG、PNG、WEBP。较大的文件处理时间可能更长。';

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
