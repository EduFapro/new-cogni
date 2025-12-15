import '../../../core/logger/app_logger.dart';
import '../domain/evaluator_repository.dart';
import '../domain/evaluator_registration_data.dart';
import 'evaluator_local_datasource.dart';
import 'evaluator_remote_data_source.dart';
import 'evaluator_model.dart';

import '../../../shared/env/env_helper.dart';
import '../../../core/environment.dart';

class EvaluatorRepositoryImpl implements EvaluatorRepository {
  final EvaluatorLocalDataSource local;
  final EvaluatorRemoteDataSource? remote;

  EvaluatorRepositoryImpl({required this.local, this.remote});

  Future<List<EvaluatorModel>> getAllEvaluators() async {
    AppLogger.info('[REPO] Fetching all evaluators');
    // Always fetch from local as primary source of truth for the app
    final list = await local.getAll();
    AppLogger.db('Fetched ${list.length} evaluators from local DB');
    return list;
  }

  Future<void> addEvaluator(EvaluatorModel evaluator) async {
    // This method seems to be used for internal/testing or direct model insertion
    // We'll insert locally only for now as it takes a Model, not RegistrationData
    AppLogger.info('[REPO] Adding evaluator ${evaluator.email} locally');
    await local.insert(evaluator);
  }

  @override
  Future<void> insertEvaluator(EvaluatorRegistrationData data) async {
    AppLogger.info('[REPO] Inserting new evaluator: ${data.username}');

    // 1. Local Insert
    final model = EvaluatorModel.fromDTO(data);
    await local.insert(model);
    final localId = model.evaluatorId;
    AppLogger.db('[REPO] Evaluator inserted into local DB with ID: $localId');

    // 2. Remote Sync
    if (remote != null) {
      if (EnvHelper.currentEnv != AppEnv.offline) {
        try {
          // We wait for remote to ensure validation passes (USER REQUEST)
          // If remote fails (e.g. 400 Bad Request), we rollback local to avoid inconsistent state
          // Pass the locally generated ID to the remote to ensure consistency
          final dataWithId = EvaluatorRegistrationData(
            id: localId,
            name: data.name,
            surname: data.surname,
            email: data.email,
            birthDate: data.birthDate,
            specialty: data.specialty,
            cpf: data.cpf,
            username: data.username,
            password: data.password,
            isAdmin: data.isAdmin,
            firstLogin: data.firstLogin,
          );
          final backendId = await remote!.createEvaluator(dataWithId);
          if (backendId != null) {
            AppLogger.info(
              '[REPO] Evaluator synced to backend with ID: $backendId',
            );
            // Optionally update local with backendId if needed, but for now just success
          }
        } catch (e, s) {
          AppLogger.error(
            'Remote creation failed. Rolling back local insertion.',
            e,
            s,
          );
          await local.deleteById(localId);
          rethrow; // Rethrow to notify UI
        }
      } else {
        AppLogger.info('📴 Offline mode: Skipping Evaluator sync.');
      }
    }
  }

  @override
  Future<bool> hasAnyEvaluatorAdmin() async {
    return await local.hasAnyEvaluatorAdmin();
  }
}
