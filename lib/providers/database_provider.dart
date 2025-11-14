import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/prod_database_helper.dart';

final databaseProvider = Provider((_) => ProdDatabaseHelper.instance);
