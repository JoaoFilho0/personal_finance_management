import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/finance_transaction.dart';

abstract interface class FinanceTransactionRepository {
  Future<List<FinanceTransaction>> loadTransactions();

  Future<FinanceTransaction> insertTransaction(
    FinanceTransaction transaction,
  );

  Future<void> deleteTransaction(FinanceTransaction transaction);
}

class SqliteFinanceTransactionRepository
    implements FinanceTransactionRepository {
  const SqliteFinanceTransactionRepository();

  static Future<Database>? _database;

  Future<Database> get _db async {
    final database = _database ??= _openDatabase();
    try {
      return await database;
    } catch (_) {
      if (identical(_database, database)) _database = null;
      rethrow;
    }
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    return openDatabase(
      path.join(databasesPath, 'personal_finance.db'),
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            category TEXT NOT NULL,
            amount REAL NOT NULL CHECK (amount > 0),
            date INTEGER NOT NULL,
            type TEXT NOT NULL CHECK (type IN ('income', 'expense'))
          )
        ''');
        await database.execute('''
          CREATE TABLE app_metadata (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<List<FinanceTransaction>> loadTransactions() async {
    final database = await _db;
    await _seedDemoTransactionsOnce(database);
    final rows = await database.query(
      'transactions',
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(FinanceTransaction.fromDatabaseMap).toList();
  }

  Future<void> _seedDemoTransactionsOnce(Database database) async {
    await database.transaction((transaction) async {
      final metadata = await transaction.query(
        'app_metadata',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: ['demo_data_seeded'],
        limit: 1,
      );
      if (metadata.isNotEmpty) return;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final demoTransactions = [
        FinanceTransaction(
          title: 'Salário Tech Corp',
          category: 'Salário',
          amount: 6150,
          date: today,
          type: TransactionType.income,
        ),
        FinanceTransaction(
          title: 'Supermercado',
          category: 'Mercado & Feira',
          amount: 384.20,
          date: today,
          type: TransactionType.expense,
        ),
        FinanceTransaction(
          title: 'Posto Ipiranga',
          category: 'Transporte',
          amount: 195,
          date: today.subtract(const Duration(days: 1)),
          type: TransactionType.expense,
        ),
        FinanceTransaction(
          title: 'Netflix',
          category: 'Lazer',
          amount: 55.90,
          date: today.subtract(const Duration(days: 1)),
          type: TransactionType.expense,
        ),
        FinanceTransaction(
          title: 'Marina Duarte',
          category: 'Transferência',
          amount: 82.50,
          date: today.subtract(const Duration(days: 2)),
          type: TransactionType.income,
        ),
        FinanceTransaction(
          title: 'Drogaria Raia',
          category: 'Saúde',
          amount: 143.30,
          date: today.subtract(const Duration(days: 2)),
          type: TransactionType.expense,
        ),
        FinanceTransaction(
          title: 'Aluguel',
          category: 'Moradia',
          amount: 2000,
          date: today.subtract(const Duration(days: 3)),
          type: TransactionType.expense,
        ),
        FinanceTransaction(
          title: 'Freelance',
          category: 'Renda extra',
          amount: 6067.50,
          date: today.subtract(const Duration(days: 4)),
          type: TransactionType.income,
        ),
        FinanceTransaction(
          title: 'Compras para casa',
          category: 'Outros',
          amount: 1071.40,
          date: today.subtract(const Duration(days: 5)),
          type: TransactionType.expense,
        ),
      ];

      for (final demoTransaction in demoTransactions) {
        await transaction.insert(
          'transactions',
          demoTransaction.toDatabaseMap(),
        );
      }
      await transaction.insert('app_metadata', {
        'key': 'demo_data_seeded',
        'value': 'true',
      });
    });
  }

  @override
  Future<FinanceTransaction> insertTransaction(
    FinanceTransaction transaction,
  ) async {
    final id = await (await _db).insert(
      'transactions',
      transaction.toDatabaseMap(),
    );
    return transaction.copyWith(id: id);
  }

  @override
  Future<void> deleteTransaction(FinanceTransaction transaction) async {
    final id = transaction.id;
    if (id == null) {
      throw StateError('Não é possível excluir uma transação sem identificador.');
    }
    final deletedCount = await (await _db).delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw StateError('A transação não foi encontrada no banco de dados.');
    }
  }
}
