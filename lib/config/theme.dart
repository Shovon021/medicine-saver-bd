import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/theme_service.dart';

/// App-wide color constants for the "Modern Clinical" design system.
class AppColors {
  // Backgrounds
  static const Color background = Color(0xFFFAFAF9); // Warm White
  static const Color surface = Color(0xFFFDFBF7); // Soft Cream

  // Primary - Dynamic from ThemeService
  static Color get primaryAccent => ThemeService.instance.colors.primary;
  static Color get primaryLight => ThemeService.instance.colors.primaryLight;
  static Color get primaryDark => ThemeService.instance.colors.primaryDark;
  
  // Fallback constants for initialization before ThemeService is ready
  static const Color defaultPrimary = Color(0xFF0D9488); // Teal Blue

  // Secondary & Status
  static const Color secondaryAccent = Color(0xFFF59E0B); // Warm Gold
  static const Color success = Color(0xFF10B981); // Soft Green
  static const Color warning = Color(0xFFF97316); // Coral Orange
  static const Color error = Color(0xFFEF4444); // Red

  // Text
  static const Color textHeading = Color(0xFF1E3A5F); // Deep Navy
  static const Color textBody = Color(0xFF4B5563); // Slate Grey
  static const Color textSubtle = Color(0xFF9CA3AF); // Light Grey

  // Borders & Shadows
  static const Color border = Color(0xFFE5E7EB);
  static const Color shadow = Color(0x0D000000); // 5% black

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF3F4F6);
}

/// Animation constants for smooth UX
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
}

/// App-wide Theme Data.
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryAccent,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryAccent,
        secondary: AppColors.secondaryAccent,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textBody,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textHeading,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textHeading,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textHeading,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textBody,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textBody,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSubtle,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textHeading,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textHeading,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primaryAccent, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 15,
          color: AppColors.textSubtle,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        margin: EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }

  /// Dark Theme for the app.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColorsDark.background,
      primaryColor: AppColorsDark.primaryAccent,
      colorScheme: const ColorScheme.dark(
        primary: AppColorsDark.primaryAccent,
        secondary: AppColorsDark.secondaryAccent,
        surface: AppColorsDark.surface,
        error: AppColorsDark.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColorsDark.textBody,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColorsDark.textHeading,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColorsDark.textHeading,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColorsDark.textHeading,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColorsDark.textBody,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColorsDark.textBody,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColorsDark.textSubtle,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColorsDark.background,
        foregroundColor: AppColorsDark.textHeading,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColorsDark.textHeading,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsDark.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColorsDark.primaryAccent, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 15,
          color: AppColorsDark.textSubtle,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsDark.primaryAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColorsDark.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        margin: EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }
}

/// Dark mode color constants with Enhanced Contrast.
class AppColorsDark {
  // Backgrounds
  static const Color background = Color(0xFF0F172A); // Rich Navy
  static const Color surface = Color(0xFF1E293B); // Slate

  // Primary - Medical Teal (Lighter for dark mode)
  static const Color primaryAccent = Color(0xFF2DD4BF); // Bright Teal
  static const Color primaryLight = Color(0xFF5EEAD4); // Light Teal
  static const Color primaryDark = Color(0xFF14B8A6); // Dark Teal

  // Secondary & Status
  static const Color secondaryAccent = Color(0xFFFBBF24); // Bright Gold
  static const Color success = Color(0xFF34D399); // Bright Green
  static const Color warning = Color(0xFFFB923C); // Bright Orange
  static const Color error = Color(0xFFF87171); // Light Red

  // Text - High Contrast
  static const Color textHeading = Color(0xFFF8FAFC); // Almost White
  static const Color textBody = Color(0xFFCBD5E1); // Light Slate
  static const Color textSubtle = Color(0xFF94A3B8); // Muted Slate

  // Borders & Shadows
  static const Color border = Color(0xFF334155);
  static const Color shadow = Color(0x40000000); // 25% black

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFF334155);
  static const Color shimmerHighlight = Color(0xFF475569);
}
