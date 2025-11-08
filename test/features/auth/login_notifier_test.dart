import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/features/auth/application/login_notifier.dart';

void main() {
  test('login succeeds with correct credentials', () async {
    final notifier = LoginNotifier(); // You may need to inject mocks
    await notifier.login('john@example.com', 'correctPassword');
    expect(notifier.state, isA<AsyncData<bool>>());
    expect((notifier.state as AsyncData).value, true);
  });

  test('login fails with wrong password', () async {
    final notifier = LoginNotifier();
    await notifier.login('john@example.com', 'wrongPassword');
    expect(notifier.state.hasError, true);
  });

  test('auto-login loads from current_user table', () async {
    final notifier = LoginNotifier();
    final result = await notifier.build();
    expect(result, false); // Or true depending on `getCachedUser()`
  });
}
