import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Model untuk satu item riwayat notifikasi
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final IconData icon;
  final Color color;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    this.isRead = false,
  });
}

class NotificationProvider with ChangeNotifier {
  static const _keyTransaction = 'notif_transaction';
  static const _keyBudgetAlert = 'notif_budget_alert';
  static const _keyDebtReminder = 'notif_debt_reminder';

  bool _transactionNotif = true;
  bool _budgetAlertNotif = true;
  bool _debtReminderNotif = false;

  // Riwayat notifikasi (in-memory, maks 50 item)
  final List<NotificationItem> _history = [];

  bool get transactionNotif => _transactionNotif;
  bool get budgetAlertNotif => _budgetAlertNotif;
  bool get debtReminderNotif => _debtReminderNotif;

  List<NotificationItem> get history => List.unmodifiable(_history);
  int get unreadCount => _history.where((n) => !n.isRead).length;

  NotificationProvider() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _transactionNotif = prefs.getBool(_keyTransaction) ?? true;
    _budgetAlertNotif = prefs.getBool(_keyBudgetAlert) ?? true;
    _debtReminderNotif = prefs.getBool(_keyDebtReminder) ?? false;
    notifyListeners();
  }

  /// Tambah item ke riwayat notifikasi
  void addToHistory({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    _history.insert(
      0,
      NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        time: DateTime.now(),
        icon: icon,
        color: color,
      ),
    );
    // Batasi maksimal 50 item
    if (_history.length > 50) _history.removeLast();
    notifyListeners();
  }

  /// Tandai semua notifikasi sebagai sudah dibaca
  void markAllAsRead() {
    for (final item in _history) {
      item.isRead = true;
    }
    notifyListeners();
  }

  /// Hapus semua riwayat
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  Future<void> setTransactionNotif(bool value) async {
    _transactionNotif = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTransaction, value);
  }

  Future<void> setBudgetAlertNotif(bool value) async {
    _budgetAlertNotif = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBudgetAlert, value);
  }

  Future<void> setDebtReminderNotif(bool value) async {
    _debtReminderNotif = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDebtReminder, value);
  }
}
