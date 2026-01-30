import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/home_screen.dart';

/// Main Entry Point
///
/// This is the entry point of the Sign Language Recognition app.
/// The app structure is organized as follows:
///
/// lib/
///   screens/     - All screen widgets (HomeScreen, PickImageScreen, etc.)
///   services/    - Business logic and external integrations (to be added)
///   widgets/     - Reusable custom widgets (to be added)
///   utils/       - Utility functions and helpers (to be added)
///   main.dart    - App entry point and MaterialApp configuration
void main() {
  runApp(const SignLanguageApp());
}

/// Root Application Widget
///
/// Configures the MaterialApp with theme, Arabic localization, and sets
/// HomeScreen as the initial route.
class SignLanguageApp extends StatelessWidget {
  const SignLanguageApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'التعرّف على لغة الإشارة',
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: colorScheme,
        fontFamily: 'Cairo',
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F3FF),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
