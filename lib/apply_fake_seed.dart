import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  // Initialize sqflite FFI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Resolve the same DB path used by ProdDatabaseHelper ('cognivoice_db.db')
  final dbRoot = await databaseFactory.getDatabasesPath();
  final dbPath = p.join(dbRoot, 'cognivoice_db.db');

  print('📂 Using database at: $dbPath');

  // Open the database
  final db = await databaseFactory.openDatabase(dbPath);

  // Read the generated SQL file
  final sqlFile = File('lib/fake_prod_seed_encrypted.sql');
  if (!await sqlFile.exists()) {
    print('❌ SQL file not found at ${sqlFile.path}');
    exit(1);
  }

  final sql = await sqlFile.readAsString();

  // Execute statements in a batch (skip BEGIN/COMMIT)
  final batch = db.batch();
  for (final raw in sql.split(';')) {
    final stmt = raw.trim();
    if (stmt.isEmpty) continue;

    final upper = stmt.toUpperCase();
    if (upper.startsWith('BEGIN TRANSACTION') || upper.startsWith('COMMIT')) {
      continue;
    }

    batch.execute(stmt);
  }

  await batch.commit(noResult: true);
  await db.close();

  print('✅ Seed SQL applied successfully to $dbPath');
}
