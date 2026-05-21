import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isAppLocked = true; // Start locked for security
  String _userName = "Akbar Gg";
  String _userEmail = "saldoku@example.com";
  String _userPhone = "";
  String _userPin = "1234";
  String? _profileImagePath;
  bool _isPinEnabled = true;
  bool _isBiometricEnabled = false;

  ThemeProvider() {
    _loadFromPrefs();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isAppLocked => _isAppLocked;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String get userPin => _userPin;
  String? get profileImagePath => _profileImagePath;
  bool get isPinEnabled => _isPinEnabled;
  bool get isBiometricEnabled => _isBiometricEnabled;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _saveToPrefs();
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

  void setUserName(String name) {
    _userName = name;
    _saveToPrefs();
    notifyListeners();
  }

  void setUserEmail(String email) {
    _userEmail = email;
    _saveToPrefs();
    notifyListeners();
  }

  void setUserPhone(String phone) {
    _userPhone = phone;
    _saveToPrefs();
    notifyListeners();
  }

  void updatePin(String newPin) {
    _userPin = newPin;
    _saveToPrefs();
    notifyListeners();
  }

  void setProfileImage(String? path) {
    _profileImagePath = path;
    _saveToPrefs();
    notifyListeners();
  }

  void setPinEnabled(bool isEnabled) {
    _isPinEnabled = isEnabled;
    if (!isEnabled) _isAppLocked = false;
    _saveToPrefs();
    notifyListeners();
  }

  void setBiometricEnabled(bool isEnabled) {
    _isBiometricEnabled = isEnabled;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('user_name') ?? "Akbar Gg";
    _userEmail = prefs.getString('user_email') ?? "saldoku@example.com";
    _userPhone = prefs.getString('user_phone') ?? "";
    _userPin = prefs.getString('user_pin') ?? "1234";
    _profileImagePath = prefs.getString('profile_image_path');
    _isPinEnabled = prefs.getBool('is_pin_enabled') ?? true;
    _isBiometricEnabled = prefs.getBool('is_biometric_enabled') ?? false;
    
    final savedTheme = prefs.getString('theme_mode') ?? 'light';
    _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _userName);
    await prefs.setString('user_email', _userEmail);
    await prefs.setString('user_phone', _userPhone);
    await prefs.setString('user_pin', _userPin);
    await prefs.setString('theme_mode', _themeMode == ThemeMode.dark ? 'dark' : 'light');
    await prefs.setBool('is_pin_enabled', _isPinEnabled);
    await prefs.setBool('is_biometric_enabled', _isBiometricEnabled);
    
    if (_profileImagePath != null) {
      await prefs.setString('profile_image_path', _profileImagePath!);
    } else {
      await prefs.remove('profile_image_path');
    }
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
