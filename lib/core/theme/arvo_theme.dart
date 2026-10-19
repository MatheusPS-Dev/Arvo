import 'package:flutter/material.dart';
import 'arvo_colors.dart';
import 'arvo_typography.dart';

/// Tema Material 3 completo do sistema Arvô, aplicando as diretrizes
/// UI/UX Pro Max (estados hover/focus/pressed visíveis, touch targets >= 48px,
/// contraste WCAG AA/AAA e tokens semânticos da identidade visual oficial).
class ArvoTheme {
  ArvoTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ArvoColors.petroleo,
      brightness: Brightness.light,
      primary: ArvoColors.petroleo,
      onPrimary: ArvoColors.nevoa,
      primaryContainer: ArvoColors.superficieDestaque,
      onPrimaryContainer: ArvoColors.petroleo,
      secondary: ArvoColors.folha,
      onSecondary: Colors.white,
      secondaryContainer: ArvoColors.sucessoFundo,
      onSecondaryContainer: ArvoColors.sucessoTexto,
      tertiary: ArvoColors.ambar,
      onTertiary: Colors.white,
      tertiaryContainer: ArvoColors.alertaFundo,
      onTertiaryContainer: ArvoColors.alertaTexto,
      surface: ArvoColors.cardFundo,
      onSurface: ArvoColors.grafite,
      surfaceContainerLowest: ArvoColors.nevoa,
      surfaceContainerLow: ArvoColors.superficieClara,
      outline: ArvoColors.linha,
      outlineVariant: ArvoColors.bordaForte,
      error: ArvoColors.erro,
      onError: Colors.white,
      errorContainer: ArvoColors.erroFundo,
      onErrorContainer: ArvoColors.erroTexto,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ArvoColors.nevoa,
      colorScheme: colorScheme,
      fontFamily: ArvoTypography.fontBody,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      textTheme: const TextTheme(
        displayLarge: ArvoTypography.displayLarge,
        displayMedium: ArvoTypography.displayMedium,
        titleLarge: ArvoTypography.titleLarge,
        titleMedium: ArvoTypography.titleMedium,
        titleSmall: ArvoTypography.titleSmall,
        bodyLarge: ArvoTypography.bodyLarge,
        bodyMedium: ArvoTypography.bodyMedium,
        bodySmall: ArvoTypography.bodySmall,
        labelLarge: ArvoTypography.button,
        labelMedium: ArvoTypography.labelMedium,
        labelSmall: ArvoTypography.labelSmall,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ArvoColors.petroleo,
        foregroundColor: ArvoColors.nevoa,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Colors.black26,
        centerTitle: false,
        iconTheme: IconThemeData(color: ArvoColors.nevoa, size: 22),
        actionsIconTheme: IconThemeData(color: ArvoColors.nevoa, size: 22),
        titleTextStyle: TextStyle(
          fontFamily: ArvoTypography.fontHeading,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ArvoColors.nevoa,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: ArvoColors.cardFundo,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ArvoColors.radiusLg),
          side: const BorderSide(color: ArvoColors.linha, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return ArvoColors.linha;
            }
            if (states.contains(WidgetState.pressed)) {
              return ArvoColors.petroleoProfundo;
            }
            if (states.contains(WidgetState.hovered)) {
              return const Color(0xFF144E41);
            }
            return ArvoColors.petroleo;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return ArvoColors.musgo;
            }
            return ArvoColors.nevoa;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return ArvoColors.folhaClara.withValues(alpha: 0.24);
            }
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withValues(alpha: 0.14);
            }
            return null;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return const BorderSide(color: ArvoColors.folhaClara, width: 2);
            }
            return BorderSide.none;
          }),
          elevation: const WidgetStatePropertyAll(0),
          minimumSize: const WidgetStatePropertyAll(Size(88, 44)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ArvoColors.radiusMd),
            ),
          ),
          textStyle: const WidgetStatePropertyAll(ArvoTypography.button),
          mouseCursor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return SystemMouseCursors.basic;
            }
            return SystemMouseCursors.click;
          }),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ArvoColors.folha,
          foregroundColor: Colors.white,
          minimumSize: const Size(88, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ArvoColors.radiusMd),
          ),
          textStyle: ArvoTypography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return ArvoColors.musgo;
            return ArvoColors.petroleo;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return ArvoColors.petroleo.withValues(alpha: 0.06);
            }
            if (states.contains(WidgetState.pressed)) {
              return ArvoColors.petroleo.withValues(alpha: 0.12);
            }
            return Colors.transparent;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return const BorderSide(color: ArvoColors.folha, width: 2.0);
            }
            if (states.contains(WidgetState.disabled)) {
              return const BorderSide(color: ArvoColors.linha, width: 1.5);
            }
            return const BorderSide(color: ArvoColors.petroleo, width: 1.5);
          }),
          minimumSize: const WidgetStatePropertyAll(Size(88, 44)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ArvoColors.radiusMd),
            ),
          ),
          textStyle: WidgetStatePropertyAll(
            ArvoTypography.button.copyWith(color: ArvoColors.petroleo),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ArvoColors.petroleo,
          minimumSize: const Size(64, 40),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ArvoColors.radiusSm),
          ),
          textStyle: const TextStyle(
            fontFamily: ArvoTypography.fontHeading,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ArvoColors.radiusMd),
          borderSide: const BorderSide(color: ArvoColors.linha),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ArvoColors.radiusMd),
          borderSide: const BorderSide(color: ArvoColors.linha),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ArvoColors.radiusMd),
          borderSide: const BorderSide(color: ArvoColors.folha, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ArvoColors.radiusMd),
          borderSide: const BorderSide(color: ArvoColors.erro, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ArvoColors.radiusMd),
          borderSide: const BorderSide(color: ArvoColors.erro, width: 2.0),
        ),
        labelStyle: const TextStyle(
          fontFamily: ArvoTypography.fontBody,
          color: ArvoColors.musgo,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: ArvoTypography.fontHeading,
          color: ArvoColors.petroleo,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(
          fontFamily: ArvoTypography.fontBody,
          color: ArvoColors.musgo,
          fontSize: 13,
        ),
        errorStyle: const TextStyle(
          fontFamily: ArvoTypography.fontBody,
          color: ArvoColors.erroTexto,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: ArvoColors.petroleo,
        secondarySelectedColor: ArvoColors.superficieDestaque,
        disabledColor: ArvoColors.superficieClara,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        labelStyle: const TextStyle(
          fontFamily: ArvoTypography.fontBody,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: ArvoColors.grafite,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: ArvoTypography.fontHeading,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        side: const BorderSide(color: ArvoColors.linha),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: ArvoColors.linha),
        ),
        titleTextStyle: ArvoTypography.titleMedium,
        contentTextStyle: ArvoTypography.bodyMedium,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ArvoColors.petroleoProfundo,
        contentTextStyle: const TextStyle(
          fontFamily: ArvoTypography.fontBody,
          color: ArvoColors.nevoa,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ArvoColors.radiusMd),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: ArvoColors.petroleoProfundo,
          borderRadius: BorderRadius.circular(ArvoColors.radiusSm),
        ),
        textStyle: const TextStyle(
          fontFamily: ArvoTypography.fontBody,
          color: ArvoColors.nevoa,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(
        color: ArvoColors.linha,
        thickness: 1,
        space: 1,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(
          ArvoColors.petroleo.withValues(alpha: 0.25),
        ),
        radius: const Radius.circular(8),
        thickness: const WidgetStatePropertyAll(6),
      ),
    );
  }
}
