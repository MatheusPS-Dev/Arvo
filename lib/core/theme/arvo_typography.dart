import 'package:flutter/material.dart';
import 'arvo_colors.dart';

/// Tipografia oficial Arvô (Brand Deck Slide 14 + UI/UX Pro Max):
/// - Outfit (SemiBold 600, Bold 700, Medium 500): títulos, destaques, KPIs e logotipo,
///   com letter-spacing levemente negativo (-0.02em) e algarismos tabulares para métricas.
/// - DM Sans (Regular 400, Medium 500, Bold 700): texto corrido (entrelinha 1.5),
///   formulários, tabelas e botões.
class ArvoTypography {
  ArvoTypography._();

  static const String fontHeading = 'Outfit';
  static const String fontBody = 'DMSans';

  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures(),
  ];

  // ===========================================================================
  // HEADINGS & DISPLAY (Outfit)
  // ===========================================================================
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontHeading,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: ArvoColors.petroleo,
    letterSpacing: -0.6,
    height: 1.1,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontHeading,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: ArvoColors.petroleo,
    letterSpacing: -0.5,
    height: 1.12,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontHeading,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: ArvoColors.petroleo,
    letterSpacing: -0.4,
    height: 1.2,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontHeading,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: ArvoColors.petroleo,
    letterSpacing: -0.25,
    height: 1.25,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontHeading,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: ArvoColors.petroleo,
    letterSpacing: -0.15,
    height: 1.3,
  );

  /// Estilo Kicker / Overline institucional (.k no Brand Deck: Outfit 600, letter-spacing 0.14em)
  static const TextStyle kicker = TextStyle(
    fontFamily: fontHeading,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: ArvoColors.alerta,
    letterSpacing: 1.4,
    height: 1.2,
  );

  // ===========================================================================
  // NUMBERS, KPIS & METRICS (Outfit + Tabular Figures para alinhamento exato)
  // ===========================================================================
  static const TextStyle metricValue = TextStyle(
    fontFamily: fontHeading,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: ArvoColors.petroleo,
    letterSpacing: -0.5,
    height: 1.1,
    fontFeatures: tabularFigures,
  );

  static const TextStyle metricSmall = TextStyle(
    fontFamily: fontHeading,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: ArvoColors.petroleo,
    letterSpacing: -0.2,
    fontFeatures: tabularFigures,
  );

  static const TextStyle numberMono = TextStyle(
    fontFamily: fontBody,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: ArvoColors.grafite,
    fontFeatures: tabularFigures,
  );

  // ===========================================================================
  // BODY, LABELS & UI (DM Sans)
  // ===========================================================================
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontBody,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: ArvoColors.grafite,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontBody,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: ArvoColors.grafite,
    height: 1.45,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: ArvoColors.musgo,
    height: 1.4,
  );

  static const TextStyle sectionHeader = titleMedium;

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontBody,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: ArvoColors.grafite,
    height: 1.3,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: ArvoColors.musgo,
    height: 1.3,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontHeading,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: ArvoColors.musgo,
    letterSpacing: 0.4,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontHeading,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: ArvoColors.nevoa,
    letterSpacing: 0.1,
  );
}
