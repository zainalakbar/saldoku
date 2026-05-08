import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Dark Theme Data
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF1E60FE),
    scaffoldBackgroundColor: const Color(0xFF0A0E21),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF1E60FE),
      secondary: Color(0xFF1E60FE),
      surface: Color(0xFF1D1E33),
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0A0E21),
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1D1E33),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  // Light Theme Data (Standardizing current look)
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF1E60FE),
    scaffoldBackgroundColor: const Color(0xFFF8FAFF),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1E60FE),
      secondary: Color(0xFF1E60FE),
      surface: Colors.white,
      onSurface: Color(0xFF0D1C44),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF8FAFF),
      elevation: 0,
    ),
  );
}
