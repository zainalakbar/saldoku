import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class TransactionCategory {
  final String name;
  final IconData icon;
  final Color color;

  const TransactionCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final TransactionCategory category;
  final String? note;
  final String? imagePath;
  final String? assetId;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.note,
    this.imagePath,
    this.assetId,
  });

  // Convert Transaction to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.index, // 0 for income, 1 for expense
      'categoryName': category.name,
      'note': note,
      'imagePath': imagePath,
      'assetId': assetId,
    };
  }

  // Create Transaction from Map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    final type = TransactionType.values[map['type']];
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      type: type,
      category: AppCategories.getByName(map['categoryName'], type),
      note: map['note'],
      imagePath: map['imagePath'],
      assetId: map['assetId'],
    );
  }
}

// Predefined categories
class AppCategories {
  static const List<TransactionCategory> incomeCategories = [
    TransactionCategory(name: 'Gaji', icon: Icons.payments, color: Colors.green),
    TransactionCategory(name: 'Bonus', icon: Icons.card_giftcard, color: Colors.orange),
    TransactionCategory(name: 'Investasi', icon: Icons.trending_up, color: Colors.blue),
    TransactionCategory(name: 'Lainnya', icon: Icons.more_horiz, color: Colors.grey),
  ];

  static const List<TransactionCategory> expenseCategories = [
    TransactionCategory(name: 'Makanan', icon: Icons.restaurant, color: Colors.orange),
    TransactionCategory(name: 'Transportasi', icon: Icons.directions_car, color: Colors.blue),
    TransactionCategory(name: 'Belanja', icon: Icons.shopping_bag, color: Colors.pink),
    TransactionCategory(name: 'Hiburan', icon: Icons.movie, color: Colors.purple),
    TransactionCategory(name: 'Kesehatan', icon: Icons.medical_services, color: Colors.red),
    TransactionCategory(name: 'Pendidikan', icon: Icons.school, color: Colors.indigo),
    TransactionCategory(name: 'Tagihan', icon: Icons.receipt, color: Colors.teal),
    TransactionCategory(name: 'Menabung', icon: Icons.savings, color: Colors.indigo),
    TransactionCategory(name: 'Lainnya', icon: Icons.more_horiz, color: Colors.grey),
  ];

  static TransactionCategory getByName(String name, TransactionType type) {
    final list = type == TransactionType.income ? incomeCategories : expenseCategories;
    return list.firstWhere((c) => c.name == name, orElse: () => list.last);
  }
}
