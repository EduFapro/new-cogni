import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/utils/validation_helper.dart';

void main() {
  test('valid email format passes', () {
    expect(ValidationHelper.isValidEmail('a@b.com'), true);
  });

  test('invalid email format fails', () {
    expect(ValidationHelper.isValidEmail('not-email'), false);
    expect(ValidationHelper.isValidEmail('a@b'), false);
    expect(ValidationHelper.isValidEmail('@b.com'), false);
  });

  test('password at least 8 chars', () {
    expect(ValidationHelper.isValidPassword('12345678'), true);
    expect(ValidationHelper.isValidPassword('abc12345'), true);
    expect(ValidationHelper.isValidPassword('abc12'), false);
    expect(ValidationHelper.isValidPassword(''), false);
  });
}
