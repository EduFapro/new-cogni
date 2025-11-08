import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/utils/validation_helper.dart';

void main() {
  test('✅ Valid email format passes', () {
    expect(ValidationHelper.isValidEmail('user@example.com'), isTrue);
  });

  test('❌ Invalid email format fails', () {
    expect(ValidationHelper.isValidEmail('invalid@com'), isFalse);
    expect(ValidationHelper.isValidEmail('missingdomain@'), isFalse);
  });

  test('✅ Valid password passes (>= 8 chars)', () {
    expect(ValidationHelper.isValidPassword('12345678'), isTrue);
  });

  test('❌ Invalid password fails (< 8 chars)', () {
    expect(ValidationHelper.isValidPassword('abc123'), isFalse);
  });
}
