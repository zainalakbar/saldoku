import 'package:sqflite/sqflite.dart' as sqfl;
import 'package:path/path.dart';
import 'transaction_model.dart';
import 'financial_models.dart';

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
      version: 5, // Incremented for debts table
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
        await db.execute('''
          CREATE TABLE assets(
            id TEXT PRIMARY KEY,
            name TEXT,
            amount REAL,
            type INTEGER,
            iconCode INTEGER,
            colorValue INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE goals(
            id TEXT PRIMARY KEY,
            name TEXT,
            targetAmount REAL,
            currentAmount REAL,
            deadline TEXT,
            iconCode INTEGER,
            colorValue INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE budgets(
            categoryName TEXT,
            month INTEGER,
            year INTEGER,
            limitAmount REAL,
            PRIMARY KEY (categoryName, month, year)
          )
        ''');
        await db.execute('''
          CREATE TABLE debts(
            id TEXT PRIMARY KEY,
            personName TEXT,
            amount REAL,
            type INTEGER,
            createdAt TEXT,
            dueDate TEXT,
            isPaid INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          // Migration logic omitted for brevity as per instructions, assuming previous tables handled
        }
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS debts(
              id TEXT PRIMARY KEY,
              personName TEXT,
              amount REAL,
              type INTEGER,
              createdAt TEXT,
              dueDate TEXT,
              isPaid INTEGER
            )
          ''');
        }
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

  // Asset CRUD
  Future<void> insertAsset(FinancialAsset asset) async {
    final db = await database;
    await db.insert('assets', asset.toMap(), conflictAlgorithm: sqfl.ConflictAlgorithm.replace);
  }

  Future<List<FinancialAsset>> getAllAssets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('assets');
    return List.generate(maps.length, (i) => FinancialAsset.fromMap(maps[i]));
  }

  Future<void> deleteAsset(String id) async {
    final db = await database;
    await db.delete('assets', where: 'id = ?', whereArgs: [id]);
  }

  // Goal CRUD
  Future<void> insertGoal(FinancialGoal goal) async {
    final db = await database;
    await db.insert('goals', goal.toMap(), conflictAlgorithm: sqfl.ConflictAlgorithm.replace);
  }

  Future<List<FinancialGoal>> getAllGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('goals');
    return List.generate(maps.length, (i) => FinancialGoal.fromMap(maps[i]));
  }

  Future<void> deleteGoal(String id) async {
    final db = await database;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  // Budget CRUD
  Future<void> insertBudget(CategoryBudget budget) async {
    final db = await database;
    await db.insert('budgets', budget.toMap(), conflictAlgorithm: sqfl.ConflictAlgorithm.replace);
  }

  Future<List<CategoryBudget>> getAllBudgets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('budgets');
    return List.generate(maps.length, (i) => CategoryBudget.fromMap(maps[i]));
  }

  Future<void> deleteBudget(String categoryName, int month, int year) async {
    final db = await database;
    await db.delete('budgets', 
      where: 'categoryName = ? AND month = ? AND year = ?', 
      whereArgs: [categoryName, month, year]
    );
  }

  // Debt CRUD
  Future<void> insertDebt(Debt debt) async {
    final db = await database;
    await db.insert('debts', debt.toMap(), conflictAlgorithm: sqfl.ConflictAlgorithm.replace);
  }

  Future<List<Debt>> getAllDebts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('debts', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => Debt.fromMap(maps[i]));
  }

  Future<void> deleteDebt(String id) async {
    final db = await database;
    await db.delete('debts', where: 'id = ?', whereArgs: [id]);
  }
}
