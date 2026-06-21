import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Next Home App Theme
/// Primary: Deep Indigo #6C63FF | Secondary: Coral #FF6584 | Surface: Dark #1A1A2E
class AppTheme {
  AppTheme._();

  // ── Color Palette ──────────────────────────────────────────────────────────
  static const Color primaryColor   = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFFFF6584);
  static const Color accentColor    = Color(0xFF43CFCF);
  static const Color errorColor     = Color(0xFFFF5252);
  static const Color successColor   = Color(0xFF4CAF50);
  static const Color warningColor   = Color(0xFFFFB74D);

  // Light mode
  static const Color lightBackground  = Color(0xFFF8F9FA);
  static const Color lightSurface     = Color(0xFFFFFFFF);
  static const Color lightOnSurface   = Color(0xFF1A1A2E);
  static const Color lightBorder      = Color(0xFFE0E0E0);

  // Dark mode
  static const Color darkBackground  = Color(0xFF0D0D1A);
  static const Color darkSurface     = Color(0xFF1A1A2E);
  static const Color darkOnSurface   = Color(0xFFF8F9FA);
  static const Color darkBorder      = Color(0xFF2D2D44);

  // ── Typography ─────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge:  GoogleFonts.inter(fontSize: 57, fontWeight: FontWeight.w700, color: textColor),
      displayMedium: GoogleFonts.inter(fontSize: 45, fontWeight: FontWeight.w700, color: textColor),
      displaySmall:  GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w600, color: textColor),
      headlineLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w600, color: textColor),
      headlineMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w600, color: textColor),
      headlineSmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: textColor),
      titleLarge:    GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: textColor),
      titleMedium:   GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
      titleSmall:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
      bodyLarge:     GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: textColor),
      bodyMedium:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textColor),
      bodySmall:     GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: textColor),
      labelLarge:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
      labelMedium:   GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textColor),
      labelSmall:    GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: textColor),
    );
  }

  // ── Light Theme ────────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary:    primaryColor,
      secondary:  secondaryColor,
      tertiary:   accentColor,
      error:      errorColor,
      background: lightBackground,
      surface:    lightSurface,
      onPrimary:  Colors.white,
      onSecondary: Colors.white,
      onBackground: lightOnSurface,
      onSurface:  lightOnSurface,
    ),
    textTheme: _buildTextTheme(lightOnSurface),
    scaffoldBackgroundColor: lightBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: lightSurface,
      foregroundColor: lightOnSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20, fontWeight: FontWeight.w600, color: lightOnSurface,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: lightSurface,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightSurface,
      selectedItemColor: primaryColor,
      unselectedItemColor: Color(0xFF9E9E9E),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: primaryColor.withOpacity(0.1),
      labelStyle: GoogleFonts.inter(color: primaryColor, fontSize: 12),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );

  // ── Dark Theme ─────────────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary:     primaryColor,
      secondary:   secondaryColor,
      tertiary:    accentColor,
      error:       errorColor,
      background:  darkBackground,
      surface:     darkSurface,
      onPrimary:   Colors.white,
      onSecondary: Colors.white,
      onBackground: darkOnSurface,
      onSurface:   darkOnSurface,
    ),
    textTheme: _buildTextTheme(darkOnSurface),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkOnSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20, fontWeight: FontWeight.w600, color: darkOnSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: darkSurface,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: primaryColor,
      unselectedItemColor: Color(0xFF757575),
      type: BottomNavigationBarType.fixed,
    ),
  );
}
