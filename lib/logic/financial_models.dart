import 'package:flutter/material.dart';

enum AssetType { cash, bank, investment, other }

class FinancialAsset {
  final String id;
  final String name;
  final double amount;
  final AssetType type;
  final IconData icon;
  final Color color;

  FinancialAsset({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'type': type.index,
      'iconCode': icon.codePoint,
      'colorValue': color.value,
    };
  }

  factory FinancialAsset.fromMap(Map<String, dynamic> map) {
    return FinancialAsset(
      id: map['id'],
      name: map['name'],
      amount: (map['amount'] as num).toDouble(),
      type: AssetType.values[map['type']],
      icon: IconData(map['iconCode'], fontFamily: 'MaterialIcons'),
      color: Color(map['colorValue']),
    );
  }
}

class FinancialGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final IconData icon;
  final Color color;

  FinancialGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    required this.icon,
    required this.color,
  });

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount) : 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline?.toIso8601String(),
      'iconCode': icon.codePoint,
      'colorValue': color.value,
    };
  }

  factory FinancialGoal.fromMap(Map<String, dynamic> map) {
    return FinancialGoal(
      id: map['id'],
      name: map['name'],
      targetAmount: (map['targetAmount'] as num).toDouble(),
      currentAmount: (map['currentAmount'] as num).toDouble(),
      deadline: (map['deadline'] != null && map['deadline'].toString().isNotEmpty) ? DateTime.parse(map['deadline']) : null,
      icon: IconData(map['iconCode'], fontFamily: 'MaterialIcons'),
      color: Color(map['colorValue']),
    );
  }
}

class CategoryBudget {
  final String categoryName;
  final double limitAmount;
  final int month;
  final int year;

  CategoryBudget({
    required this.categoryName,
    required this.limitAmount,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoryName': categoryName,
      'limitAmount': limitAmount,
      'month': month,
      'year': year,
    };
  }

  factory CategoryBudget.fromMap(Map<String, dynamic> map) {
    return CategoryBudget(
      categoryName: map['categoryName'],
      limitAmount: (map['limitAmount'] as num).toDouble(),
      month: map['month'],
      year: map['year'],
    );
  }
}
enum DebtType { toMe, fromMe } // toMe = piutang (orang ngutang saya), fromMe = hutang (saya ngutang orang)

class Debt {
  final String id;
  final String personName;
  final double amount;
  final DebtType type;
  final DateTime createdAt;
  final DateTime? dueDate;
  final bool isPaid;

  Debt({
    required this.id,
    required this.personName,
    required this.amount,
    required this.type,
    required this.createdAt,
    this.dueDate,
    this.isPaid = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personName': personName,
      'amount': amount,
      'type': type.index,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'isPaid': isPaid ? 1 : 0,
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'],
      personName: map['personName'],
      amount: (map['amount'] as num).toDouble(),
      type: DebtType.values[map['type']],
      createdAt: DateTime.parse(map['createdAt']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      isPaid: map['isPaid'] == 1,
    );
  }

  Debt copyWith({bool? isPaid}) {
    return Debt(
      id: id,
      personName: personName,
      amount: amount,
      type: type,
      createdAt: createdAt,
      dueDate: dueDate,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}
