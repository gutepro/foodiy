import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FoodiyTheme {
  FoodiyTheme._();

  static const Color _white = Color(0xFFFFFFFF);
  static const Color _lightGray = Color(0xFFF5F5F5);
  static const Color _textCharcoal = Color(0xFF333333);
  static const Color _avocadoGreen = Color(0xFF708A5E);
  static const Color _pumpkinOrange = Color(0xFFFF914D);
  static const Color sweetPotatoOrange = Color(0xFFEF8354);

  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: _avocadoGreen,
      onPrimary: _white,
      secondary: _lightGray,
      onSecondary: _textCharcoal,
      surface: _white,
      onSurface: _textCharcoal,
      background: _white,
      onBackground: _textCharcoal,
      error: Colors.red,
      onError: _white,
      surfaceVariant: _lightGray,
      onSurfaceVariant: _textCharcoal,
      outline: Color(0xFFDDDDDD),
      outlineVariant: Color(0xFFEEEEEE),
      tertiary: _pumpkinOrange,
      onTertiary: _white,
      shadow: Colors.black26,
      scrim: Colors.black54,
      inverseSurface: _textCharcoal,
      inversePrimary: _white,
    );

    final baseText = ThemeData.light().textTheme.apply(
          bodyColor: _textCharcoal,
          displayColor: _textCharcoal,
        );
    final textTheme = GoogleFonts.interTextTheme(baseText).apply(
      fontFamilyFallback: const ['Rubik'],
      bodyColor: _textCharcoal,
      displayColor: _textCharcoal,
    ).copyWith(
      headlineSmall: GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 22,
        height: 1.25,
      ),
      titleLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        height: 1.3,
      ),
      titleMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        height: 1.35,
      ),
      bodyLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        height: 1.45,
      ),
      bodyMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 1.45,
      ),
      bodySmall: GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        height: 1.3,
      ),
      labelMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        height: 1.3,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _white,
      canvasColor: _white,
      colorScheme: scheme,
      cardColor: _lightGray,
      appBarTheme: const AppBarTheme(
        backgroundColor: _white,
        foregroundColor: _textCharcoal,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _avocadoGreen,
          foregroundColor: _white,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size.fromHeight(44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _textCharcoal,
          side: const BorderSide(color: Color(0xFFDDDDDD)),
          textStyle: baseText.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _avocadoGreen,
          textStyle: baseText.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        fillColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.selected)) return _avocadoGreen;
          return null;
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _avocadoGreen, width: 1.4),
        ),
        labelStyle: baseText.bodyMedium?.copyWith(color: _textCharcoal),
        hintStyle: baseText.bodyMedium?.copyWith(color: Colors.grey.shade600),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _lightGray,
        selectedColor: _avocadoGreen.withOpacity(0.14),
        disabledColor: _lightGray,
        labelStyle: baseText.labelMedium ?? const TextStyle(),
        secondaryLabelStyle: baseText.labelMedium ?? const TextStyle(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      dividerColor: const Color(0xFFDDDDDD),
    );
  }
}
