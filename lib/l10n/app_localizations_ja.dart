// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get homeTitle => 'ホーム';

  @override
  String get myRecipesTitle => '私のレシピ';

  @override
  String get backToHomeButton => 'ホームに戻る';

  @override
  String get homeLoadErrorTitle => 'レシピの読み込み中に問題が発生しました。';

  @override
  String get untitledRecipe => '無題のレシピ';

  @override
  String get deleteRecipeTooltip => 'レシピを削除';

  @override
  String get noRecipesYet => 'まだレシピがありません';

  @override
  String get homeLoadErrorHeadline => 'コンテンツの読み込み中に問題が発生しました。';

  @override
  String get homeLoadErrorDescription => 'レシピとブックは安全です。もう一度試すか、ホームに戻ってください。';

  @override
  String get tryAgain => '再試行';

  @override
  String get homeChefPlaceholder => 'シェフ';

  @override
  String homeGreetingChef(Object name) {
    return 'こんにちは $name、料理の準備はできましたか？';
  }

  @override
  String homeGreetingUser(Object name) {
    return 'こんにちは $name、お帰りなさい';
  }

  @override
  String get homeUploadPromptChef => 'レシピをアップして、落ち着いたステップ体験にしましょう。';

  @override
  String get homeUploadPromptUser => 'レシピやレシピ本を見つけましょう。アップロードはシェフ向けです。';

  @override
  String get homeUploadRecipe => 'レシピをアップロード';

  @override
  String get homeCreateManual => '手動で作成';

  @override
  String homeFreeChefLimit(int limit) {
    return '無料シェフは最大 $limit 件のレシピを公開できます。';
  }

  @override
  String get homeUpgradeToChef => 'アップロードするにはシェフになる';

  @override
  String get homeShoppingListTooltip => '買い物リスト';

  @override
  String get homeSearchTooltip => '検索';

  @override
  String get homeResumeCookingTitle => '料理を再開';

  @override
  String get homeNotNow => '今はしない';

  @override
  String homeStepRemaining(int step, Object time) {
    return 'ステップ $step • 残り $time';
  }

  @override
  String get homeResumeButton => '再開';

  @override
  String get homeMyCookbooks => 'マイレシピ集';

  @override
  String get homeSeeAll => 'すべて表示';

  @override
  String get homeNoCookbooks => 'まだレシピ集がありません';

  @override
  String get homeLoadingRecipesTimeout => 'レシピの読み込みがタイムアウトしました。';

  @override
  String get homeUploadsForChefsTitle => 'アップロードはシェフ専用です';

  @override
  String get homeUploadsForChefsBody => 'シェフになって自分のレシピを追加・整理しましょう。';

  @override
  String get homeBecomeChefButton => 'シェフになる';

  @override
  String get homeUploadDocBody => 'レシピ文書をアップして個人レシピ集を始めましょう。';

  @override
  String get homeUploadsForChefsSnackbar =>
      'アップロードはシェフ専用です。シェフになってレシピを追加してください。';

  @override
  String get homeDeleteRecipeTitle => 'レシピを削除';

  @override
  String homeDeleteRecipeMessage(Object title) {
    return '「$title」を削除しますか？元に戻せません。';
  }

  @override
  String get homeCancel => 'キャンセル';

  @override
  String get homeDelete => '削除';

  @override
  String get homeRecipeDeleted => 'レシピを削除しました';

  @override
  String homeDeleteRecipeFailed(Object error) {
    return 'レシピの削除に失敗しました: $error';
  }

  @override
  String get profileTitle => 'プロフィール';

  @override
  String get profileAnonymousUser => '匿名ユーザー';

  @override
  String get profileNoEmail => 'メールなし';

  @override
  String get profileEditChefProfile => 'シェフプロフィールを編集';

  @override
  String get profileAccountTypeChef => 'シェフアカウント';

  @override
  String get profileAccountTypeUser => '一般ユーザーアカウント';

  @override
  String get profilePlanBillingTitle => 'プランと請求';

  @override
  String get profileSubscriptionTitle => 'サブスクリプションを確認';

  @override
  String get profileSubscriptionSubtitle => '現在のプランとアップグレードオプションを確認';

  @override
  String get profileChefToolsTitle => 'シェフツール';

  @override
  String get profileRecentActivityTitle => '最近のアクティビティ';

  @override
  String get profileSeeAll => 'すべて表示';

  @override
  String get profileNoRecentActivity => 'まだ最近のアクティビティがありません';

  @override
  String get profileSettingsTitle => '設定';

  @override
  String get profileOpenSettings => '設定を開く';

  @override
  String get profileOpenSettingsSubtitle => 'アカウント、設定など';

  @override
  String get profileUserTypeFreeUser => '無料ユーザー';

  @override
  String get profileUserTypePremiumUser => 'プレミアムユーザー';

  @override
  String get profileUserTypeFreeChef => '無料シェフ';

  @override
  String get profileUserTypePremiumChef => 'プレミアムシェフ';

  @override
  String get profileChefDashboardUnavailable => 'シェフ用ダッシュボードはシェフアカウントで利用できます。';

  @override
  String get profileChefDashboardTitle => 'シェフダッシュボード';

  @override
  String get profileChefDashboardSubtitle => 'Foodiyでのコンテンツを管理';

  @override
  String get profileUploadRecipe => 'レシピをアップロード';

  @override
  String get profileCreateCookbook => 'レシピ本を作成';

  @override
  String get profileChefInsights => 'シェフインサイト';

  @override
  String profileFreeChefLimitMessage(int limit, int current) {
    return '無料シェフは最大 $limit 件のレシピを公開できます。\\nレシピ: $current / $limit';
  }

  @override
  String get profileUpgradeToPremiumChef => 'プレミアムシェフにアップグレード';

  @override
  String get profileStatMyRecipes => '私のレシピ';

  @override
  String get profileStatMyCookbooks => 'マイレシピ本';

  @override
  String get profileStatFollowers => 'フォロワー';

  @override
  String get profileStatChefInsights => 'シェフインサイト';

  @override
  String get profileInsightsDescription => 'あなたのコンテンツはFoodiyで表示・発見されます。';

  @override
  String get profileInsightsRecipes => 'レシピ';

  @override
  String get profileInsightsCookbooks => 'レシピ本';

  @override
  String get profileInsightsFollowers => 'フォロワー';

  @override
  String get profileInsightsPremiumNote => 'プレミアムシェフは制限が少なく、より快適に使えます。';

  @override
  String get profileInsightsClose => '閉じる';

  @override
  String profileStepsCount(int count) {
    return '$count 手順';
  }

  @override
  String get navHome => 'ホーム';

  @override
  String get navDiscover => '発見';

  @override
  String get navCookbooks => 'レシピ集';

  @override
  String get navProfile => 'プロフィール';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsPlayTimerSound => 'タイマー終了時に音を鳴らす';

  @override
  String get settingsNotificationsSection => '通知';

  @override
  String get settingsNotificationSettings => '通知の設定';

  @override
  String get settingsNotificationSettingsSubtitle => '受け取りたい通知を選択してください';

  @override
  String get settingsAccountSection => 'アカウント';

  @override
  String get settingsEditPersonalDetails => '個人情報を編集';

  @override
  String get settingsChangePassword => 'パスワードを変更';

  @override
  String get settingsLogout => 'ログアウト';

  @override
  String get settingsLogoutFail => 'ログアウトに失敗しました。再度お試しください。';

  @override
  String get settingsDeleteAccount => 'アカウント削除';

  @override
  String get settingsPreferencesSection => 'アプリの設定';

  @override
  String get settingsLanguageUnits => '言語と単位';

  @override
  String get settingsLanguageUnitsSubtitle => 'アプリの言語と単位を選択';

  @override
  String get settingsLegalSection => '法務';

  @override
  String get settingsTermsOfUse => '利用規約';

  @override
  String get settingsPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get settingsAboutSection => '情報';

  @override
  String get settingsAboutApp => 'Foodiy について';

  @override
  String get settingsAboutAppSubtitle => 'このアプリについて詳しく知る';

  @override
  String get languageUnitsTitle => '言語と単位';

  @override
  String get languageSectionTitle => '言語';

  @override
  String get languagePickerLabel => 'アプリの言語';

  @override
  String get languageSystemDefault => 'システム既定';

  @override
  String get languageEnglish => '英語';

  @override
  String get languageHebrew => 'ヘブライ語';

  @override
  String get languageSpanish => 'スペイン語';

  @override
  String get languageFrench => 'フランス語';

  @override
  String get languageArabic => 'アラビア語';

  @override
  String get languageChinese => '中国語';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageItalian => 'イタリア語';

  @override
  String get unitsSectionTitle => '単位';

  @override
  String get unitsMetric => 'メートル法（グラム、摂氏）';

  @override
  String get unitsImperial => 'ヤード・ポンド法（カップ、華氏）';

  @override
  String get notificationTitle => '通知';

  @override
  String get notificationPreferencesTitle => '通知の設定';

  @override
  String get notificationNewChefRecipesTitle => 'シェフの新しいレシピ';

  @override
  String get notificationNewChefRecipesSubtitle => 'シェフが新しいレシピを公開したら通知を受け取る';

  @override
  String get notificationPlaylistSuggestionsTitle => 'プレイリストの提案';

  @override
  String get notificationPlaylistSuggestionsSubtitle => 'おすすめのプレイリストを受け取る';

  @override
  String get notificationAppTipsTitle => 'アプリのヒントと更新情報';

  @override
  String get privacyTitle => 'プライバシーポリシー';

  @override
  String get privacyPlaceholder =>
      'これは Foodiy のプライバシーポリシーの仮テキストです。\\n\\nここでデータの利用・保存・保護について説明します。\\n後で正式なポリシーに置き換えます。';

  @override
  String get termsTitle => '利用規約';

  @override
  String get termsPlaceholder =>
      'これは Foodiy の利用規約の仮テキストです。\\n\\nここで利用ルール、責任制限などの法的詳細を説明します。\\n後で正式な規約に置き換えます。';

  @override
  String get aboutTitle => 'Foodiy について';

  @override
  String get aboutAppName => 'Foodiy';

  @override
  String get aboutVersion => 'バージョン 0.1.0 (dev)';

  @override
  String get aboutDescription =>
      'Foodiy はあなたの料理・レシピブックのパートナーです。\\n\\nレシピブックを作成・フォローし、シェフのコレクションを見つけ、自分の本を作って買い物リストも管理できます。';

  @override
  String aboutCopyright(int year) {
    return '© $year Foodiy. All rights reserved.';
  }

  @override
  String get homeSectionFailed => 'セクションを表示できませんでした';

  @override
  String homeSectionErrorDetails(Object tag, Object error) {
    return '[$tag] $error';
  }

  @override
  String homeUiError(Object error) {
    return 'UI エラー: $error';
  }

  @override
  String get discoverSearchHint => 'レシピ本やシェフを検索';

  @override
  String get discoverNoCookbooks => '公開されているレシピ本はまだありません';

  @override
  String get discoverPublicBadge => '公開';

  @override
  String get discoverCategoryBreakfast => '朝食';

  @override
  String get discoverCategoryBrunch => 'ブランチ';

  @override
  String get discoverCategoryQuickWeeknightDinners => '平日夜の簡単ディナー';

  @override
  String get discoverCategoryFridayLunch => '金曜ランチ';

  @override
  String get discoverCategoryComfortFood => '癒やしの料理';

  @override
  String get discoverCategoryBakingBasics => 'ベーキング基礎';

  @override
  String get discoverCategoryBreadAndDough => 'パン・生地';

  @override
  String get discoverCategoryPastries => 'ペイストリー';

  @override
  String get discoverCategoryCakesAndDesserts => 'ケーキとデザート';

  @override
  String get discoverCategoryCookiesAndSmallSweets => 'クッキーと小さなスイーツ';

  @override
  String get discoverCategoryChocolateLovers => 'チョコ好き';

  @override
  String get discoverCategoryHealthyAndLight => 'ヘルシー＆軽め';

  @override
  String get discoverCategoryHighProtein => '高たんぱく';

  @override
  String get discoverCategoryVegetarian => 'ベジタリアン';

  @override
  String get discoverCategoryVegan => 'ヴィーガン';

  @override
  String get discoverCategoryGlutenFree => 'グルテンフリー';

  @override
  String get discoverCategoryOnePotMeals => 'ワンポット料理';

  @override
  String get discoverCategorySoupsAndStews => 'スープ・シチュー';

  @override
  String get discoverCategorySalads => 'サラダ';

  @override
  String get discoverCategoryPastaAndRisotto => 'パスタとリゾット';

  @override
  String get discoverCategoryRiceAndGrains => 'ごはん・雑穀';

  @override
  String get discoverCategoryMiddleEastern => '中東料理';

  @override
  String get discoverCategoryItalianClassics => 'イタリアの定番';

  @override
  String get discoverCategoryAsianInspired => 'アジア風';

  @override
  String get discoverCategoryStreetFood => 'ストリートフード';

  @override
  String get discoverCategoryFamilyFavorites => '家族の定番';

  @override
  String get discoverCategoryHostingAndHolidays => 'おもてなし・休日';

  @override
  String get discoverCategoryMealPrep => '作り置き';

  @override
  String get discoverCategoryKidsFriendly => '子ども向け';

  @override
  String get discoverCategoryLateNightCravings => '深夜の一品';

  @override
  String get cookbooksLoadError => 'レシピ本の同期に失敗しました。もう一度お試しください。';

  @override
  String get cookbooksEmptyTitle => 'まだレシピ本がありません';

  @override
  String get cookbooksEmptyBody => '最初のレシピ本を作成しましょう';

  @override
  String get cookbooksUntitled => 'タイトルなしのレシピ本';

  @override
  String get cookbooksPrivateBadge => '非公開';

  @override
  String cookbooksRecipeCount(int count) {
    return '$count 件のレシピ';
  }

  @override
  String get cookbooksChefCookbookSuffix => 'シェフのレシピ本';

  @override
  String get cookbooksActionRename => '名前を変更';

  @override
  String get cookbooksActionShare => '共有';

  @override
  String get cookbooksActionDelete => '削除';

  @override
  String get cookbooksMissing => 'このレシピ本は存在しません';

  @override
  String cookbooksCreateFailed(Object error) {
    return 'レシピ本を作成できませんでした: $error';
  }

  @override
  String get cookbooksRenameTitle => 'レシピ本の名前を変更';

  @override
  String get cookbooksRenameNewName => '新しい名前';

  @override
  String get cookbooksNameRequired => '名前は必須です';

  @override
  String get cookbooksSave => '保存';

  @override
  String get cookbooksDeleteTitle => 'レシピ本を削除';

  @override
  String cookbooksDeleteMessage(Object name) {
    return '\"$name\" を削除しますか？';
  }

  @override
  String cookbooksShareSubject(Object name) {
    return 'レシピ本: $name';
  }

  @override
  String get cookbooksCategoryLimit => '最大 5 件まで選択できます';

  @override
  String get cookbooksCategoryPublicRequired => '公開レシピ本には 1～5 件のカテゴリが必要です';

  @override
  String get cookbooksPublicSubtitle => '公開レシピ本は他のユーザーが見られます';

  @override
  String get cookbooksBasicsTitle => '基本情報';

  @override
  String get cookbooksNameLabel => 'レシピ本の名前';

  @override
  String get cookbooksChooseImage => '画像を選択';

  @override
  String get cookbooksCategoriesTitle => 'カテゴリ';

  @override
  String get cookbooksCategoriesPublicHint =>
      '他の人が見つけやすいよう 1～5 件のカテゴリを選んでください。';

  @override
  String get cookbooksCategoriesPrivateHint => '任意: 最大 5 件まで追加できます。';

  @override
  String cookbooksCategoriesSelected(int count) {
    return '$count/5 選択済み';
  }

  @override
  String get cookbooksCreateTitle => 'レシピ本を作成';

  @override
  String get cookbooksBack => '戻る';

  @override
  String get cookbooksNext => '次へ';

  @override
  String get cookbooksCreate => '作成';

  @override
  String get recipeDifficultyMedium => '中くらい';

  @override
  String recipeSaveSuccess(Object title) {
    return 'レシピ「$title」を保存し、マイレシピに追加しました';
  }

  @override
  String recipeSaveFailed(Object error) {
    return 'レシピの保存/公開に失敗しました: $error';
  }

  @override
  String get recipeCreateTitle => 'レシピを作成';

  @override
  String get recipeEditTitle => 'レシピを編集';

  @override
  String get recipeOnlyChefBody =>
      'シェフアカウントのみレシピをアップロードできます。\n\nシェフプランにアップグレードしてレシピを作成してください。';

  @override
  String get recipeFreePlanLimitBody =>
      '無料シェフプランのアップロード上限に達しました。\n\nさらに作成するにはプレミアムシェフへアップグレードしてください。';

  @override
  String get recipePhotoLabel => 'レシピの写真';

  @override
  String get recipeTakePhoto => '写真を撮る';

  @override
  String get recipePhotoLibrary => 'フォトライブラリ';

  @override
  String get recipePickFile => 'ファイル';

  @override
  String get recipeUploadLimitBanner =>
      '無料シェフプランではレシピのアップロードが制限されます。\nプレミアムシェフにアップグレードすると制限が解除されます。';

  @override
  String get recipeTitleLabel => 'レシピタイトル';

  @override
  String get recipeIngredientsTitle => '材料';

  @override
  String get recipeIngredientLabel => '材料';

  @override
  String get recipeQuantityLabel => '量';

  @override
  String get recipeUnitLabel => '単位';

  @override
  String get recipeAddIngredient => '材料を追加';

  @override
  String get recipeToolsTitle => '道具 / 設備';

  @override
  String get recipeToolLabel => '道具';

  @override
  String get recipeAddTool => '道具を追加';

  @override
  String get recipePreCookingTitle => '調理前の準備';

  @override
  String get recipePreCookingHint => '例: オーブンを200℃に予熱、トレイに紙を敷く、豆を一晩浸すなど';

  @override
  String get recipeStepsTitle => '手順';

  @override
  String get recipeAddStep => '手順を追加';

  @override
  String get recipePreviewInPlayer => 'プレーヤーでプレビュー';

  @override
  String get recipeUpdateButton => 'レシピを更新';

  @override
  String get recipeSaveButton => 'レシピを保存';

  @override
  String get recipeStepLabel => '手順';

  @override
  String get recipeStepMinutesLabel => '分';

  @override
  String get recipeRemoveStepTooltip => '手順を削除';

  @override
  String get recipeDeleteButton => 'レシピを削除';

  @override
  String get recipeDeleteStep1Title => 'レシピを削除しますか？';

  @override
  String get recipeDeleteStep1Body => 'このレシピを削除してもよろしいですか？';

  @override
  String get recipeDeleteStep1Continue => '続行';

  @override
  String get recipeDeleteStep2Title => 'この操作は元に戻せません';

  @override
  String get recipeDeleteStep2Body => 'このレシピを削除すると永久に削除されます。';

  @override
  String get recipeDeleteStep2Delete => '削除';

  @override
  String recipeDeleteFailed(Object error) {
    return 'レシピの削除に失敗しました: $error';
  }

  @override
  String get importDocTitle => 'ドキュメントからレシピをインポート';

  @override
  String get importDocHeader => 'ドキュメントからレシピを取り込む';

  @override
  String get importDocBody => 'きれいなレシピファイルまたは写真を選んでください。読み取りと作成の間、安定した状態を保ちます。';

  @override
  String get importDocFileReady => 'ファイルの準備完了';

  @override
  String get importDocAddDocument => 'レシピドキュメントを追加';

  @override
  String get importDocFormatsShort => 'PDF, DOCX, JPG, PNG, WEBP';

  @override
  String get importDocProcessingNote => '処理中もアップロードを安定させます。';

  @override
  String get importDocEmptyHelper => 'まだファイルが選択されていません。明瞭なレシピファイルや写真を追加してください。';

  @override
  String get importDocChooseFile => 'ファイルを選ぶ';

  @override
  String get importDocChoosePhoto => '写真を選ぶ';

  @override
  String get importDocTakePhoto => '写真を撮る';

  @override
  String get importDocTipsTitle => 'スムーズな取り込みのコツ';

  @override
  String get importDocTip1 => 'レシピ全体が映る明るい写真を使ってください。';

  @override
  String get importDocTip2 => 'レシピに進むまでこの画面にとどまってください。';

  @override
  String get importDocTip3 => '取り込み後に詳細を編集できます。';

  @override
  String get importDocUpload => 'アップロードして取り込む';

  @override
  String get importDocSupportedFooter =>
      '対応形式: PDF, DOC, DOCX, JPG, PNG, WEBP。大きいファイルは処理に時間がかかる場合があります。';
}
