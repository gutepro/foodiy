import 'package:flutter/material.dart';

class FoodiyTheme {
  FoodiyTheme._();

  static const Color _backgroundColor = Color(0xFFFDF4E3);

  static ThemeData get light {
    final baseScheme = ColorScheme.fromSeed(seedColor: Colors.deepOrange);
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _backgroundColor,
      colorScheme: baseScheme.copyWith(
        // ignore: deprecated_member_use
        background: _backgroundColor,
      ),
    );
  }
}
