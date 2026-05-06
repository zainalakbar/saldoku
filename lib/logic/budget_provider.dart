import 'package:flutter/material.dart';
import 'financial_models.dart';
import 'database_service.dart';

class BudgetProvider with ChangeNotifier {
  final List<CategoryBudget> _budgets = [];
  final DatabaseService _dbService = DatabaseService();

  List<CategoryBudget> get budgets => [..._budgets];

  BudgetProvider() {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    try {
      final list = await _dbService.getAllBudgets();
      _budgets.clear();
      _budgets.addAll(list);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading budgets: $e');
    }
  }

  Future<void> setBudget(CategoryBudget budget) async {
    final index = _budgets.indexWhere((b) => 
      b.categoryName == budget.categoryName && 
      b.month == budget.month && 
      b.year == budget.year
    );
    if (index != -1) {
      _budgets[index] = budget;
    } else {
      _budgets.add(budget);
    }
    notifyListeners();

    try {
      await _dbService.insertBudget(budget);
    } catch (e) {
      debugPrint('Error saving budget: $e');
    }
  }

  Future<void> deleteBudget(String categoryName, int month, int year) async {
    _budgets.removeWhere((b) => 
      b.categoryName == categoryName && 
      b.month == month && 
      b.year == year
    );
    notifyListeners();

    try {
      await _dbService.deleteBudget(categoryName, month, year);
    } catch (e) {
      debugPrint('Error deleting budget: $e');
    }
  }

  CategoryBudget? getBudgetForCategory(String categoryName, int month, int year) {
    try {
      return _budgets.firstWhere((b) => 
        b.categoryName == categoryName && 
        b.month == month && 
        b.year == year
      );
    } catch (_) {
      return null;
    }
  }

  double getUsagePercentage(String categoryName, double currentSpending, int month, int year) {
    final budget = getBudgetForCategory(categoryName, month, year);
    if (budget == null || budget.limitAmount <= 0) return 0;
    return currentSpending / budget.limitAmount;
  }
}
