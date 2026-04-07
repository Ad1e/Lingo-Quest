import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryPurpleLight = Color(0xFFA78BFA);
  static const Color primaryPurpleDark = Color(0xFF5B21B6);
  
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentTealLight = Color(0xFF2DD4BF);
  static const Color accentTealDark = Color(0xFF0D9488);
  
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  
  static const Color errorRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF97316);
  static const Color infoBlue = Color(0xFF3B82F6);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryPurple,
      onPrimary: Colors.white,
      primaryContainer: primaryPurpleLight,
      onPrimaryContainer: primaryPurpleDark,
      secondary: accentTeal,
      onSecondary: Colors.white,
      secondaryContainer: accentTealLight,
      onSecondaryContainer: accentTealDark,
      tertiary: infoBlue,
      background: lightBackground,
      surface: lightSurface,
      surfaceVariant: lightSurfaceVariant,
      error: errorRed,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: lightBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: lightSurface,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: primaryPurple),
      titleTextStyle: _lightHeadlineLarge,
      surfaceTintColor: primaryPurple,
    ),
    cardTheme: CardTheme(
      color: lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      surfaceTintColor: primaryPurpleLight,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: _lightLabelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryPurple,
        side: const BorderSide(color: primaryPurple, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: _lightLabelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryPurple,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: _lightLabelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorRed, width: 1),
      ),
      hintStyle: _lightBodyMedium.copyWith(color: Colors.grey),
      labelStyle: _lightLabelMedium,
    ),
    textTheme: _lightTextTheme,
    chipTheme: ChipThemeData(
      backgroundColor: primaryPurpleLight,
      selectedColor: primaryPurple,
      disabledColor: Colors.grey.shade300,
      brightness: Brightness.light,
      labelStyle: _lightLabelMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    iconTheme: const IconThemeData(color: primaryPurple),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryPurple,
      linearTrackColor: lightSurfaceVariant,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryPurpleLight,
      onPrimary: primaryPurpleDark,
      primaryContainer: primaryPurple,
      onPrimaryContainer: Colors.white,
      secondary: accentTealLight,
      onSecondary: accentTealDark,
      secondaryContainer: accentTeal,
      onSecondaryContainer: Colors.white,
      tertiary: infoBlue,
      background: darkBackground,
      surface: darkSurface,
      surfaceVariant: darkSurfaceVariant,
      error: errorRed,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: darkSurface,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: primaryPurpleLight),
      titleTextStyle: _darkHeadlineLarge,
      surfaceTintColor: primaryPurple,
    ),
    cardTheme: CardTheme(
      color: darkSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      surfaceTintColor: primaryPurple,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurpleLight,
        foregroundColor: primaryPurpleDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: _darkLabelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryPurpleLight,
        side: const BorderSide(color: primaryPurpleLight, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: _darkLabelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryPurpleLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: _darkLabelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryPurpleLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorRed, width: 1),
      ),
      hintStyle: _darkBodyMedium.copyWith(color: Colors.grey),
      labelStyle: _darkLabelMedium,
    ),
    textTheme: _darkTextTheme,
    chipTheme: ChipThemeData(
      backgroundColor: primaryPurple,
      selectedColor: primaryPurpleLight,
      disabledColor: Colors.grey.shade700,
      brightness: Brightness.dark,
      labelStyle: _darkLabelMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    iconTheme: const IconThemeData(color: primaryPurpleLight),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryPurpleLight,
      linearTrackColor: darkSurfaceVariant,
    ),
  );

  // Light Text Theme
  static const TextTheme _lightTextTheme = TextTheme(
    displayLarge: _lightDisplayLarge,
    displayMedium: _lightDisplayMedium,
    displaySmall: _lightDisplaySmall,
    headlineLarge: _lightHeadlineLarge,
    headlineMedium: _lightHeadlineMedium,
    headlineSmall: _lightHeadlineSmall,
    titleLarge: _lightTitleLarge,
    titleMedium: _lightTitleMedium,
    titleSmall: _lightTitleSmall,
    bodyLarge: _lightBodyLarge,
    bodyMedium: _lightBodyMedium,
    bodySmall: _lightBodySmall,
    labelLarge: _lightLabelLarge,
    labelMedium: _lightLabelMedium,
    labelSmall: _lightLabelSmall,
  );

  // Dark Text Theme
  static const TextTheme _darkTextTheme = TextTheme(
    displayLarge: _darkDisplayLarge,
    displayMedium: _darkDisplayMedium,
    displaySmall: _darkDisplaySmall,
    headlineLarge: _darkHeadlineLarge,
    headlineMedium: _darkHeadlineMedium,
    headlineSmall: _darkHeadlineSmall,
    titleLarge: _darkTitleLarge,
    titleMedium: _darkTitleMedium,
    titleSmall: _darkTitleSmall,
    bodyLarge: _darkBodyLarge,
    bodyMedium: _darkBodyMedium,
    bodySmall: _darkBodySmall,
    labelLarge: _darkLabelLarge,
    labelMedium: _darkLabelMedium,
    labelSmall: _darkLabelSmall,
  );

  // Light Typography Styles
  static const TextStyle _lightDisplayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    color: Colors.black87,
  );

  static const TextStyle _lightDisplayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: Colors.black87,
  );

  static const TextStyle _lightDisplaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: Colors.black87,
  );

  static const TextStyle _lightHeadlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: Colors.black87,
  );

  static const TextStyle _lightHeadlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: Colors.black87,
  );

  static const TextStyle _lightHeadlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: Colors.black87,
  );

  static const TextStyle _lightTitleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: Colors.black87,
  );

  static const TextStyle _lightTitleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: Colors.black87,
  );

  static const TextStyle _lightTitleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: Colors.black87,
  );

  static const TextStyle _lightBodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: Colors.black87,
  );

  static const TextStyle _lightBodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: Colors.black87,
  );

  static const TextStyle _lightBodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: Colors.black54,
  );

  static const TextStyle _lightLabelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: Colors.black87,
  );

  static const TextStyle _lightLabelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: Colors.black87,
  );

  static const TextStyle _lightLabelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: Colors.black54,
  );

  // Dark Typography Styles
  static const TextStyle _darkDisplayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    color: Colors.white,
  );

  static const TextStyle _darkDisplayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: Colors.white,
  );

  static const TextStyle _darkDisplaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: Colors.white,
  );

  static const TextStyle _darkHeadlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: Colors.white,
  );

  static const TextStyle _darkHeadlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: Colors.white,
  );

  static const TextStyle _darkHeadlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: Colors.white,
  );

  static const TextStyle _darkTitleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: Colors.white,
  );

  static const TextStyle _darkTitleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: Colors.white,
  );

  static const TextStyle _darkTitleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: Colors.white,
  );

  static const TextStyle _darkBodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  static const TextStyle _darkBodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: Colors.white70,
  );

  static const TextStyle _darkBodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: Colors.white54,
  );

  static const TextStyle _darkLabelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: Colors.white,
  );

  static const TextStyle _darkLabelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  static const TextStyle _darkLabelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: Colors.white54,
  );
}
