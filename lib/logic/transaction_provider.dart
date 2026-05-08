import 'package:flutter/material.dart';
import 'transaction_model.dart';
import 'database_service.dart';

class TransactionProvider with ChangeNotifier {
  final List<Transaction> _transactions = [];
  final DatabaseService _dbService = DatabaseService();

  TransactionProvider() {
    loadTransactions();
  }

  List<Transaction> get transactions => [..._transactions];

  List<Transaction> get recentTransactions {
    final sorted = [..._transactions];
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(10).toList();
  }

  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get currentBalance => totalIncome - totalExpense;

  // Monthly stats
  double getMonthlyIncome(int month, int year) {
    return _transactions
        .where((t) => t.type == TransactionType.income && t.date.month == month && t.date.year == year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getMonthlyExpense(int month, int year) {
    return _transactions
        .where((t) => t.type == TransactionType.expense && t.date.month == month && t.date.year == year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getCategorySpending(String categoryName, int month, int year) {
    return _transactions
        .where((t) => 
          t.type == TransactionType.expense && 
          t.category.name == categoryName && 
          t.date.month == month && 
          t.date.year == year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  List<Transaction> getTransactionsByMonth(int month, int year) {
    return _transactions
        .where((t) => t.date.month == month && t.date.year == year)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Database Methods
  Future<void> loadTransactions() async {
    final list = await _dbService.getAllTransactions();
    _transactions.clear();
    _transactions.addAll(list);
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _dbService.insertTransaction(transaction);
    _transactions.insert(0, transaction);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await _dbService.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _dbService.updateTransaction(transaction);
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      notifyListeners();
    }
  }

  String exportToCSV() {
    if (_transactions.isEmpty) return '';
    
    final StringBuffer buffer = StringBuffer();
    // Header
    buffer.writeln('ID,Judul,Nominal,Tipe,Kategori,Tanggal');
    
    for (var t in _transactions) {
      final typeStr = t.type == TransactionType.income ? 'Pemasukan' : 'Pengeluaran';
      buffer.writeln('${t.id},${t.title},${t.amount},${typeStr},${t.category.name},${t.date.toIso8601String()}');
    }
    
    return buffer.toString();
  }
}
