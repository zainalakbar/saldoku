import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Logic Providers
import 'logic/transaction_provider.dart';
import 'logic/financial_provider.dart';
import 'logic/budget_provider.dart';
import 'logic/theme_provider.dart';
import 'logic/navigation_provider.dart';
import 'logic/notification_provider.dart';

// Screens
import 'screens/main_screen.dart';
import 'screens/onboarding_screen.dart';
import 'pin_lock_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
  
  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => FinancialProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Saldoku',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            home: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: !hasSeenOnboarding 
                  ? const OnboardingScreen(key: ValueKey('onboarding')) 
                  : ((themeProvider.isAppLocked && themeProvider.isPinEnabled)
                      ? const PinLockScreen(key: ValueKey('pin_lock')) 
                      : const MainScreen(key: ValueKey('main_screen'))),
            ),
          );
        },
      ),
    );
  }
}
