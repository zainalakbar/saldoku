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
  bool _isPrivacyMode = false;

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
  bool get isPrivacyMode => _isPrivacyMode;

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

  void setBiometricEnabled(bool value) {
    _isBiometricEnabled = value;
    _saveToPrefs();
    notifyListeners();
  }

  void setPrivacyMode(bool value) {
    _isPrivacyMode = value;
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
    _isPrivacyMode = prefs.getBool('is_privacy_mode') ?? false;
    
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
    await prefs.setBool('is_privacy_mode', _isPrivacyMode);
    
    if (_profileImagePath != null) {
      await prefs.setString('profile_image_path', _profileImagePath!);
    } else {
      await prefs.remove('profile_image_path');
    }
  }

  // ─── COLOR CONSTANTS ──────────────────────────────────────────
  static const _bgDark       = Color(0xFF050C1F);   // Near-black navy
  static const _surfaceDark  = Color(0xFF0D1530);   // Navy card surface
  static const _elevatedDark = Color(0xFF142040);   // Elevated navy container
  static const _lime         = Color(0xFF1E90FF);   // Electric blue – primary accent
  static const _limeSoft     = Color(0xFF0085D1);   // Deep sky blue – secondary
  static const _onLime       = Color(0xFF050C1F);   // Dark navy text on blue buttons
  static const _bgLight      = Color(0xFFF0F4FF);   // Light scaffold (ice white-blue)
  static const _onSurfaceL   = Color(0xFF0D1C44);   // Text on light surface

  // ─── DARK THEME ───────────────────────────────────────────────
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: _lime,
    scaffoldBackgroundColor: _bgDark,
    colorScheme: const ColorScheme.dark(
      primary: _lime,
      onPrimary: _onLime,
      secondary: _limeSoft,
      onSecondary: _onLime,
      surface: _surfaceDark,
      onSurface: Colors.white,
      surfaceContainerHighest: _elevatedDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _bgDark,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: _surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lime,
        foregroundColor: _onLime,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _elevatedDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _lime, width: 1.5),
      ),
      labelStyle: const TextStyle(color: Colors.white54),
    ),
    textTheme: const TextTheme(
      headlineLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white,  letterSpacing: -1),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white,  letterSpacing: -0.5),
      titleLarge:     TextStyle(fontSize: 18, fontWeight: FontWeight.bold,  color: Colors.white),
      bodyLarge:      TextStyle(fontSize: 16,                               color: Colors.white70),
      bodyMedium:     TextStyle(fontSize: 14,                               color: Colors.white54),
    ),
    dividerColor: Colors.white12,
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? _onLime : Colors.white54),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? _lime : Colors.white24),
    ),
  );

  // ─── LIGHT THEME ──────────────────────────────────────────────
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF1E60FE),
    scaffoldBackgroundColor: const Color(0xFFF5F7FB), // Soft blue-grey
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1E60FE),
      onPrimary: Colors.white,
      secondary: Color(0xFF0085D1),
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF1A2536),
      surfaceContainerHighest: Color(0xFFEFF3FB),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F7FB),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF1A2536)),
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A2536)),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shadowColor: Color(0x141E60FE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E60FE),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF0F4FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF1E60FE), width: 1.5),
      ),
      labelStyle: const TextStyle(color: Color(0xFF1A2536)),
    ),
    textTheme: const TextTheme(
      headlineLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1A2536), letterSpacing: -1),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A2536), letterSpacing: -0.5),
      titleLarge:     TextStyle(fontSize: 18, fontWeight: FontWeight.bold,  color: Color(0xFF1A2536)),
      bodyLarge:      TextStyle(fontSize: 16,                               color: Color(0xFF3D5A80)),
      bodyMedium:     TextStyle(fontSize: 14,                               color: Color(0xFF6B7C9D)),
    ),
    dividerColor: const Color(0xFFE2E8F4),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? Colors.white : const Color(0xFF9BACC8)),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? const Color(0xFF1E60FE) : const Color(0xFFCDD6E8)),
    ),
  );
}
