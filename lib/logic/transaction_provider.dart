import 'package:flutter/material.dart';
import 'transaction_model.dart';
import 'database_service.dart';

class TransactionProvider with ChangeNotifier {
  final List<Transaction> _transactions = [];
  final List<RecurringTransaction> _recurringTransactions = [];
  final DatabaseService _dbService = DatabaseService();

  TransactionProvider() {
    loadTransactions();
    loadRecurringTransactions().then((_) => _processRecurringTransactions());
  }

  List<RecurringTransaction> get recurringTransactions => [..._recurringTransactions];

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

  // Recurring Transactions CRUD
  Future<void> loadRecurringTransactions() async {
    final list = await _dbService.getAllRecurringTransactions();
    _recurringTransactions.clear();
    _recurringTransactions.addAll(list);
    notifyListeners();
  }

  Future<void> addRecurringTransaction(RecurringTransaction rt) async {
    await _dbService.insertRecurringTransaction(rt);
    _recurringTransactions.add(rt);
    notifyListeners();
  }

  Future<void> updateRecurringTransaction(RecurringTransaction rt) async {
    await _dbService.updateRecurringTransaction(rt);
    final index = _recurringTransactions.indexWhere((t) => t.id == rt.id);
    if (index != -1) {
      _recurringTransactions[index] = rt;
      notifyListeners();
    }
  }

  Future<void> deleteRecurringTransaction(String id) async {
    await _dbService.deleteRecurringTransaction(id);
    _recurringTransactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> _processRecurringTransactions() async {
    final now = DateTime.now();
    bool addedAny = false;

    for (var i = 0; i < _recurringTransactions.length; i++) {
      final rt = _recurringTransactions[i];
      if (!rt.isActive) continue;

      bool shouldProcess = false;
      if (rt.lastProcessed == null) {
        shouldProcess = true;
      } else {
        final last = rt.lastProcessed!;
        switch (rt.frequency) {
          case RecurringFrequency.daily:
            if (now.difference(last).inDays >= 1 || now.day != last.day) shouldProcess = true;
            break;
          case RecurringFrequency.weekly:
            if (now.difference(last).inDays >= 7) shouldProcess = true;
            break;
          case RecurringFrequency.monthly:
            if (now.year > last.year || now.month > last.month) shouldProcess = true;
            break;
          case RecurringFrequency.yearly:
            if (now.year > last.year) shouldProcess = true;
            break;
        }
      }

      if (shouldProcess) {
        final newTx = Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString() + rt.id.hashCode.toString(),
          title: rt.title,
          amount: rt.amount,
          date: now,
          type: rt.type,
          category: rt.category,
          note: 'Otomatis (Transaksi Rutin)',
        );
        await addTransaction(newTx);
        
        // Update last processed
        final updatedRt = RecurringTransaction(
          id: rt.id,
          title: rt.title,
          amount: rt.amount,
          type: rt.type,
          category: rt.category,
          frequency: rt.frequency,
          lastProcessed: now,
          isActive: rt.isActive,
        );
        await updateRecurringTransaction(updatedRt);
        addedAny = true;
      }
    }

    if (addedAny) {
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
