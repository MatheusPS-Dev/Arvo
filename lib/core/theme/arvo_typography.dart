import 'package:flutter/material.dart';
import 'arvo_colors.dart';

/// Tipografia oficial Arvô:
/// - Outfit para títulos, números em destaque e logotipo
/// - DM Sans para textos corridos, tabelas e interface
class ArvoTypography {
  ArvoTypography._();

  static const String fontHeading = 'Outfit';
  static const String fontBody = 'DMSans';

  // Headings (Outfit)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontHeading,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: ArvoColors.petroleo,
    letterSpacing: -0.5,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontHeading,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: ArvoColors.petroleo,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontHeading,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: ArvoColors.petroleo,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontHeading,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: ArvoColors.petroleo,
  );

  // Numbers & Metrics (Outfit)
  static const TextStyle metricValue = TextStyle(
    fontFamily: fontHeading,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: ArvoColors.petroleo,
  );

  // Body & UI (DM Sans)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontBody,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: ArvoColors.grafite,
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontBody,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: ArvoColors.grafite,
    height: 1.35,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontBody,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: ArvoColors.musgo,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: ArvoColors.musgo,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );
}
