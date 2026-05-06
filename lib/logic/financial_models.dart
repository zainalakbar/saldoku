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
