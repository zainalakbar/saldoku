import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isAppLocked = true; // Start locked for security

  ThemeMode get themeMode => _themeMode;
  bool get isAppLocked => _isAppLocked;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void unlockApp() {
    _isAppLocked = false;
    notifyListeners();
  }

  void lockApp() {
    _isAppLocked = true;
    notifyListeners();
  }

  // Dark Theme Data
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF1E60FE),
    scaffoldBackgroundColor: const Color(0xFF0F111A), // Deeper dark
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF1E60FE),
      secondary: Color(0xFF00D2FF), // Neon cyan for accents
      surface: Color(0xFF1A1C29),
      onSurface: Colors.white,
      surfaceContainerHighest: Color(0xFF25283D),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F111A),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1A1C29),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
    ),
  );

  // Light Theme Data
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF1E60FE),
    scaffoldBackgroundColor: const Color(0xFFF4F7FF), // Soft premium blue-white
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1E60FE),
      secondary: Color(0xFF1E60FE),
      surface: Colors.white,
      onSurface: Color(0xFF0D1C44),
      surfaceContainerHighest: Color(0xFFF0F4FF),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF4F7FF),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1C44)),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0D1C44), letterSpacing: -1),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0D1C44), letterSpacing: -0.5),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1C44)),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF4A4A4A)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
    ),
  );
}
