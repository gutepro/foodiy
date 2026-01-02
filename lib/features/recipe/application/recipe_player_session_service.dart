import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerSession {
  final String sessionId;
  final String recipeId;
  final int stepIndex;
  final bool isPlaying;
  final int? timerEndEpochMs;
  final int? pausedRemainingMs;
  final int lastUpdatedEpochMs;

  const PlayerSession({
    required this.sessionId,
    required this.recipeId,
    required this.stepIndex,
    required this.isPlaying,
    required this.lastUpdatedEpochMs,
    this.timerEndEpochMs,
    this.pausedRemainingMs,
  });

  PlayerSession copyWith({
    String? sessionId,
    String? recipeId,
    int? stepIndex,
    bool? isPlaying,
    int? timerEndEpochMs,
    int? pausedRemainingMs,
    int? lastUpdatedEpochMs,
  }) {
    return PlayerSession(
      sessionId: sessionId ?? this.sessionId,
      recipeId: recipeId ?? this.recipeId,
      stepIndex: stepIndex ?? this.stepIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      timerEndEpochMs: timerEndEpochMs ?? this.timerEndEpochMs,
      pausedRemainingMs: pausedRemainingMs ?? this.pausedRemainingMs,
      lastUpdatedEpochMs: lastUpdatedEpochMs ?? this.lastUpdatedEpochMs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'recipeId': recipeId,
      'stepIndex': stepIndex,
      'isPlaying': isPlaying,
      'timerEndEpochMs': timerEndEpochMs,
      'pausedRemainingMs': pausedRemainingMs,
      'lastUpdatedEpochMs': lastUpdatedEpochMs,
    };
  }

  factory PlayerSession.fromJson(Map<String, dynamic> json) {
    return PlayerSession(
      sessionId: json['sessionId'] as String? ?? _randomSessionId(),
      recipeId: json['recipeId'] as String? ?? '',
      stepIndex: json['stepIndex'] as int? ?? 0,
      isPlaying: json['isPlaying'] as bool? ?? false,
      timerEndEpochMs: json['timerEndEpochMs'] as int?,
      pausedRemainingMs: json['pausedRemainingMs'] as int?,
      lastUpdatedEpochMs: json['lastUpdatedEpochMs'] as int? ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }
}

String _randomSessionId() {
  final now = DateTime.now().microsecondsSinceEpoch;
  final random = Random().nextInt(1 << 32);
  return '$now-$random';
}

class RecipePlayerSessionService {
  RecipePlayerSessionService._internal();

  static final RecipePlayerSessionService instance =
      RecipePlayerSessionService._internal();

  static const _sessionKey = 'player_session';
  static const Duration maxAge = Duration(hours: 24);

  Future<void> saveSession(PlayerSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(session.toJson());
    await prefs.setString(_sessionKey, jsonStr);
    debugPrint('RecipePlayerSessionService: saved session for recipe=${session.recipeId}');
  }

  Future<PlayerSession?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_sessionKey);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      return PlayerSession.fromJson(data);
    } catch (e) {
      debugPrint('RecipePlayerSessionService: failed to decode session: $e');
      return null;
    }
  }

  Future<PlayerSession?> loadValidSession() async {
    final session = await loadSession();
    if (session == null) return null;
    final now = DateTime.now().millisecondsSinceEpoch;
    final age = now - session.lastUpdatedEpochMs;
    if (age > maxAge.inMilliseconds) {
      await clearSession();
      return null;
    }
    return session;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    debugPrint('RecipePlayerSessionService: cleared session');
  }
}
