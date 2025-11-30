class SettingsService {
  SettingsService._internal();

  static final SettingsService _instance = SettingsService._internal();
  static SettingsService get instance => _instance;

  bool playTimerSound = true; // TODO: persist to storage.
}
