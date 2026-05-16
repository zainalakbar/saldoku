import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Logic Providers
import 'logic/transaction_provider.dart';
import 'logic/financial_provider.dart';
import 'logic/budget_provider.dart';
import 'logic/theme_provider.dart';
import 'logic/navigation_provider.dart';

// Screens
import 'screens/main_screen.dart';
import 'pin_lock_screen.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => FinancialProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Saldoku',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            home: themeProvider.isAppLocked ? const PinLockScreen() : const MainScreen(),
          );
        },
      ),
    );
  }
}
