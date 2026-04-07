import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════
// APP COLORS
// ═══════════════════════════════════════════════════════════════
class AppColors {
  AppColors._();

  // Primary
  static const Color primary     = Color(0xFF1A73E8);
  static const Color primaryMid  = Color(0xFFEBF2FD); // blue tint bg

  // Amber / Gamification
  static const Color amber       = Color(0xFFF5A623);
  static const Color amberMid    = Color(0xFFFEF3DC); // amber tint bg
  static const Color amberText   = Color(0xFFB87D0A);

  // Neutrals
  static const Color neutralDark = Color(0xFF1A1A2A);
  static const Color neutralMid  = Color(0xFF6B7280);
  static const Color neutralLight= Color(0xFFF3F4F6);

  // Light mode
  static const Color bgLight     = Color(0xFFFFFFFF);
  static const Color surfaceLight= Color(0xFFF9FAFB);
  static const Color borderLight = Color(0x14000000); // 8% black

  // Dark mode
  static const Color bgDark      = Color(0xFF0D1117);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color textPrimaryDark   = Color(0xFFE6EDF3);
  static const Color textSecondaryDark = Color(0xFF8B949E);
  static const Color borderDark        = Color(0x14FFFFFF); // 8% white

  // Error (only used for validation, never decoratively)
  static const Color error       = Color(0xFFE53935);
}

// ═══════════════════════════════════════════════════════════════
// APP SPACING
// ═══════════════════════════════════════════════════════════════
class AppSpacing {
  AppSpacing._();
  static const double screenH   = 20.0; // horizontal screen padding
  static const double screenTop = 16.0;
  static const double cardV     = 16.0; // card vertical padding
  static const double cardH     = 20.0; // card horizontal padding
  static const double sectionGap= 28.0;
  static const double itemGap   = 12.0;
  static const double inlineGap = 10.0;
}

// ═══════════════════════════════════════════════════════════════
// APP RADIUS
// ═══════════════════════════════════════════════════════════════
class AppRadius {
  AppRadius._();
  static const double button     = 14.0;
  static const double card       = 16.0;
  static const double bottomSheet= 24.0;
  static const double input      = 12.0;
  static const double chip       = 999.0;
  static const double avatar     = 999.0;
  static const double iconBox    = 8.0;
}

// ═══════════════════════════════════════════════════════════════
// APP TEXT STYLES  (Plus Jakarta Sans via google_fonts)
// ═══════════════════════════════════════════════════════════════
class AppTextStyles {
  AppTextStyles._();

  static TextStyle display({Color? color}) => GoogleFonts.plusJakartaSans(
    fontSize: 32, fontWeight: FontWeight.w800, color: color ?? AppColors.neutralDark, height: 1.2,
  );
  static TextStyle screenTitle({Color? color}) => GoogleFonts.plusJakartaSans(
    fontSize: 22, fontWeight: FontWeight.w700, color: color ?? AppColors.neutralDark, height: 1.3,
  );
  static TextStyle sectionHeading({Color? color}) => GoogleFonts.plusJakartaSans(
    fontSize: 17, fontWeight: FontWeight.w600, color: color ?? AppColors.neutralDark, height: 1.4,
  );
  static TextStyle body({Color? color}) => GoogleFonts.plusJakartaSans(
    fontSize: 15, fontWeight: FontWeight.w400, color: color ?? AppColors.neutralDark, height: 1.65,
  );
  static TextStyle bodyMedium({Color? color}) => GoogleFonts.plusJakartaSans(
    fontSize: 15, fontWeight: FontWeight.w500, color: color ?? AppColors.neutralDark, height: 1.5,
  );
  static TextStyle bodySemiBold({Color? color}) => GoogleFonts.plusJakartaSans(
    fontSize: 15, fontWeight: FontWeight.w600, color: color ?? AppColors.neutralDark, height: 1.5,
  );
  static TextStyle caption({Color? color}) => GoogleFonts.plusJakartaSans(
    fontSize: 13, fontWeight: FontWeight.w400, color: color ?? AppColors.neutralMid, height: 1.5,
  );
  static TextStyle label({Color? color}) => GoogleFonts.plusJakartaSans(
    fontSize: 11, fontWeight: FontWeight.w600, color: color ?? AppColors.neutralMid,
    letterSpacing: 0.044 * 11,
  );
  static TextStyle buttonText({Color? color}) => GoogleFonts.plusJakartaSans(
    fontSize: 16, fontWeight: FontWeight.w600, color: color ?? Colors.white, height: 1.2,
  );
}

// ═══════════════════════════════════════════════════════════════
// ELEVATION / SHADOWS
// ═══════════════════════════════════════════════════════════════
class AppShadows {
  AppShadows._();
  static List<BoxShadow> card = [
    const BoxShadow(color: Color(0x08000000), blurRadius: 16, offset: Offset(0, 2)),
  ];
  static List<BoxShadow> floating = [
    const BoxShadow(color: Color(0x121A73E8), blurRadius: 20, offset: Offset(0, 6)),
  ];
  static List<BoxShadow> darkBorder = [
    BoxShadow(color: AppColors.borderDark.withValues(alpha: 0.08), blurRadius: 0, spreadRadius: 1),
  ];
}

// ═══════════════════════════════════════════════════════════════
// THEME DATA
// ═══════════════════════════════════════════════════════════════
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark  => _build(Brightness.dark);

  // Keep legacy accessors for compatibility
  static ThemeData get lightTheme => light;
  static ThemeData get darkTheme  => dark;

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg      = isDark ? AppColors.bgDark      : AppColors.bgLight;
    final surface = isDark ? AppColors.surfaceDark  : AppColors.surfaceLight;
    final textPrimary   = isDark ? AppColors.textPrimaryDark   : AppColors.neutralDark;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.neutralMid;

    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      TextTheme(
        displayLarge : TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: textPrimary, height: 1.2),
        displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: textPrimary, height: 1.3),
        displaySmall : TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary, height: 1.3),
        headlineLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary, height: 1.35),
        headlineMedium:TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary, height: 1.4),
        headlineSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary, height: 1.5),
        titleLarge   : TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary, height: 1.5),
        titleMedium  : TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary, height: 1.5),
        titleSmall   : TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary, height: 1.5),
        bodyLarge    : TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: textPrimary, height: 1.65),
        bodyMedium   : TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary, height: 1.6),
        bodySmall    : TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary, height: 1.5),
        labelLarge   : TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        labelMedium  : TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textSecondary),
        labelSmall   : TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary, letterSpacing: 0.5),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary:    AppColors.primary,
        onPrimary:  Colors.white,
        primaryContainer: AppColors.primaryMid,
        onPrimaryContainer: AppColors.primary,
        secondary:  AppColors.amber,
        onSecondary: AppColors.neutralDark,
        secondaryContainer: AppColors.amberMid,
        onSecondaryContainer: AppColors.amberText,
        tertiary:   AppColors.neutralMid,
        onTertiary: Colors.white,
        error:      AppColors.error,
        onError:    Colors.white,
        surface:    surface,
        onSurface:  textPrimary,
        surfaceContainerHighest: isDark ? AppColors.surfaceDark : AppColors.neutralLight,
        outline:    isDark ? AppColors.borderDark : AppColors.borderLight,
      ),
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,

      // ── AppBar ─────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // ── Cards ──────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: isDark ? AppColors.surfaceDark : AppColors.bgLight,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
        margin: EdgeInsets.zero,
      ),

      // ── Buttons ────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600),
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      // ── Inputs ─────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : AppColors.neutralLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppColors.neutralMid),
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppColors.neutralMid),
        floatingLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500),
        errorStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.error),
        prefixIconColor: WidgetStateColor.resolveWith((states) =>
          states.contains(WidgetState.focused) ? AppColors.primary : AppColors.neutralMid),
        suffixIconColor: AppColors.neutralMid,
      ),

      // ── Chips ──────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.neutralLight,
        selectedColor: AppColors.primary,
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        side: BorderSide.none,
      ),

      // ── Progress ───────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.neutralLight,
        linearMinHeight: 6,
      ),

      // ── NavigationBar ──────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.bgLight,
        indicatorColor: AppColors.primaryMid,
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.neutralMid,
          size: 22,
        )),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => GoogleFonts.plusJakartaSans(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.neutralMid,
        )),
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // ── Divider ────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
        thickness: 1, space: 1,
      ),

      // ── Icon ───────────────────────────────────────────────────
      iconTheme: IconThemeData(color: textPrimary, size: 22),
    );
  }
}
