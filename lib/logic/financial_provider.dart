import 'package:flutter/material.dart';
import 'financial_models.dart';
import 'database_service.dart';

class FinancialProvider with ChangeNotifier {
  final List<FinancialAsset> _assets = [];
  final List<FinancialGoal> _goals = [];
  final List<Debt> _debts = [];
  final List<SplitBillHistory> _splitBillHistory = [];
  final List<User> _persistentFriends = [];
  final DatabaseService _dbService = DatabaseService();

  FinancialProvider() {
    loadData();
  }

  List<FinancialAsset> get assets => [..._assets];
  List<FinancialGoal> get goals => [..._goals];
  List<Debt> get debts => [..._debts];
  List<SplitBillHistory> get splitBillHistory => [..._splitBillHistory];
  List<User> get persistentFriends => [..._persistentFriends];

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

      final historyList = await _dbService.getAllSplitBillHistory();
      _splitBillHistory.clear();
      _splitBillHistory.addAll(historyList);

      final friendsList = await _dbService.getAllFriends();
      _persistentFriends.clear();
      _persistentFriends.addAll(friendsList);
      
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

  Future<void> clearPaidDebts(DebtType type) async {
    final idsToRemove = _debts.where((d) => d.type == type && d.isPaid).map((d) => d.id).toList();
    _debts.removeWhere((d) => idsToRemove.contains(d.id));
    notifyListeners();
    for (var id in idsToRemove) {
      await _dbService.deleteDebt(id);
    }
  }

  Future<void> clearAllDebts(DebtType type) async {
    final idsToRemove = _debts.where((d) => d.type == type).map((d) => d.id).toList();
    _debts.removeWhere((d) => idsToRemove.contains(d.id));
    notifyListeners();
    for (var id in idsToRemove) {
      await _dbService.deleteDebt(id);
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

  Future<void> updateAssetAmount(String id, double newAmount) async {
    final index = _assets.indexWhere((a) => a.id == id);
    if (index != -1) {
      final oldAsset = _assets[index];
      final newAsset = FinancialAsset(
        id: oldAsset.id,
        name: oldAsset.name,
        amount: newAmount,
        type: oldAsset.type,
        icon: oldAsset.icon,
        color: oldAsset.color,
      );
      _assets[index] = newAsset;
      notifyListeners();
      try {
        await _dbService.insertAsset(newAsset);
      } catch (e) {
        debugPrint('Error updating asset amount: $e');
      }
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

  // Split Bill History Methods
  Future<void> addSplitBillHistory(SplitBillHistory history) async {
    _splitBillHistory.insert(0, history);
    notifyListeners();
    try {
      await _dbService.insertSplitBillHistory(history);
    } catch (e) {
      debugPrint('Error saving split bill history: $e');
    }
  }

  Future<void> deleteSplitBillHistory(String id) async {
    _splitBillHistory.removeWhere((h) => h.id == id);
    notifyListeners();
    try {
      await _dbService.deleteSplitBillHistory(id);
    } catch (e) {
      debugPrint('Error deleting split bill history: $e');
    }
  }

  // Persistent Friends Methods
  Future<void> addFriend(User friend) async {
    // Check if already exists by name to avoid duplicates
    if (_persistentFriends.any((f) => f.name.toLowerCase() == friend.name.toLowerCase())) return;
    
    _persistentFriends.add(friend);
    notifyListeners();
    try {
      await _dbService.insertFriend(friend);
    } catch (e) {
      debugPrint('Error saving friend: $e');
    }
  }

  Future<void> deleteFriend(String id) async {
    _persistentFriends.removeWhere((f) => f.id == id);
    notifyListeners();
    try {
      await _dbService.deleteFriend(id);
    } catch (e) {
      debugPrint('Error deleting friend: $e');
    }
  }
}
