import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'config/theme.dart';
import 'screens/splash_screen.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow Google Fonts to work even with network issues
  GoogleFonts.config.allowRuntimeFetching = true;
  
  // Initialize theme service
  await ThemeService.instance.init();

  runApp(const MedicineSaverApp());
}

class MedicineSaverApp extends StatelessWidget {
  const MedicineSaverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, child) {
        final themeColors = ThemeService.instance.colors;
        
        return MaterialApp(
          title: 'Medicine Saver BD',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme.copyWith(
            primaryColor: themeColors.primary,
            colorScheme: ColorScheme.light(
              primary: themeColors.primary,
              secondary: themeColors.primaryLight,
              surface: AppColors.surface,
              error: AppColors.error,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: AppColors.textBody,
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          darkTheme: AppTheme.darkTheme.copyWith(
            primaryColor: themeColors.primary,
            colorScheme: ColorScheme.dark(
              primary: themeColors.primary,
              secondary: themeColors.primaryLight,
              error: AppColors.error,
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          themeMode: ThemeMode.system,
          home: const SplashScreen(),
        );
      },
    );
  }
}
