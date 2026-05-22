import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../constants/database_tables.dart';

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();

  Database? _database;

  Future<Database> get database async {
    final current = _database;
    if (current != null) return current;
    final dbPath = await getDatabasesPath();
    final database = await openDatabase(
      p.join(dbPath, 'food_hub.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE ${DatabaseTables.favorites}(
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  thumbnailUrl TEXT NOT NULL,
  category TEXT NOT NULL,
  syncStatus TEXT NOT NULL,
  updatedAt INTEGER NOT NULL
)
''');
        await db.execute('''
CREATE TABLE ${DatabaseTables.customRecipes}(
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  category TEXT NOT NULL,
  ingredients TEXT NOT NULL,
  steps TEXT NOT NULL,
  imageUrl TEXT NOT NULL,
  localImagePath TEXT NOT NULL,
  syncStatus TEXT NOT NULL,
  updatedAt INTEGER NOT NULL
)
''');
        await db.execute('''
CREATE TABLE ${DatabaseTables.mealPlan}(
  id TEXT PRIMARY KEY,
  day TEXT NOT NULL,
  slot TEXT NOT NULL,
  mealId TEXT NOT NULL,
  name TEXT NOT NULL,
  syncStatus TEXT NOT NULL,
  updatedAt INTEGER NOT NULL
)
''');
      },
    );
    _database = database;
    return database;
  }
}

class SyncStatus {
  const SyncStatus._();

  static const synced = 'synced';
  static const pending = 'pending';
  static const pendingDelete = 'pending_delete';
}
