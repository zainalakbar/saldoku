import 'package:flutter/material.dart';
import 'financial_models.dart';
import 'database_service.dart';

class FinancialProvider with ChangeNotifier {
  final List<FinancialAsset> _assets = [];
  final List<FinancialGoal> _goals = [];
  final List<Debt> _debts = [];
  final DatabaseService _dbService = DatabaseService();

  FinancialProvider() {
    loadData();
  }

  List<FinancialAsset> get assets => [..._assets];
  List<FinancialGoal> get goals => [..._goals];
  List<Debt> get debts => [..._debts];

  double get totalAssetAmount {
    return _assets.fold(0.0, (sum, asset) => sum + asset.amount);
  }

  double get totalGoalAmount {
    return _goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
  }

  double get totalDebtAmount {
    return _debts
        .where((d) => d.type == DebtType.fromMe && !d.isPaid)
        .fold(0.0, (sum, debt) => sum + debt.amount);
  }

  double get totalPiutangAmount {
    return _debts
        .where((d) => d.type == DebtType.toMe && !d.isPaid)
        .fold(0.0, (sum, debt) => sum + debt.amount);
  }

  // Load data
  Future<void> loadData() async {
    try {
      final assetsList = await _dbService.getAllAssets();
      final goalsList = await _dbService.getAllGoals();
      final debtsList = await _dbService.getAllDebts();
      
      _assets.clear();
      _assets.addAll(assetsList);
      
      _goals.clear();
      _goals.addAll(goalsList);

      _debts.clear();
      _debts.addAll(debtsList);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading financial data: $e');
    }
  }

  // ... (Asset and Goal methods)

  // Debt Methods
  Future<void> addDebt(Debt debt) async {
    _debts.add(debt);
    notifyListeners();
    try {
      await _dbService.insertDebt(debt);
    } catch (e) {
      debugPrint('Error saving debt: $e');
    }
  }

  Future<void> toggleDebtPaid(String id) async {
    final index = _debts.indexWhere((d) => d.id == id);
    if (index != -1) {
      final updatedDebt = _debts[index].copyWith(isPaid: !_debts[index].isPaid);
      _debts[index] = updatedDebt;
      notifyListeners();
      try {
        await _dbService.insertDebt(updatedDebt);
      } catch (e) {
        debugPrint('Error updating debt status: $e');
      }
    }
  }

  Future<void> deleteDebt(String id) async {
    _debts.removeWhere((d) => d.id == id);
    notifyListeners();
    try {
      await _dbService.deleteDebt(id);
    } catch (e) {
      debugPrint('Error deleting debt: $e');
    }
  }

  // Asset Methods
  Future<void> addAsset(FinancialAsset asset) async {
    _assets.add(asset);
    notifyListeners();
    try {
      await _dbService.insertAsset(asset);
    } catch (e) {
      debugPrint('Error saving asset: $e');
    }
  }

  Future<void> deleteAsset(String id) async {
    _assets.removeWhere((a) => a.id == id);
    notifyListeners();
    try {
      await _dbService.deleteAsset(id);
    } catch (e) {
      debugPrint('Error deleting asset: $e');
    }
  }

  // Goal Methods
  Future<void> addGoal(FinancialGoal goal) async {
    _goals.add(goal);
    notifyListeners();
    try {
      await _dbService.insertGoal(goal);
    } catch (e) {
      debugPrint('Error saving goal: $e');
    }
  }

  Future<void> updateGoalAmount(String id, double additionalAmount) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      final oldGoal = _goals[index];
      final newGoal = FinancialGoal(
        id: oldGoal.id,
        name: oldGoal.name,
        targetAmount: oldGoal.targetAmount,
        currentAmount: oldGoal.currentAmount + additionalAmount,
        deadline: oldGoal.deadline,
        icon: oldGoal.icon,
        color: oldGoal.color,
      );
      _goals[index] = newGoal;
      notifyListeners();
      try {
        await _dbService.insertGoal(newGoal);
      } catch (e) {
        debugPrint('Error updating goal: $e');
      }
    }
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
    try {
      await _dbService.deleteGoal(id);
    } catch (e) {
      debugPrint('Error deleting goal: $e');
    }
  }
}
