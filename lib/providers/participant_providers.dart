import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../core/database/base_database_helper.dart';
import '../core/database/prod_database_helper.dart';
import '../features/participant/presentation/create_participant_evaluation_notifier.dart';

/// DB Provider for participants (used in production)
final participantDbHelperProvider = Provider<BaseDatabaseHelper>((ref) {
  return ProdDatabaseHelper.instance;
});

/// Notifier to create participant and evaluation
final createParticipantEvaluationProvider =
AsyncNotifierProvider<CreateParticipantEvaluationNotifier, dynamic>(
      () => CreateParticipantEvaluationNotifier(),
);
