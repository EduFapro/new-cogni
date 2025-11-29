import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/database_provider.dart';
import '../../../providers/network_provider.dart';
import 'recording_file_local_datasource.dart';
import 'recording_file_remote_data_source.dart';
import '../domain/recording_file_repository.dart';
import 'recording_file_repository_impl.dart';

final recordingFileLocalDataSourceProvider =
    Provider<RecordingFileLocalDataSource>((ref) {
      final dbHelper = ref.read(databaseProvider);
      return RecordingFileLocalDataSource(dbHelper: dbHelper);
    });

final recordingFileRepositoryProvider = Provider<RecordingFileRepository>((
  ref,
) {
  final localDataSource = ref.read(recordingFileLocalDataSourceProvider);
  final networkService = ref.read(networkServiceProvider);
  final remoteDataSource = RecordingFileRemoteDataSource(networkService);

  return RecordingFileRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );
});
