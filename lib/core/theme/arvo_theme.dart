import 'package:flutter/material.dart';
import 'arvo_colors.dart';
import 'arvo_typography.dart';

class ArvoTheme {
  ArvoTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ArvoColors.nevoa,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ArvoColors.petroleo,
        primary: ArvoColors.petroleo,
        secondary: ArvoColors.folha,
        tertiary: ArvoColors.ambar,
        surface: ArvoColors.cardFundo,
        surfaceContainerLowest: ArvoColors.nevoa,
        error: ArvoColors.erro,
      ),
      fontFamily: ArvoTypography.fontBody,
      appBarTheme: const AppBarTheme(
        backgroundColor: ArvoColors.petroleo,
        foregroundColor: ArvoColors.nevoa,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: ArvoTypography.fontHeading,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ArvoColors.nevoa,
        ),
      ),
      cardTheme: CardThemeData(
        color: ArvoColors.cardFundo,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ArvoColors.linha, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ArvoColors.petroleo,
          foregroundColor: ArvoColors.nevoa,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: ArvoTypography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ArvoColors.petroleo,
          side: const BorderSide(color: ArvoColors.petroleo, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: ArvoTypography.button.copyWith(color: ArvoColors.petroleo),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ArvoColors.linha),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ArvoColors.linha),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ArvoColors.folha, width: 1.8),
        ),
        hintStyle: const TextStyle(
          fontFamily: ArvoTypography.fontBody,
          color: ArvoColors.musgo,
          fontSize: 14,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ArvoColors.linha,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
