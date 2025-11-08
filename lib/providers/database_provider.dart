import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database_helper.dart';

final databaseProvider = Provider<DatabaseHelper>((_) => DatabaseHelper.instance);
