import 'package:flutter/material.dart';

/// DevSpace Design System Colors.
///
/// Centralized color tokens for the application.
/// Supports Material 3 Light and Dark ColorSchemes.
abstract final class AppColors {
  // ============================================================
  // Brand Colors
  // ============================================================

  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5947D6);
  static const Color primaryLight = Color(0xFFC6BFFF);

  static const Color primaryContainer = Color(0xFF6C5CE7);
  static const Color primaryDarkMode = Color(0xFFC6BFFF);

  // ============================================================
  // Accent Colors
  // ============================================================

  static const Color success = Color(0xFF16A875);
  static const Color successDark = Color(0xFF3DDC97);

  static const Color warning = Color(0xFFD97706);
  static const Color warningDark = Color(0xFFFFB86B);

  static const Color error = Color(0xFFDC4545);
  static const Color errorDark = Color(0xFFFF6B6B);

  // ============================================================
  // Light Theme - Surfaces
  // ============================================================

  static const Color lightBackground = Color(0xFFFBF8FF);
  static const Color lightSurface = Color(0xFFFFFFFF);

  static const Color lightSurfaceDim = Color(0xFFD9D9E7);

  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF3F2FF);
  static const Color lightSurfaceContainer = Color(0xFFEDEDFB);
  static const Color lightSurfaceContainerHigh = Color(0xFFE7E7F5);
  static const Color lightSurfaceContainerHighest = Color(0xFFD9D9E7);

  // ============================================================
  // Light Theme - Text
  // ============================================================

  static const Color lightText = Color(0xFF191B25);
  static const Color lightSecondaryText = Color(0xFF474554);
  static const Color lightDisabledText = Color(0xFFA6ADBD);

  static const Color lightOnBackground = lightText;
  static const Color lightOnSurface = lightText;
  static const Color lightOnSurfaceVariant = lightSecondaryText;

  // ============================================================
  // Light Theme - Borders
  // ============================================================

  static const Color lightBorder = Color(0xFFC8C4D7);
  static const Color lightOutline = Color(0xFF787586);
  static const Color lightOutlineVariant = lightBorder;

  // ============================================================
  // Dark Theme - Surfaces
  // ============================================================

  static const Color darkBackground = Color(0xFF10131A);
  static const Color darkSurface = Color(0xFF171C26);

  static const Color darkSurfaceContainerLowest = Color(0xFF10131A);
  static const Color darkSurfaceContainerLow = Color(0xFF191B23);
  static const Color darkSurfaceContainer = Color(0xFF1D2027);
  static const Color darkSurfaceContainerHigh = Color(0xFF272A31);
  static const Color darkSurfaceContainerHighest = Color(0xFF32353C);

  // ============================================================
  // Dark Theme - Text
  // ============================================================

  static const Color darkText = Color(0xFFE0E2EC);
  static const Color darkSecondaryText = Color(0xFFC8C4D7);
  static const Color darkMutedText = Color(0xFF6B7280);

  static const Color darkOnBackground = darkText;
  static const Color darkOnSurface = darkText;
  static const Color darkOnSurfaceVariant = darkSecondaryText;

  // ============================================================
  // Dark Theme - Borders
  // ============================================================

  static const Color darkBorder = Color(0xFF2A3040);
  static const Color darkOutline = Color(0xFF928EA0);
  static const Color darkOutlineVariant = darkBorder;

  // ============================================================
  // Common Colors
  // ============================================================

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // ============================================================
  // Code & Terminal
  // ============================================================

  static const Color codeBackground = Color(0xFF0D1017);
  static const Color codeBorder = Color(0xFF242A38);
  static const Color codeLineNumber = Color(0xFF4B5563);

  static const Color codeAddition = Color(0xFF3DDC97);
  static const Color codeDeletion = Color(0xFFFF6B6B);

  // ============================================================
  // Interactive States
  // ============================================================

  static const Color lightHover = Color(0xFFF7F8FC);
  static const Color darkHover = Color(0xFF1A202C);
  static const Color darkActiveBorder = Color(0xFF3D465C);

  // ============================================================
  // ColorScheme - Light
  // ============================================================

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,

    // Primary
    primary: primary,
    onPrimary: white,
    primaryContainer: Color(0xFFE7E0FF),
    onPrimaryContainer: Color(0xFF21005D),

    primaryFixed: Color(0xFFE7E0FF),
    primaryFixedDim: Color(0xFFC6BFFF),
    onPrimaryFixed: Color(0xFF21005D),
    onPrimaryFixedVariant: Color(0xFF5947D6),

    // Secondary
    secondary: Color(0xFF625B71),
    onSecondary: white,
    secondaryContainer: Color(0xFFE8DEF8),
    onSecondaryContainer: Color(0xFF1D192B),

    // Tertiary
    tertiary: Color(0xFF7D5260),
    onTertiary: white,
    tertiaryContainer: Color(0xFFFFD8E4),
    onTertiaryContainer: Color(0xFF31111D),

    // Error
    error: error,
    onError: white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),

    // Surfaces
    surface: lightSurface,
    onSurface: lightOnSurface,
    surfaceTint: primary,

    surfaceDim: lightSurfaceDim,
    surfaceBright: lightSurface,

    surfaceContainerLowest: lightSurfaceContainerLowest,
    surfaceContainerLow: lightSurfaceContainerLow,
    surfaceContainer: lightSurfaceContainer,
    surfaceContainerHigh: lightSurfaceContainerHigh,
    surfaceContainerHighest: lightSurfaceContainerHighest,

    // Variants
    onSurfaceVariant: lightOnSurfaceVariant,
    outline: lightOutline,
    outlineVariant: lightOutlineVariant,

    // Other
    shadow: black,
    scrim: black,

    inverseSurface: Color(0xFF30313B),
    onInverseSurface: Color(0xFFF2F0FA),
    inversePrimary: primaryLight,
  );

  // ============================================================
  // ColorScheme - Dark
  // ============================================================

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,

    // Primary
    primary: primaryDarkMode,
    onPrimary: Color(0xFF352475),
    primaryContainer: Color(0xFF4D3D9F),
    onPrimaryContainer: Color(0xFFE7E0FF),

    primaryFixed: Color(0xFFE7E0FF),
    primaryFixedDim: Color(0xFFC6BFFF),
    onPrimaryFixed: Color(0xFF21005D),
    onPrimaryFixedVariant: Color(0xFF5947D6),

    // Secondary
    secondary: Color(0xFFCCC2DC),
    onSecondary: Color(0xFF332D41),
    secondaryContainer: Color(0xFF4A4458),
    onSecondaryContainer: Color(0xFFE8DEF8),

    // Tertiary
    tertiary: Color(0xFFEFB8C8),
    onTertiary: Color(0xFF492532),
    tertiaryContainer: Color(0xFF633B48),
    onTertiaryContainer: Color(0xFFFFD8E4),

    // Error
    error: errorDark,
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),

    // Surfaces
    surface: darkSurface,
    onSurface: darkOnSurface,
    surfaceTint: primaryDarkMode,

    surfaceDim: darkBackground,
    surfaceBright: Color(0xFF383B45),

    surfaceContainerLowest: darkSurfaceContainerLowest,
    surfaceContainerLow: darkSurfaceContainerLow,
    surfaceContainer: darkSurfaceContainer,
    surfaceContainerHigh: darkSurfaceContainerHigh,
    surfaceContainerHighest: darkSurfaceContainerHighest,

    // Variants
    onSurfaceVariant: darkOnSurfaceVariant,
    outline: darkOutline,
    outlineVariant: darkOutlineVariant,

    // Other
    shadow: black,
    scrim: black,

    inverseSurface: Color(0xFFE0E2EC),
    onInverseSurface: Color(0xFF30313B),
    inversePrimary: primary,
  );
}
