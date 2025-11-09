import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/database/prod_database_helper.dart';
import '../../../core/logger/app_logger.dart';
import '../data/participant_local_datasource.dart';
import '../data/participant_repository_impl.dart';
import '../domain/participant_repository.dart';

final participantDbHelperProvider = Provider<ProdDatabaseHelper>((ref) {
  AppLogger.db('Providing ProdDatabaseHelper.instance for participants');
  return ProdDatabaseHelper.instance;
});

final participantRepositoryProvider = Provider<ParticipantRepository>((ref) {
  final dbHelper = ref.watch(participantDbHelperProvider);
  AppLogger.info('Creating ParticipantRepositoryImpl via participant_provider');
  return ParticipantRepositoryImpl(
    local: ParticipantLocalDataSource(dbHelper: dbHelper),
  );
});
