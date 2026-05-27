import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _theme(
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E8F68),
          brightness: Brightness.light,
        ),
      );

  static ThemeData dark() => _theme(
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF22C493),
          brightness: Brightness.dark,
        ),
      );

  static ThemeData _theme(ColorScheme colorScheme) {
    final base = ThemeData(useMaterial3: true, colorScheme: colorScheme);
    final textTheme = GoogleFonts.nunitoSansTextTheme(base.textTheme);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colorScheme.surfaceContainerHigh,
        surfaceTintColor: colorScheme.primary.withValues(alpha: .08),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: .55)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: .70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
    );
  }
}
