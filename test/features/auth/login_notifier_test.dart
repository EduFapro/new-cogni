import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segundo_cogni/providers/auth_providers.dart';

import '../../mocks/fake_auth_repository.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWith((ref) => FakeAuthRepository()),
    ]);
  });

  tearDown(() => container.dispose());

  test('login succeeds with correct credentials', () async {
    final notifier = container.read(loginProvider.notifier);
    await notifier.login('john@example.com', 'correctPassword');

    final state = container.read(loginProvider);
    expect(state, isA<AsyncData<bool>>());
    expect((state as AsyncData).value, true);
  });

  test('login fails with wrong password', () async {
    final notifier = container.read(loginProvider.notifier);
    await notifier.login('john@example.com', 'wrongPassword');

    final state = container.read(loginProvider);
    expect(state.hasError, true);
  });

  test('auto-login loads from current_user table', () async {
    final notifier = container.read(loginProvider.notifier);
    final result = await notifier.build();
    expect(result, false); // assuming no user is saved in the fake initially
  });
}
