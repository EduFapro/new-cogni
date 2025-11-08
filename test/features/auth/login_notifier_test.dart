import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/features/auth/application/login_notifier.dart';
import 'package:segundo_cogni/features/evaluator/data/evaluator_model.dart';


void main() {
  test('Successful login stores user in current_user table', () async {
    final notifier = LoginNotifier(); // You may need a mock/ref
    await notifier.login('john@example.com', 'correctPassword');

    // Query the DB
    final user = await db.query('current_user');
    expect(user.length, 1);
    expect(user.first['email'], isNotEmpty);
  });

  test('Login fails with wrong password', () async {
    final notifier = LoginNotifier();
    await notifier.login('john@example.com', 'wrongPassword');

    expect(notifier.state.hasError, true);
  });
}
