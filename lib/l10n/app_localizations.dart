import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_he.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('he'),
    Locale('it'),
    Locale('ja'),
    Locale('zh'),
  ];

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @myRecipesTitle.
  ///
  /// In en, this message translates to:
  /// **'My recipes'**
  String get myRecipesTitle;

  /// No description provided for @backToHomeButton.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHomeButton;

  /// No description provided for @homeLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'We had trouble loading recipes.'**
  String get homeLoadErrorTitle;

  /// No description provided for @untitledRecipe.
  ///
  /// In en, this message translates to:
  /// **'Untitled recipe'**
  String get untitledRecipe;

  /// No description provided for @deleteRecipeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete recipe'**
  String get deleteRecipeTooltip;

  /// No description provided for @noRecipesYet.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get noRecipesYet;

  /// No description provided for @homeLoadErrorHeadline.
  ///
  /// In en, this message translates to:
  /// **'We had trouble loading your content.'**
  String get homeLoadErrorHeadline;

  /// No description provided for @homeLoadErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'Your recipes and cookbooks stay safe. You can try again, or go back to Home.'**
  String get homeLoadErrorDescription;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @homeChefPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Chef'**
  String get homeChefPlaceholder;

  /// No description provided for @homeGreetingChef.
  ///
  /// In en, this message translates to:
  /// **'Hi {name}, ready to cook?'**
  String homeGreetingChef(Object name);

  /// No description provided for @homeGreetingUser.
  ///
  /// In en, this message translates to:
  /// **'Hi {name}, welcome back'**
  String homeGreetingUser(Object name);

  /// No description provided for @homeUploadPromptChef.
  ///
  /// In en, this message translates to:
  /// **'Upload a recipe to turn it into a calm, step-by-step experience.'**
  String get homeUploadPromptChef;

  /// No description provided for @homeUploadPromptUser.
  ///
  /// In en, this message translates to:
  /// **'Explore recipes and cookbooks. Uploads are for chefs.'**
  String get homeUploadPromptUser;

  /// No description provided for @homeUploadRecipe.
  ///
  /// In en, this message translates to:
  /// **'Upload recipe'**
  String get homeUploadRecipe;

  /// No description provided for @homeCreateManual.
  ///
  /// In en, this message translates to:
  /// **'Create manually'**
  String get homeCreateManual;

  /// No description provided for @homeFreeChefLimit.
  ///
  /// In en, this message translates to:
  /// **'Free chefs can publish up to {limit} recipes.'**
  String homeFreeChefLimit(int limit);

  /// No description provided for @homeUpgradeToChef.
  ///
  /// In en, this message translates to:
  /// **'Become a Chef to upload'**
  String get homeUpgradeToChef;

  /// No description provided for @homeShoppingListTooltip.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get homeShoppingListTooltip;

  /// No description provided for @homeSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get homeSearchTooltip;

  /// No description provided for @homeResumeCookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Resume cooking'**
  String get homeResumeCookingTitle;

  /// No description provided for @homeNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get homeNotNow;

  /// No description provided for @homeStepRemaining.
  ///
  /// In en, this message translates to:
  /// **'Step {step} • {time} remaining'**
  String homeStepRemaining(int step, Object time);

  /// No description provided for @homeResumeButton.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get homeResumeButton;

  /// No description provided for @homeMyCookbooks.
  ///
  /// In en, this message translates to:
  /// **'My cookbooks'**
  String get homeMyCookbooks;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @homeNoCookbooks.
  ///
  /// In en, this message translates to:
  /// **'No cookbooks yet'**
  String get homeNoCookbooks;

  /// No description provided for @homeLoadingRecipesTimeout.
  ///
  /// In en, this message translates to:
  /// **'Loading recipes timed out.'**
  String get homeLoadingRecipesTimeout;

  /// No description provided for @homeUploadsForChefsTitle.
  ///
  /// In en, this message translates to:
  /// **'Uploads are for chefs'**
  String get homeUploadsForChefsTitle;

  /// No description provided for @homeUploadsForChefsBody.
  ///
  /// In en, this message translates to:
  /// **'Become a Chef to add and organize your own recipes.'**
  String get homeUploadsForChefsBody;

  /// No description provided for @homeBecomeChefButton.
  ///
  /// In en, this message translates to:
  /// **'Become a Chef'**
  String get homeBecomeChefButton;

  /// No description provided for @homeUploadDocBody.
  ///
  /// In en, this message translates to:
  /// **'Upload a recipe document to start your personal cookbook.'**
  String get homeUploadDocBody;

  /// No description provided for @homeUploadsForChefsSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Uploads are for chefs. Become a Chef to add recipes.'**
  String get homeUploadsForChefsSnackbar;

  /// No description provided for @homeDeleteRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete recipe'**
  String get homeDeleteRecipeTitle;

  /// No description provided for @homeDeleteRecipeMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"? This cannot be undone.'**
  String homeDeleteRecipeMessage(Object title);

  /// No description provided for @homeCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get homeCancel;

  /// No description provided for @homeDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get homeDelete;

  /// No description provided for @homeRecipeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Recipe deleted'**
  String get homeRecipeDeleted;

  /// No description provided for @homeDeleteRecipeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete recipe: {error}'**
  String homeDeleteRecipeFailed(Object error);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileAnonymousUser.
  ///
  /// In en, this message translates to:
  /// **'Anonymous user'**
  String get profileAnonymousUser;

  /// No description provided for @profileNoEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get profileNoEmail;

  /// No description provided for @profileEditChefProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Chef Profile'**
  String get profileEditChefProfile;

  /// No description provided for @profileAccountTypeChef.
  ///
  /// In en, this message translates to:
  /// **'Chef account'**
  String get profileAccountTypeChef;

  /// No description provided for @profileAccountTypeUser.
  ///
  /// In en, this message translates to:
  /// **'Regular user account'**
  String get profileAccountTypeUser;

  /// No description provided for @profilePlanBillingTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan and billing'**
  String get profilePlanBillingTitle;

  /// No description provided for @profileSubscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'View my subscription'**
  String get profileSubscriptionTitle;

  /// No description provided for @profileSubscriptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See your current plan and upgrade options'**
  String get profileSubscriptionSubtitle;

  /// No description provided for @profileChefToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Chef tools'**
  String get profileChefToolsTitle;

  /// No description provided for @profileRecentActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get profileRecentActivityTitle;

  /// No description provided for @profileSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get profileSeeAll;

  /// No description provided for @profileNoRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity yet'**
  String get profileNoRecentActivity;

  /// No description provided for @profileSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettingsTitle;

  /// No description provided for @profileOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get profileOpenSettings;

  /// No description provided for @profileOpenSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account, preferences and more'**
  String get profileOpenSettingsSubtitle;

  /// No description provided for @profileUserTypeFreeUser.
  ///
  /// In en, this message translates to:
  /// **'Free user'**
  String get profileUserTypeFreeUser;

  /// No description provided for @profileUserTypePremiumUser.
  ///
  /// In en, this message translates to:
  /// **'Premium user'**
  String get profileUserTypePremiumUser;

  /// No description provided for @profileUserTypeFreeChef.
  ///
  /// In en, this message translates to:
  /// **'Free chef'**
  String get profileUserTypeFreeChef;

  /// No description provided for @profileUserTypePremiumChef.
  ///
  /// In en, this message translates to:
  /// **'Premium chef'**
  String get profileUserTypePremiumChef;

  /// No description provided for @profileChefDashboardUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Chef dashboard is available for chef accounts.'**
  String get profileChefDashboardUnavailable;

  /// No description provided for @profileChefDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Chef Dashboard'**
  String get profileChefDashboardTitle;

  /// No description provided for @profileChefDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your content on Foodiy'**
  String get profileChefDashboardSubtitle;

  /// No description provided for @profileUploadRecipe.
  ///
  /// In en, this message translates to:
  /// **'Upload recipe'**
  String get profileUploadRecipe;

  /// No description provided for @profileCreateCookbook.
  ///
  /// In en, this message translates to:
  /// **'Create cookbook'**
  String get profileCreateCookbook;

  /// No description provided for @profileChefInsights.
  ///
  /// In en, this message translates to:
  /// **'Chef Insights'**
  String get profileChefInsights;

  /// No description provided for @profileFreeChefLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'Free chefs can publish up to {limit} recipes.\\nRecipes: {current} / {limit}'**
  String profileFreeChefLimitMessage(int limit, int current);

  /// No description provided for @profileUpgradeToPremiumChef.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium Chef'**
  String get profileUpgradeToPremiumChef;

  /// No description provided for @profileStatMyRecipes.
  ///
  /// In en, this message translates to:
  /// **'My recipes'**
  String get profileStatMyRecipes;

  /// No description provided for @profileStatMyCookbooks.
  ///
  /// In en, this message translates to:
  /// **'My cookbooks'**
  String get profileStatMyCookbooks;

  /// No description provided for @profileStatFollowers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get profileStatFollowers;

  /// No description provided for @profileStatChefInsights.
  ///
  /// In en, this message translates to:
  /// **'Chef Insights'**
  String get profileStatChefInsights;

  /// No description provided for @profileInsightsDescription.
  ///
  /// In en, this message translates to:
  /// **'Your content is visible and discoverable on Foodiy.'**
  String get profileInsightsDescription;

  /// No description provided for @profileInsightsRecipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get profileInsightsRecipes;

  /// No description provided for @profileInsightsCookbooks.
  ///
  /// In en, this message translates to:
  /// **'Cookbooks'**
  String get profileInsightsCookbooks;

  /// No description provided for @profileInsightsFollowers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get profileInsightsFollowers;

  /// No description provided for @profileInsightsPremiumNote.
  ///
  /// In en, this message translates to:
  /// **'Premium chefs enjoy fewer limits and a cleaner experience.'**
  String get profileInsightsPremiumNote;

  /// No description provided for @profileInsightsClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get profileInsightsClose;

  /// No description provided for @profileStepsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} steps'**
  String profileStepsCount(int count);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get navDiscover;

  /// No description provided for @navCookbooks.
  ///
  /// In en, this message translates to:
  /// **'Cookbooks'**
  String get navCookbooks;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPlayTimerSound.
  ///
  /// In en, this message translates to:
  /// **'Play sound when timer finishes'**
  String get settingsPlayTimerSound;

  /// No description provided for @settingsNotificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationsSection;

  /// No description provided for @settingsNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get settingsNotificationSettings;

  /// No description provided for @settingsNotificationSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose which notifications you want to receive'**
  String get settingsNotificationSettingsSubtitle;

  /// No description provided for @settingsAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountSection;

  /// No description provided for @settingsEditPersonalDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit personal details'**
  String get settingsEditPersonalDetails;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get settingsChangePassword;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to log out. Please try again.'**
  String get settingsLogoutFail;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsPreferencesSection.
  ///
  /// In en, this message translates to:
  /// **'App preferences'**
  String get settingsPreferencesSection;

  /// No description provided for @settingsLanguageUnits.
  ///
  /// In en, this message translates to:
  /// **'Language and units'**
  String get settingsLanguageUnits;

  /// No description provided for @settingsLanguageUnitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose app language and measurement units'**
  String get settingsLanguageUnitsSubtitle;

  /// No description provided for @settingsLegalSection.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get settingsLegalSection;

  /// No description provided for @settingsTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get settingsTermsOfUse;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsAboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutSection;

  /// No description provided for @settingsAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About Foodiy'**
  String get settingsAboutApp;

  /// No description provided for @settingsAboutAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn more about this app'**
  String get settingsAboutAppSubtitle;

  /// No description provided for @languageUnitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Language and units'**
  String get languageUnitsTitle;

  /// No description provided for @languageSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSectionTitle;

  /// No description provided for @languagePickerLabel.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get languagePickerLabel;

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHebrew.
  ///
  /// In en, this message translates to:
  /// **'Hebrew'**
  String get languageHebrew;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageChinese;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageJapanese;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languageItalian;

  /// No description provided for @unitsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get unitsSectionTitle;

  /// No description provided for @unitsMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric (grams, Celsius)'**
  String get unitsMetric;

  /// No description provided for @unitsImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial (cups, Fahrenheit)'**
  String get unitsImperial;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationTitle;

  /// No description provided for @notificationPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences'**
  String get notificationPreferencesTitle;

  /// No description provided for @notificationNewChefRecipesTitle.
  ///
  /// In en, this message translates to:
  /// **'New recipes from chefs'**
  String get notificationNewChefRecipesTitle;

  /// No description provided for @notificationNewChefRecipesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified when chefs publish new recipes'**
  String get notificationNewChefRecipesSubtitle;

  /// No description provided for @notificationPlaylistSuggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlist suggestions'**
  String get notificationPlaylistSuggestionsTitle;

  /// No description provided for @notificationPlaylistSuggestionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get suggestions for playlists you might like'**
  String get notificationPlaylistSuggestionsSubtitle;

  /// No description provided for @notificationAppTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'App tips and updates'**
  String get notificationAppTipsTitle;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyTitle;

  /// No description provided for @privacyPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'This is a placeholder for the Foodiy privacy policy.\\n\\nHere you will describe how user data is used, stored, and protected.\\nLater we will replace this text with the real policy.'**
  String get privacyPlaceholder;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsTitle;

  /// No description provided for @termsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'This is a placeholder for the Foodiy terms of use.\\n\\nHere you will describe the rules for using the app, limitations of liability, and other legal details.\\nLater we will replace this text with the real terms.'**
  String get termsPlaceholder;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Foodiy'**
  String get aboutTitle;

  /// No description provided for @aboutAppName.
  ///
  /// In en, this message translates to:
  /// **'Foodiy'**
  String get aboutAppName;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 0.1.0 (dev)'**
  String get aboutVersion;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Foodiy is your personal cooking and cookbook companion.\\n\\nCreate and follow recipe cookbooks, discover chef collections, build your own cookbooks and manage shopping lists – all in one place.'**
  String get aboutDescription;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'© {year} Foodiy. All rights reserved.'**
  String aboutCopyright(int year);

  /// No description provided for @homeSectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Section failed to render'**
  String get homeSectionFailed;

  /// No description provided for @homeSectionErrorDetails.
  ///
  /// In en, this message translates to:
  /// **'[{tag}] {error}'**
  String homeSectionErrorDetails(Object tag, Object error);

  /// No description provided for @homeUiError.
  ///
  /// In en, this message translates to:
  /// **'UI error: {error}'**
  String homeUiError(Object error);

  /// No description provided for @discoverSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search cookbooks or chefs'**
  String get discoverSearchHint;

  /// No description provided for @discoverNoCookbooks.
  ///
  /// In en, this message translates to:
  /// **'No public cookbooks yet'**
  String get discoverNoCookbooks;

  /// No description provided for @discoverPublicBadge.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get discoverPublicBadge;

  /// No description provided for @discoverCategoryBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get discoverCategoryBreakfast;

  /// No description provided for @discoverCategoryBrunch.
  ///
  /// In en, this message translates to:
  /// **'Brunch'**
  String get discoverCategoryBrunch;

  /// No description provided for @discoverCategoryQuickWeeknightDinners.
  ///
  /// In en, this message translates to:
  /// **'Quick Weeknight Dinners'**
  String get discoverCategoryQuickWeeknightDinners;

  /// No description provided for @discoverCategoryFridayLunch.
  ///
  /// In en, this message translates to:
  /// **'Friday Lunch'**
  String get discoverCategoryFridayLunch;

  /// No description provided for @discoverCategoryComfortFood.
  ///
  /// In en, this message translates to:
  /// **'Comfort Food'**
  String get discoverCategoryComfortFood;

  /// No description provided for @discoverCategoryBakingBasics.
  ///
  /// In en, this message translates to:
  /// **'Baking Basics'**
  String get discoverCategoryBakingBasics;

  /// No description provided for @discoverCategoryBreadAndDough.
  ///
  /// In en, this message translates to:
  /// **'Bread & Dough'**
  String get discoverCategoryBreadAndDough;

  /// No description provided for @discoverCategoryPastries.
  ///
  /// In en, this message translates to:
  /// **'Pastries'**
  String get discoverCategoryPastries;

  /// No description provided for @discoverCategoryCakesAndDesserts.
  ///
  /// In en, this message translates to:
  /// **'Cakes & Desserts'**
  String get discoverCategoryCakesAndDesserts;

  /// No description provided for @discoverCategoryCookiesAndSmallSweets.
  ///
  /// In en, this message translates to:
  /// **'Cookies & Small Sweets'**
  String get discoverCategoryCookiesAndSmallSweets;

  /// No description provided for @discoverCategoryChocolateLovers.
  ///
  /// In en, this message translates to:
  /// **'Chocolate Lovers'**
  String get discoverCategoryChocolateLovers;

  /// No description provided for @discoverCategoryHealthyAndLight.
  ///
  /// In en, this message translates to:
  /// **'Healthy & Light'**
  String get discoverCategoryHealthyAndLight;

  /// No description provided for @discoverCategoryHighProtein.
  ///
  /// In en, this message translates to:
  /// **'High Protein'**
  String get discoverCategoryHighProtein;

  /// No description provided for @discoverCategoryVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get discoverCategoryVegetarian;

  /// No description provided for @discoverCategoryVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get discoverCategoryVegan;

  /// No description provided for @discoverCategoryGlutenFree.
  ///
  /// In en, this message translates to:
  /// **'Gluten Free'**
  String get discoverCategoryGlutenFree;

  /// No description provided for @discoverCategoryOnePotMeals.
  ///
  /// In en, this message translates to:
  /// **'One Pot Meals'**
  String get discoverCategoryOnePotMeals;

  /// No description provided for @discoverCategorySoupsAndStews.
  ///
  /// In en, this message translates to:
  /// **'Soups & Stews'**
  String get discoverCategorySoupsAndStews;

  /// No description provided for @discoverCategorySalads.
  ///
  /// In en, this message translates to:
  /// **'Salads'**
  String get discoverCategorySalads;

  /// No description provided for @discoverCategoryPastaAndRisotto.
  ///
  /// In en, this message translates to:
  /// **'Pasta & Risotto'**
  String get discoverCategoryPastaAndRisotto;

  /// No description provided for @discoverCategoryRiceAndGrains.
  ///
  /// In en, this message translates to:
  /// **'Rice & Grains'**
  String get discoverCategoryRiceAndGrains;

  /// No description provided for @discoverCategoryMiddleEastern.
  ///
  /// In en, this message translates to:
  /// **'Middle Eastern'**
  String get discoverCategoryMiddleEastern;

  /// No description provided for @discoverCategoryItalianClassics.
  ///
  /// In en, this message translates to:
  /// **'Italian Classics'**
  String get discoverCategoryItalianClassics;

  /// No description provided for @discoverCategoryAsianInspired.
  ///
  /// In en, this message translates to:
  /// **'Asian Inspired'**
  String get discoverCategoryAsianInspired;

  /// No description provided for @discoverCategoryStreetFood.
  ///
  /// In en, this message translates to:
  /// **'Street Food'**
  String get discoverCategoryStreetFood;

  /// No description provided for @discoverCategoryFamilyFavorites.
  ///
  /// In en, this message translates to:
  /// **'Family Favorites'**
  String get discoverCategoryFamilyFavorites;

  /// No description provided for @discoverCategoryHostingAndHolidays.
  ///
  /// In en, this message translates to:
  /// **'Hosting & Holidays'**
  String get discoverCategoryHostingAndHolidays;

  /// No description provided for @discoverCategoryMealPrep.
  ///
  /// In en, this message translates to:
  /// **'Meal Prep'**
  String get discoverCategoryMealPrep;

  /// No description provided for @discoverCategoryKidsFriendly.
  ///
  /// In en, this message translates to:
  /// **'Kids Friendly'**
  String get discoverCategoryKidsFriendly;

  /// No description provided for @discoverCategoryLateNightCravings.
  ///
  /// In en, this message translates to:
  /// **'Late Night Cravings'**
  String get discoverCategoryLateNightCravings;

  /// No description provided for @cookbooksLoadError.
  ///
  /// In en, this message translates to:
  /// **'Cookbooks sync failed. Please try again.'**
  String get cookbooksLoadError;

  /// No description provided for @cookbooksEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You do not have any cookbooks yet'**
  String get cookbooksEmptyTitle;

  /// No description provided for @cookbooksEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create your first personal cookbook'**
  String get cookbooksEmptyBody;

  /// No description provided for @cookbooksUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled cookbook'**
  String get cookbooksUntitled;

  /// No description provided for @cookbooksPrivateBadge.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get cookbooksPrivateBadge;

  /// No description provided for @cookbooksRecipeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} recipes'**
  String cookbooksRecipeCount(int count);

  /// No description provided for @cookbooksChefCookbookSuffix.
  ///
  /// In en, this message translates to:
  /// **'Chef cookbook'**
  String get cookbooksChefCookbookSuffix;

  /// No description provided for @cookbooksActionRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get cookbooksActionRename;

  /// No description provided for @cookbooksActionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get cookbooksActionShare;

  /// No description provided for @cookbooksActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get cookbooksActionDelete;

  /// No description provided for @cookbooksMissing.
  ///
  /// In en, this message translates to:
  /// **'This cookbook no longer exists'**
  String get cookbooksMissing;

  /// No description provided for @cookbooksCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to create cookbook: {error}'**
  String cookbooksCreateFailed(Object error);

  /// No description provided for @cookbooksRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename cookbook'**
  String get cookbooksRenameTitle;

  /// No description provided for @cookbooksRenameNewName.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get cookbooksRenameNewName;

  /// No description provided for @cookbooksNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get cookbooksNameRequired;

  /// No description provided for @cookbooksSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get cookbooksSave;

  /// No description provided for @cookbooksDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete cookbook'**
  String get cookbooksDeleteTitle;

  /// No description provided for @cookbooksDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String cookbooksDeleteMessage(Object name);

  /// No description provided for @cookbooksShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Cookbook: {name}'**
  String cookbooksShareSubject(Object name);

  /// No description provided for @cookbooksCategoryLimit.
  ///
  /// In en, this message translates to:
  /// **'You can select up to 5 categories'**
  String get cookbooksCategoryLimit;

  /// No description provided for @cookbooksCategoryPublicRequired.
  ///
  /// In en, this message translates to:
  /// **'Select 1-5 categories for public cookbooks'**
  String get cookbooksCategoryPublicRequired;

  /// No description provided for @cookbooksPublicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Public cookbooks are visible to others'**
  String get cookbooksPublicSubtitle;

  /// No description provided for @cookbooksBasicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Basics'**
  String get cookbooksBasicsTitle;

  /// No description provided for @cookbooksNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Cookbook name'**
  String get cookbooksNameLabel;

  /// No description provided for @cookbooksChooseImage.
  ///
  /// In en, this message translates to:
  /// **'Choose image'**
  String get cookbooksChooseImage;

  /// No description provided for @cookbooksCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get cookbooksCategoriesTitle;

  /// No description provided for @cookbooksCategoriesPublicHint.
  ///
  /// In en, this message translates to:
  /// **'Select 1-5 categories so others can find your cookbook.'**
  String get cookbooksCategoriesPublicHint;

  /// No description provided for @cookbooksCategoriesPrivateHint.
  ///
  /// In en, this message translates to:
  /// **'Optional: add up to 5 categories.'**
  String get cookbooksCategoriesPrivateHint;

  /// No description provided for @cookbooksCategoriesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count}/5 selected'**
  String cookbooksCategoriesSelected(int count);

  /// No description provided for @cookbooksCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create cookbook'**
  String get cookbooksCreateTitle;

  /// No description provided for @cookbooksBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get cookbooksBack;

  /// No description provided for @cookbooksNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get cookbooksNext;

  /// No description provided for @cookbooksCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get cookbooksCreate;

  /// No description provided for @recipeDifficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get recipeDifficultyMedium;

  /// No description provided for @recipeSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Recipe \"{title}\" saved and added to My recipes'**
  String recipeSaveSuccess(Object title);

  /// No description provided for @recipeSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save/publish recipe: {error}'**
  String recipeSaveFailed(Object error);

  /// No description provided for @recipeCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create recipe'**
  String get recipeCreateTitle;

  /// No description provided for @recipeEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit recipe'**
  String get recipeEditTitle;

  /// No description provided for @recipeOnlyChefBody.
  ///
  /// In en, this message translates to:
  /// **'Only chef accounts can upload recipes.\n\nUpgrade to a chef plan to start creating recipes.'**
  String get recipeOnlyChefBody;

  /// No description provided for @recipeFreePlanLimitBody.
  ///
  /// In en, this message translates to:
  /// **'You have reached the upload limit for the free chef plan.\n\nUpgrade to a premium chef plan to create more recipes.'**
  String get recipeFreePlanLimitBody;

  /// No description provided for @recipePhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipe photo'**
  String get recipePhotoLabel;

  /// No description provided for @recipeTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get recipeTakePhoto;

  /// No description provided for @recipePhotoLibrary.
  ///
  /// In en, this message translates to:
  /// **'Photo library'**
  String get recipePhotoLibrary;

  /// No description provided for @recipePickFile.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get recipePickFile;

  /// No description provided for @recipeUploadLimitBanner.
  ///
  /// In en, this message translates to:
  /// **'Free chef plan - recipe upload is limited.\nUpgrade to premium chef to remove this limit.'**
  String get recipeUploadLimitBanner;

  /// No description provided for @recipeTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipe title'**
  String get recipeTitleLabel;

  /// No description provided for @recipeIngredientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get recipeIngredientsTitle;

  /// No description provided for @recipeIngredientLabel.
  ///
  /// In en, this message translates to:
  /// **'Ingredient'**
  String get recipeIngredientLabel;

  /// No description provided for @recipeQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get recipeQuantityLabel;

  /// No description provided for @recipeUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get recipeUnitLabel;

  /// No description provided for @recipeAddIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get recipeAddIngredient;

  /// No description provided for @recipeToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tools / Equipment'**
  String get recipeToolsTitle;

  /// No description provided for @recipeToolLabel.
  ///
  /// In en, this message translates to:
  /// **'Tool'**
  String get recipeToolLabel;

  /// No description provided for @recipeAddTool.
  ///
  /// In en, this message translates to:
  /// **'Add tool'**
  String get recipeAddTool;

  /// No description provided for @recipePreCookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Preparation before cooking'**
  String get recipePreCookingTitle;

  /// No description provided for @recipePreCookingHint.
  ///
  /// In en, this message translates to:
  /// **'For example: preheat oven to 200C, line the tray, soak beans overnight...'**
  String get recipePreCookingHint;

  /// No description provided for @recipeStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get recipeStepsTitle;

  /// No description provided for @recipeAddStep.
  ///
  /// In en, this message translates to:
  /// **'Add step'**
  String get recipeAddStep;

  /// No description provided for @recipePreviewInPlayer.
  ///
  /// In en, this message translates to:
  /// **'Preview in player'**
  String get recipePreviewInPlayer;

  /// No description provided for @recipeUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update recipe'**
  String get recipeUpdateButton;

  /// No description provided for @recipeSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save recipe'**
  String get recipeSaveButton;

  /// No description provided for @recipeStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get recipeStepLabel;

  /// No description provided for @recipeStepMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get recipeStepMinutesLabel;

  /// No description provided for @recipeRemoveStepTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove step'**
  String get recipeRemoveStepTooltip;

  /// No description provided for @recipeDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete recipe'**
  String get recipeDeleteButton;

  /// No description provided for @recipeDeleteStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Delete recipe?'**
  String get recipeDeleteStep1Title;

  /// No description provided for @recipeDeleteStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this recipe?'**
  String get recipeDeleteStep1Body;

  /// No description provided for @recipeDeleteStep1Continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get recipeDeleteStep1Continue;

  /// No description provided for @recipeDeleteStep2Title.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone'**
  String get recipeDeleteStep2Title;

  /// No description provided for @recipeDeleteStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Deleting this recipe will remove it permanently.'**
  String get recipeDeleteStep2Body;

  /// No description provided for @recipeDeleteStep2Delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get recipeDeleteStep2Delete;

  /// No description provided for @recipeDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete recipe: {error}'**
  String recipeDeleteFailed(Object error);

  /// No description provided for @importDocTitle.
  ///
  /// In en, this message translates to:
  /// **'Import recipe from document'**
  String get importDocTitle;

  /// No description provided for @importDocHeader.
  ///
  /// In en, this message translates to:
  /// **'Import a recipe from a document'**
  String get importDocHeader;

  /// No description provided for @importDocBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a clean recipe file or photo. We will keep things steady while we read it and create a recipe for you.'**
  String get importDocBody;

  /// No description provided for @importDocFileReady.
  ///
  /// In en, this message translates to:
  /// **'File ready'**
  String get importDocFileReady;

  /// No description provided for @importDocAddDocument.
  ///
  /// In en, this message translates to:
  /// **'Add a recipe document'**
  String get importDocAddDocument;

  /// No description provided for @importDocFormatsShort.
  ///
  /// In en, this message translates to:
  /// **'PDF, DOCX, JPG, PNG, WEBP'**
  String get importDocFormatsShort;

  /// No description provided for @importDocProcessingNote.
  ///
  /// In en, this message translates to:
  /// **'We will keep your upload stable while we process it.'**
  String get importDocProcessingNote;

  /// No description provided for @importDocEmptyHelper.
  ///
  /// In en, this message translates to:
  /// **'No file chosen yet. Add a clear recipe file or photo to continue.'**
  String get importDocEmptyHelper;

  /// No description provided for @importDocChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get importDocChooseFile;

  /// No description provided for @importDocChoosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get importDocChoosePhoto;

  /// No description provided for @importDocTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get importDocTakePhoto;

  /// No description provided for @importDocTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips for a calm import'**
  String get importDocTipsTitle;

  /// No description provided for @importDocTip1.
  ///
  /// In en, this message translates to:
  /// **'Use a well-lit photo with the full recipe visible.'**
  String get importDocTip1;

  /// No description provided for @importDocTip2.
  ///
  /// In en, this message translates to:
  /// **'Stay on this screen until we send you to the recipe.'**
  String get importDocTip2;

  /// No description provided for @importDocTip3.
  ///
  /// In en, this message translates to:
  /// **'You can edit details after the import finishes.'**
  String get importDocTip3;

  /// No description provided for @importDocUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload and import'**
  String get importDocUpload;

  /// No description provided for @importDocSupportedFooter.
  ///
  /// In en, this message translates to:
  /// **'Supported: PDF, DOC, DOCX, JPG, PNG, WEBP. Larger files may take longer to process.'**
  String get importDocSupportedFooter;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @addSelected.
  ///
  /// In en, this message translates to:
  /// **'Add selected'**
  String get addSelected;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @chefByLine.
  ///
  /// In en, this message translates to:
  /// **'By {name}'**
  String chefByLine(Object name);

  /// No description provided for @chefFollowLabel.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get chefFollowLabel;

  /// No description provided for @chefFollowSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in to follow chefs'**
  String get chefFollowSignInRequired;

  /// No description provided for @chefFollowUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update follow: {error}'**
  String chefFollowUpdateFailed(Object error);

  /// No description provided for @chefFollowingLabel.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get chefFollowingLabel;

  /// No description provided for @chefMyRecipesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your recipes'**
  String get chefMyRecipesSubtitle;

  /// No description provided for @chefNoCookbooks.
  ///
  /// In en, this message translates to:
  /// **'No cookbooks yet'**
  String get chefNoCookbooks;

  /// No description provided for @chefNotEnabledBody.
  ///
  /// In en, this message translates to:
  /// **'Chef tools are available for chef accounts.'**
  String get chefNotEnabledBody;

  /// No description provided for @chefNotEnabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Chef tools unavailable'**
  String get chefNotEnabledTitle;

  /// No description provided for @chefNotFound.
  ///
  /// In en, this message translates to:
  /// **'Chef not found'**
  String get chefNotFound;

  /// No description provided for @chefPremiumFeaturesBody.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium Chef to unlock publishing, cookbooks, and insights.'**
  String get chefPremiumFeaturesBody;

  /// No description provided for @chefPremiumFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium features'**
  String get chefPremiumFeaturesTitle;

  /// No description provided for @chefPublicCookbook.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get chefPublicCookbook;

  /// No description provided for @chefUploadNewRecipe.
  ///
  /// In en, this message translates to:
  /// **'Upload new recipe'**
  String get chefUploadNewRecipe;

  /// No description provided for @chefUploadNewRecipeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import a recipe document or create manually.'**
  String get chefUploadNewRecipeSubtitle;

  /// No description provided for @cookbooksAddRecipeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add recipe: {error}'**
  String cookbooksAddRecipeFailed(Object error);

  /// No description provided for @cookbooksAddRecipes.
  ///
  /// In en, this message translates to:
  /// **'Add recipes'**
  String get cookbooksAddRecipes;

  /// No description provided for @cookbooksAddingRecipes.
  ///
  /// In en, this message translates to:
  /// **'Adding recipes...'**
  String get cookbooksAddingRecipes;

  /// No description provided for @cookbooksCoverImage.
  ///
  /// In en, this message translates to:
  /// **'Cover image'**
  String get cookbooksCoverImage;

  /// No description provided for @cookbooksDeleteWarning.
  ///
  /// In en, this message translates to:
  /// **'Delete this cookbook? This cannot be undone.'**
  String get cookbooksDeleteWarning;

  /// No description provided for @cookbooksDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get cookbooksDescriptionLabel;

  /// No description provided for @cookbooksEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit cookbook'**
  String get cookbooksEditTitle;

  /// No description provided for @cookbooksLoadRecipesFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load recipes: {error}'**
  String cookbooksLoadRecipesFailed(Object error);

  /// No description provided for @cookbooksLoadRecipesFailedDetail.
  ///
  /// In en, this message translates to:
  /// **'Failed to load recipes. Please try again.'**
  String get cookbooksLoadRecipesFailedDetail;

  /// No description provided for @cookbooksLoadRecipesFailedSimple.
  ///
  /// In en, this message translates to:
  /// **'Failed to load recipes'**
  String get cookbooksLoadRecipesFailedSimple;

  /// No description provided for @cookbooksNoRecipesAvailable.
  ///
  /// In en, this message translates to:
  /// **'This cookbook has no recipes available.'**
  String get cookbooksNoRecipesAvailable;

  /// No description provided for @cookbooksNoRecipesToAdd.
  ///
  /// In en, this message translates to:
  /// **'No recipes available to add.'**
  String get cookbooksNoRecipesToAdd;

  /// No description provided for @cookbooksNoRecipesYet.
  ///
  /// In en, this message translates to:
  /// **'This cookbook has no recipes yet.'**
  String get cookbooksNoRecipesYet;

  /// No description provided for @cookbooksPlaylistTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Playlist title'**
  String get cookbooksPlaylistTitleLabel;

  /// No description provided for @cookbooksPlaylistTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a playlist title'**
  String get cookbooksPlaylistTitleRequired;

  /// No description provided for @cookbooksPublicCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create public cookbook'**
  String get cookbooksPublicCreateTitle;

  /// No description provided for @cookbooksPublicCreated.
  ///
  /// In en, this message translates to:
  /// **'Public playlist created'**
  String get cookbooksPublicCreated;

  /// No description provided for @cookbooksPublicLabel.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get cookbooksPublicLabel;

  /// No description provided for @cookbooksPublicNoRecipesBody.
  ///
  /// In en, this message translates to:
  /// **'You have no recipes to add yet.\nUpload recipes to create a public cookbook.'**
  String get cookbooksPublicNoRecipesBody;

  /// No description provided for @cookbooksRecipesAdded.
  ///
  /// In en, this message translates to:
  /// **'Recipes added to cookbook'**
  String get cookbooksRecipesAdded;

  /// No description provided for @cookbooksSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get cookbooksSaveChanges;

  /// No description provided for @cookbooksSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String cookbooksSaveFailed(Object error);

  /// No description provided for @cookbooksSaveToMy.
  ///
  /// In en, this message translates to:
  /// **'Save to my cookbooks'**
  String get cookbooksSaveToMy;

  /// No description provided for @cookbooksSavedToMy.
  ///
  /// In en, this message translates to:
  /// **'Saved {name} to your cookbooks'**
  String cookbooksSavedToMy(Object name);

  /// No description provided for @cookbooksSelectAtLeastOneRecipe.
  ///
  /// In en, this message translates to:
  /// **'Select at least one recipe'**
  String get cookbooksSelectAtLeastOneRecipe;

  /// No description provided for @cookbooksSelectRecipes.
  ///
  /// In en, this message translates to:
  /// **'Select recipes'**
  String get cookbooksSelectRecipes;

  /// No description provided for @cookbooksSelectRecipesToInclude.
  ///
  /// In en, this message translates to:
  /// **'Select recipes to include'**
  String get cookbooksSelectRecipesToInclude;

  /// No description provided for @cookbooksUpdated.
  ///
  /// In en, this message translates to:
  /// **'Cookbook updated'**
  String get cookbooksUpdated;

  /// No description provided for @discoverChefsToFollow.
  ///
  /// In en, this message translates to:
  /// **'Chefs to follow'**
  String get discoverChefsToFollow;

  /// No description provided for @discoverFollowersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} followers'**
  String discoverFollowersCount(int count);

  /// No description provided for @discoverNoChefsYet.
  ///
  /// In en, this message translates to:
  /// **'No chefs to follow yet'**
  String get discoverNoChefsYet;

  /// No description provided for @durationHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr'**
  String durationHours(int hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr {minutes} min'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @goHomeButton.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHomeButton;

  /// No description provided for @importDocEmptyFile.
  ///
  /// In en, this message translates to:
  /// **'File is empty. Choose another file.'**
  String get importDocEmptyFile;

  /// No description provided for @importDocOverlayErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t process this file'**
  String get importDocOverlayErrorTitle;

  /// No description provided for @importDocOverlayProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get importDocOverlayProcessing;

  /// No description provided for @importDocOverlayUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get importDocOverlayUploading;

  /// No description provided for @importDocPickPhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick photo: {error}'**
  String importDocPickPhotoFailed(Object error);

  /// No description provided for @importDocReadBytesFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to read file: {error}'**
  String importDocReadBytesFailed(Object error);

  /// No description provided for @importDocSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in to upload recipes.'**
  String get importDocSignInRequired;

  /// No description provided for @importDocStepSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving recipe'**
  String get importDocStepSaving;

  /// No description provided for @importDocStepUnderstanding.
  ///
  /// In en, this message translates to:
  /// **'Understanding recipe'**
  String get importDocStepUnderstanding;

  /// No description provided for @importDocStepUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading file'**
  String get importDocStepUploading;

  /// No description provided for @importDocTakePhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to take photo: {error}'**
  String importDocTakePhotoFailed(Object error);

  /// No description provided for @importDocUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get importDocUploadFailed;

  /// No description provided for @importDocUploadFailedCode.
  ///
  /// In en, this message translates to:
  /// **'Upload failed ({code})'**
  String importDocUploadFailedCode(Object code);

  /// No description provided for @importDocUploadFailedWithError.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String importDocUploadFailedWithError(Object error);

  /// No description provided for @importDocUploaded.
  ///
  /// In en, this message translates to:
  /// **'Upload complete'**
  String get importDocUploaded;

  /// No description provided for @importedRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Imported recipe'**
  String get importedRecipeTitle;

  /// No description provided for @playlistPlayAll.
  ///
  /// In en, this message translates to:
  /// **'Play all'**
  String get playlistPlayAll;

  /// No description provided for @playlistPlayAllNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Play all is not implemented yet'**
  String get playlistPlayAllNotImplemented;

  /// No description provided for @playlistPlayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlist - {title}'**
  String playlistPlayerTitle(Object title);

  /// No description provided for @playlistStepCookFirstRecipe.
  ///
  /// In en, this message translates to:
  /// **'Cook the first recipe according to its instructions.'**
  String get playlistStepCookFirstRecipe;

  /// No description provided for @playlistStepCookRemaining.
  ///
  /// In en, this message translates to:
  /// **'Cook the rest of the playlist.'**
  String get playlistStepCookRemaining;

  /// No description provided for @playlistStepPrepIngredients.
  ///
  /// In en, this message translates to:
  /// **'Prepare ingredients for the first recipe.'**
  String get playlistStepPrepIngredients;

  /// No description provided for @playlistStepPrepNextRecipe.
  ///
  /// In en, this message translates to:
  /// **'Prepare the next recipe in the playlist.'**
  String get playlistStepPrepNextRecipe;

  /// No description provided for @recipeAddIngredientsToCart.
  ///
  /// In en, this message translates to:
  /// **'Add ingredients to cart'**
  String get recipeAddIngredientsToCart;

  /// No description provided for @recipeAddToCartFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add to cart'**
  String get recipeAddToCartFailed;

  /// No description provided for @recipeAddToCookbook.
  ///
  /// In en, this message translates to:
  /// **'Add to cookbook'**
  String get recipeAddToCookbook;

  /// No description provided for @recipeAddToCookbookFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add to cookbook: {error}'**
  String recipeAddToCookbookFailed(Object error);

  /// No description provided for @recipeAddToCookbooksTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to cookbooks'**
  String get recipeAddToCookbooksTitle;

  /// No description provided for @recipeAddToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get recipeAddToFavorites;

  /// No description provided for @recipeAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added {count} items to cart'**
  String recipeAddedToCart(int count);

  /// No description provided for @recipeAddedToCookbooks.
  ///
  /// In en, this message translates to:
  /// **'Added to cookbooks'**
  String get recipeAddedToCookbooks;

  /// No description provided for @recipeAddedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get recipeAddedToFavorites;

  /// No description provided for @recipeAttachDialogFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load cookbooks'**
  String get recipeAttachDialogFailed;

  /// No description provided for @recipeCookbooksLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load cookbooks'**
  String get recipeCookbooksLoadFailed;

  /// No description provided for @recipeCoverUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload cover: {error}'**
  String recipeCoverUploadFailed(Object error);

  /// No description provided for @recipeCreateCookbookFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a cookbook first'**
  String get recipeCreateCookbookFirst;

  /// No description provided for @recipeDifficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get recipeDifficultyEasy;

  /// No description provided for @recipeEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get recipeEditButton;

  /// No description provided for @recipeImportFailedBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t import this recipe. Try again or go Home.'**
  String get recipeImportFailedBody;

  /// No description provided for @recipeImportFailedScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get recipeImportFailedScreenTitle;

  /// No description provided for @recipeImportFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get recipeImportFailedTitle;

  /// No description provided for @recipeImportNeedsReviewBody.
  ///
  /// In en, this message translates to:
  /// **'We imported the recipe but it needs review. You can edit it now.'**
  String get recipeImportNeedsReviewBody;

  /// No description provided for @recipeImportNeedsReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get recipeImportNeedsReviewTitle;

  /// No description provided for @recipeImportProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Still working on it'**
  String get recipeImportProcessingTitle;

  /// No description provided for @recipeImportStepExtractingText.
  ///
  /// In en, this message translates to:
  /// **'Extracting text'**
  String get recipeImportStepExtractingText;

  /// No description provided for @recipeImportStepFinalizing.
  ///
  /// In en, this message translates to:
  /// **'Finalizing'**
  String get recipeImportStepFinalizing;

  /// No description provided for @recipeImportStepUnderstanding.
  ///
  /// In en, this message translates to:
  /// **'Understanding recipe'**
  String get recipeImportStepUnderstanding;

  /// No description provided for @recipeImportStepUploadComplete.
  ///
  /// In en, this message translates to:
  /// **'Upload complete'**
  String get recipeImportStepUploadComplete;

  /// No description provided for @recipeImportTimeoutBody.
  ///
  /// In en, this message translates to:
  /// **'This is taking longer than expected. You can try again or go Home.'**
  String get recipeImportTimeoutBody;

  /// No description provided for @recipeImportTimeoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Import timeout'**
  String get recipeImportTimeoutTitle;

  /// No description provided for @recipeImportUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown import error'**
  String get recipeImportUnknownError;

  /// No description provided for @recipeNoIngredients.
  ///
  /// In en, this message translates to:
  /// **'No ingredients yet'**
  String get recipeNoIngredients;

  /// No description provided for @recipeNoIngredientsToAdd.
  ///
  /// In en, this message translates to:
  /// **'No ingredients to add'**
  String get recipeNoIngredientsToAdd;

  /// No description provided for @recipeNoSteps.
  ///
  /// In en, this message translates to:
  /// **'No steps yet'**
  String get recipeNoSteps;

  /// No description provided for @recipeNoTools.
  ///
  /// In en, this message translates to:
  /// **'No tools listed'**
  String get recipeNoTools;

  /// No description provided for @recipeNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find this recipe.'**
  String get recipeNotFoundBody;

  /// No description provided for @recipeNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe not found'**
  String get recipeNotFoundTitle;

  /// No description provided for @recipeOcrPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'OCR preview'**
  String get recipeOcrPreviewLabel;

  /// No description provided for @recipeOriginalLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get recipeOriginalLanguageLabel;

  /// No description provided for @recipePlayerHandsFreeMode.
  ///
  /// In en, this message translates to:
  /// **'Hands-free mode'**
  String get recipePlayerHandsFreeMode;

  /// No description provided for @recipePlayerHandsFreeOn.
  ///
  /// In en, this message translates to:
  /// **'Hands-free mode ON'**
  String get recipePlayerHandsFreeOn;

  /// No description provided for @recipePlayerNoSteps.
  ///
  /// In en, this message translates to:
  /// **'No steps available'**
  String get recipePlayerNoSteps;

  /// No description provided for @recipePlayerStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String recipePlayerStepOf(int current, int total);

  /// No description provided for @recipePlayerStepPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String recipePlayerStepPlaceholder(int number);

  /// No description provided for @recipePlayerVoiceControl.
  ///
  /// In en, this message translates to:
  /// **'Voice control'**
  String get recipePlayerVoiceControl;

  /// No description provided for @recipeProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get recipeProcessing;

  /// No description provided for @recipeRemoveFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get recipeRemoveFromFavorites;

  /// No description provided for @recipeRemovedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get recipeRemovedFromFavorites;

  /// No description provided for @recipeSignInToSave.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save recipes.'**
  String get recipeSignInToSave;

  /// No description provided for @recipeStartCooking.
  ///
  /// In en, this message translates to:
  /// **'Start cooking'**
  String get recipeStartCooking;

  /// No description provided for @recipeStepRequired.
  ///
  /// In en, this message translates to:
  /// **'Step is required'**
  String get recipeStepRequired;

  /// No description provided for @recipeTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get recipeTitleRequired;

  /// No description provided for @recipeTranslateToEnglish.
  ///
  /// In en, this message translates to:
  /// **'Translate to English'**
  String get recipeTranslateToEnglish;

  /// No description provided for @recipeTranslatedFrom.
  ///
  /// In en, this message translates to:
  /// **'Translated from {language}'**
  String recipeTranslatedFrom(Object language);

  /// No description provided for @recipeTranslating.
  ///
  /// In en, this message translates to:
  /// **'Translating'**
  String get recipeTranslating;

  /// No description provided for @recipeTranslationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Translation is unavailable'**
  String get recipeTranslationUnavailable;

  /// No description provided for @recipeUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'This recipe isn\'t available right now.'**
  String get recipeUnavailableBody;

  /// No description provided for @recipeUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe unavailable'**
  String get recipeUnavailableTitle;

  /// No description provided for @recipeViewChef.
  ///
  /// In en, this message translates to:
  /// **'View chef'**
  String get recipeViewChef;

  /// No description provided for @recipeViewOriginal.
  ///
  /// In en, this message translates to:
  /// **'View original'**
  String get recipeViewOriginal;

  /// No description provided for @recipesLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipesLabel;

  /// No description provided for @chefSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile'**
  String get chefSaveFailed;

  /// No description provided for @chefEditOwnOnly.
  ///
  /// In en, this message translates to:
  /// **'You can only edit your own profile.'**
  String get chefEditOwnOnly;

  /// No description provided for @chefEditAvatarLabel.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get chefEditAvatarLabel;

  /// No description provided for @chefEditChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get chefEditChangePhoto;

  /// No description provided for @chefEditBioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get chefEditBioLabel;

  /// No description provided for @chefEditBioHint.
  ///
  /// In en, this message translates to:
  /// **'Tell followers about your cooking style, specialties, and inspirations.'**
  String get chefEditBioHint;

  /// No description provided for @chefEditMakeChangeToSave.
  ///
  /// In en, this message translates to:
  /// **'Make a change to enable Save.'**
  String get chefEditMakeChangeToSave;

  /// No description provided for @chefNoRecipesYet.
  ///
  /// In en, this message translates to:
  /// **'You have not published any recipes yet'**
  String get chefNoRecipesYet;

  /// No description provided for @chefLoadRecipesFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load recipes. Please try again.'**
  String get chefLoadRecipesFailed;

  /// No description provided for @chefRecipeStats.
  ///
  /// In en, this message translates to:
  /// **'Views: {views} • Saves: {saves}'**
  String chefRecipeStats(int views, int saves);

  /// No description provided for @chefRecipeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Recipe \"{title}\" deleted'**
  String chefRecipeDeleted(Object title);

  /// No description provided for @discoverFeaturedCookbooks.
  ///
  /// In en, this message translates to:
  /// **'Featured cookbooks'**
  String get discoverFeaturedCookbooks;

  /// No description provided for @discoverCookbookLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load cookbook'**
  String get discoverCookbookLoadFailed;

  /// No description provided for @discoverCookbookNotFound.
  ///
  /// In en, this message translates to:
  /// **'Cookbook not found'**
  String get discoverCookbookNotFound;

  /// No description provided for @discoverCookbookNoRecipes.
  ///
  /// In en, this message translates to:
  /// **'No recipes in this cookbook yet.'**
  String get discoverCookbookNoRecipes;

  /// No description provided for @discoverCookbookNoRecipesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No recipes available.'**
  String get discoverCookbookNoRecipesAvailable;

  /// No description provided for @discoverRecipesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load recipes'**
  String get discoverRecipesLoadFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'es',
    'fr',
    'he',
    'it',
    'ja',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'he':
      return AppLocalizationsHe();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
