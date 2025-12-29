import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Available app themes
enum AppThemeType {
  teal,    // Default medical teal
  blue,    // Professional blue
  purple,  // Modern purple
  green,   // Nature green
  orange,  // Energetic orange
  pink,    // Soft pink
}

/// Color palette for each theme
class ThemeColors {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final String name;
  final IconData icon;

  const ThemeColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.name,
    required this.icon,
  });
}

/// Theme presets
class ThemePresets {
  static const Map<AppThemeType, ThemeColors> themes = {
    AppThemeType.teal: ThemeColors(
      primary: Color(0xFF0D9488),
      primaryLight: Color(0xFF5EEAD4),
      primaryDark: Color(0xFF0F766E),
      name: 'Teal',
      icon: Icons.medical_services,
    ),
    AppThemeType.blue: ThemeColors(
      primary: Color(0xFF2563EB),
      primaryLight: Color(0xFF60A5FA),
      primaryDark: Color(0xFF1D4ED8),
      name: 'Blue',
      icon: Icons.water_drop,
    ),
    AppThemeType.purple: ThemeColors(
      primary: Color(0xFF7C3AED),
      primaryLight: Color(0xFFA78BFA),
      primaryDark: Color(0xFF5B21B6),
      name: 'Purple',
      icon: Icons.diamond,
    ),
    AppThemeType.green: ThemeColors(
      primary: Color(0xFF059669),
      primaryLight: Color(0xFF6EE7B7),
      primaryDark: Color(0xFF047857),
      name: 'Green',
      icon: Icons.eco,
    ),
    AppThemeType.orange: ThemeColors(
      primary: Color(0xFFEA580C),
      primaryLight: Color(0xFFFB923C),
      primaryDark: Color(0xFFC2410C),
      name: 'Orange',
      icon: Icons.wb_sunny,
    ),
    AppThemeType.pink: ThemeColors(
      primary: Color(0xFFDB2777),
      primaryLight: Color(0xFFF472B6),
      primaryDark: Color(0xFFBE185D),
      name: 'Pink',
      icon: Icons.favorite,
    ),
  };
}

/// Theme service for managing app theme
class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._();
  static ThemeService get instance => _instance;
  
  ThemeService._();
  
  static const String _themeKey = 'app_theme';
  
  AppThemeType _currentTheme = AppThemeType.teal;
  AppThemeType get currentTheme => _currentTheme;
  
  ThemeColors get colors => ThemePresets.themes[_currentTheme]!;
  
  /// Initialize theme from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _currentTheme = AppThemeType.values[themeIndex];
    notifyListeners();
  }
  
  /// Set new theme
  Future<void> setTheme(AppThemeType theme) async {
    _currentTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
    notifyListeners();
  }
  
  /// Get all available themes
  List<MapEntry<AppThemeType, ThemeColors>> get allThemes {
    return ThemePresets.themes.entries.toList();
  }
}
