import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  SettingsService._internal();

  static final SettingsService _instance = SettingsService._internal();
  static SettingsService get instance => _instance;

  bool playTimerSound = true; // TODO: persist to storage.

  // Notification toggles
  bool notifyNewChefRecipes = true;
  bool notifyPlaylistSuggestions = true;
  bool notifyAppTips = true;

  // Language and units
  static const _localeKey = 'app_locale';
  final ValueNotifier<String?> _selectedLocaleCodeNotifier =
      ValueNotifier<String?>(null); // null/'' follows device

  String? get selectedLocaleCode => _selectedLocaleCodeNotifier.value;
  ValueListenable<String?> get localeListenable => _selectedLocaleCodeNotifier;

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_localeKey) ?? '';
    final code = stored.isEmpty ? null : stored;
    _selectedLocaleCodeNotifier.value = code;
    debugPrint(
      '[LOCALE_INIT] stored=$stored resolved=${_logLocale(code)}',
    );
  }

  Future<void> setSelectedLocaleCode(String? code) async {
    final normalized = (code == null || code.isEmpty) ? null : code;
    _selectedLocaleCodeNotifier.value = normalized;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, normalized ?? '');
    debugPrint('[LOCALE_SET] selected=${_logLocale(normalized)}');
  }

  Locale? get resolvedLocale {
    final code = _selectedLocaleCodeNotifier.value;
    if (code == null || code.isEmpty) return null;
    return Locale(code);
  }

  String _logLocale(String? code) => (code == null || code.isEmpty)
      ? 'system'
      : code;

  String preferredUnits = 'metric'; // 'metric' or 'imperial'
}
