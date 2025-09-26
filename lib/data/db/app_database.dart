import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  Database? _database;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    final path = join(await getDatabasesPath(), 'cogni.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE admins(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            surname TEXT NOT NULL,
            birthDate TEXT NOT NULL,
            specialty TEXT NOT NULL,
            cpfOrNif TEXT NOT NULL,
            username TEXT NOT NULL,
            password TEXT NOT NULL,
            firstLogin INTEGER NOT NULL,
            isAdmin INTEGER NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }
}
