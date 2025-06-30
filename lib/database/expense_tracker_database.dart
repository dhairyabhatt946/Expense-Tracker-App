import 'package:expense_tracker/utils/string_constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ExpenseTrackerDatabase {
  Future<Database> initDatabase() async {
    Database db = await openDatabase(
      join(await getDatabasesPath(), DB_NAME),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE $TBL_NAME ($ID INTEGER PRIMARY KEY AUTOINCREMENT, '
              '$AMOUNT REAL NOT NULL, '
              '$CATEGORY TEXT NOT NULL, '
              '$NOTE TEXT, '
              '$DATE TEXT NOT NULL, '
              '$TYPE TEXT NOT NULL);'
        );
      },
      version: 1,
    );
    return db;
  }

  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    Database db = await initDatabase();
    List<Map<String, dynamic>> transactions = await db.query(
      TBL_NAME,
      orderBy: '$DATE DESC',
    );
    return transactions;
  }

  Future<void> addTransaction(Map<String, dynamic> map) async {
    Database db = await initDatabase();
    await db.insert(TBL_NAME, map);
  }

  Future<void> updateTransaction(int id, Map<String, dynamic> map) async {
    Database db = await initDatabase();
    await db.update(TBL_NAME, map, where: '$ID = ?', whereArgs: [id]);
  }

  Future<void> deleteTransactions(int id) async {
    Database db = await initDatabase();
    await db.delete(TBL_NAME, where: '$ID = ?', whereArgs: [id]);
  }
}