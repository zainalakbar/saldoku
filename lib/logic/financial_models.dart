import 'dart:convert';
import 'package:flutter/material.dart';

class User {
  String id;
  String name;
  double balance;

  User({required this.id, required this.name, this.balance = 0.0});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Tanpa Nama',
      balance: (map['balance'] ?? 0.0).toDouble(),
    );
  }
}

class TransactionItem {
  String name;
  double price;
  List<String> assignedUserIds;

  TransactionItem({
    required this.name,
    required this.price,
    List<String>? assignedUserIds,
  }) : assignedUserIds = assignedUserIds ?? [];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'assignedUserIds': assignedUserIds,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      assignedUserIds: map['assignedUserIds'] != null 
          ? List<String>.from(map['assignedUserIds']) 
          : [],
    );
  }
}

class UserDebt {
  final String userId;
  final double itemsTotal;
  final double taxShare;
  final double grandTotal;

  UserDebt({
    required this.userId,
    required this.itemsTotal,
    required this.taxShare,
    required this.grandTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'itemsTotal': itemsTotal,
      'taxShare': taxShare,
      'grandTotal': grandTotal,
    };
  }

  factory UserDebt.fromMap(Map<String, dynamic> map) {
    return UserDebt(
      userId: map['userId'] ?? '',
      itemsTotal: (map['itemsTotal'] ?? 0.0).toDouble(),
      taxShare: (map['taxShare'] ?? 0.0).toDouble(),
      grandTotal: (map['grandTotal'] ?? 0.0).toDouble(),
    );
  }
}

class BillTransaction {
  String id;
  List<TransactionItem> items;
  double taxAndServiceAmount;
  String mainPayerId;

  BillTransaction({
    required this.id,
    required this.items,
    required this.taxAndServiceAmount,
    required this.mainPayerId,
  });

  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.price);
  }

  double get totalAmount {
    return subtotal + taxAndServiceAmount;
  }
}

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
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: AssetType.values[map['type'] ?? 0],
      icon: IconData(map['iconCode'] ?? 0xe3af, fontFamily: 'MaterialIcons'),
      color: Color(map['colorValue'] ?? 0xFF000000),
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
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0.0).toDouble(),
      currentAmount: (map['currentAmount'] ?? 0.0).toDouble(),
      deadline: (map['deadline'] != null && map['deadline'].toString().isNotEmpty) ? DateTime.parse(map['deadline']) : null,
      icon: IconData(map['iconCode'] ?? 0xe3af, fontFamily: 'MaterialIcons'),
      color: Color(map['colorValue'] ?? 0xFF000000),
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
      categoryName: map['categoryName'] ?? '',
      limitAmount: (map['limitAmount'] ?? 0.0).toDouble(),
      month: map['month'] ?? 1,
      year: map['year'] ?? 2024,
    );
  }
}
enum DebtType { toMe, fromMe }

class Debt {
  final String id;
  final String personName;
  final double amount;
  final DebtType type;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String? note;
  final bool isPaid;

  Debt({
    required this.id,
    required this.personName,
    required this.amount,
    required this.type,
    required this.createdAt,
    this.dueDate,
    this.note,
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
      'note': note,
      'isPaid': isPaid ? 1 : 0,
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'] ?? '',
      personName: map['personName'] ?? 'Tanpa Nama',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: DebtType.values[map['type'] ?? 0],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      note: map['note'],
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

class SplitBillHistory {
  final String id;
  final String title;
  final double totalAmount;
  final DateTime date;
  final List<UserDebt> debts;
  final List<User> allUsers;
  final List<TransactionItem> items;

  SplitBillHistory({
    required this.id,
    required this.title,
    required this.totalAmount,
    required this.date,
    required this.debts,
    required this.allUsers,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'totalAmount': totalAmount,
      'date': date.toIso8601String(),
      'debtsJson': jsonEncode(debts.map((e) => e.toMap()).toList()),
      'usersJson': jsonEncode(allUsers.map((e) => e.toMap()).toList()),
      'itemsJson': jsonEncode(items.map((e) => e.toMap()).toList()),
    };
  }

  factory SplitBillHistory.fromMap(Map<String, dynamic> map) {
    return SplitBillHistory(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Tanpa Judul',
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      debts: (jsonDecode(map['debtsJson'] ?? '[]') as List)
          .map((e) => UserDebt.fromMap(e))
          .toList(),
      allUsers: (jsonDecode(map['usersJson'] ?? '[]') as List)
          .map((e) => User.fromMap(e))
          .toList(),
      items: (jsonDecode(map['itemsJson'] ?? '[]') as List)
          .map((e) => TransactionItem.fromMap(e))
          .toList(),
    );
  }
}
