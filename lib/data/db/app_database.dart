import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _db;

  AppDatabase._internal();

  /// Initialize FFI before opening any database
  static Future<void> init() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  /// Open or return the existing database
  Future<Database> get database async {
    if (_db != null) return _db!;

    final dbPath = await _getDatabasePath();
    _db = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE admins (
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
      ),
    );

    return _db!;
  }

  /// Compute a proper database path (Windows safe)
  Future<String> _getDatabasePath() async {
    final dbFolder = Directory.current.path;
    return p.join(dbFolder, 'app.db');
  }
}
