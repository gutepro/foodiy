class SettingsService {
  SettingsService._internal();

  static final SettingsService _instance = SettingsService._internal();
  static SettingsService get instance => _instance;

  bool playTimerSound = true; // TODO: persist to storage.

  // Notification toggles
  bool notifyNewChefRecipes = true;
  bool notifyPlaylistSuggestions = true;
  bool notifyAppTips = true;

  // Language and units
  String preferredLanguageCode = 'auto'; // 'auto' follows device
  String preferredUnits = 'metric'; // 'metric' or 'imperial'
}
