import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/database/base_database_helper.dart';
import '../core/database/prod_database_helper.dart';
import '../core/logger/app_logger.dart';
import '../features/participant/presentation/create_participant_evaluation_notifier.dart';

/// DB Provider for participants (used in production)
final participantDbHelperProvider = Provider<BaseDatabaseHelper>((ref) {
  AppLogger.db('Providing ProdDatabaseHelper.instance (participant_providers)');
  return ProdDatabaseHelper.instance;
});

/// Notifier to create participant + evaluation hierarchy
final createParticipantEvaluationProvider =
AsyncNotifierProvider<CreateParticipantEvaluationNotifier, dynamic>(
      () {
    AppLogger.info(
      'Initializing CreateParticipantEvaluationNotifier via createParticipantEvaluationProvider',
    );
    return CreateParticipantEvaluationNotifier();
  },
);
