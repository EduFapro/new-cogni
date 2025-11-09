import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/database/prod_database_helper.dart';
import '../data/participant_local_datasource.dart';
import '../data/participant_repository_impl.dart';
import '../domain/participant_repository.dart';

final participantDbHelperProvider = Provider<ProdDatabaseHelper>((ref) {
  return ProdDatabaseHelper.instance;
});

final participantRepositoryProvider = Provider<ParticipantRepository>((ref) {
  final dbHelper = ref.watch(participantDbHelperProvider);
  return ParticipantRepositoryImpl(
    local: ParticipantLocalDataSource(dbHelper: dbHelper),
  );
});
