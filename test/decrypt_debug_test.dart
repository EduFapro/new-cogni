import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/shared/encryption/deterministic_encryption_helper.dart';
import 'package:segundo_cogni/core/logger/app_logger.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await DeterministicEncryptionHelper.init();
  });

  test('Debug decryption', () async {
    // Mock logger to print to stdout
    // AppLogger.redirect((msg) => print(msg), (msg, e, s) => print('$msg: $e'));

    final target = 'jhj16AnHsJFJHkBVjJTJ8Q==';
    print('Target: $target');

    final decrypted = DeterministicEncryptionHelper.decryptText(target);
    print('Decrypted: $decrypted');

    // Try double decryption
    if (decrypted != '[DECRYPTION_FAILED]') {
      final doubleDecrypted = DeterministicEncryptionHelper.decryptText(
        decrypted,
      );
      print('Double Decrypted: $doubleDecrypted');
    }
  });
}
