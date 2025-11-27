import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/database_provider.dart';
import 'recording_file_local_datasource.dart';
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
  return RecordingFileRepositoryImpl(localDataSource: localDataSource);
});
