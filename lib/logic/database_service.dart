import 'package:sqflite/sqflite.dart' as sqfl;
import 'package:path/path.dart';
import 'transaction_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static sqfl.Database? _database;

  Future<sqfl.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<sqfl.Database> _initDatabase() async {
    final dbPath = await sqfl.getDatabasesPath();
    final path = join(dbPath, 'saldoku.db');

    return await sqfl.openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id TEXT PRIMARY KEY,
            title TEXT,
            amount REAL,
            date TEXT,
            type INTEGER,
            categoryName TEXT,
            note TEXT,
            imagePath TEXT
          )
        ''');
      },
    );
  }

  // Transaction CRUD
  Future<void> insertTransaction(Transaction transaction) async {
    final db = await database;
    await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: sqfl.ConflictAlgorithm.replace,
    );
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
