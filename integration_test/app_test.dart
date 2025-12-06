import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:segundo_cogni/main.dart' as app;
import 'package:fluent_ui/fluent_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login flow test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Verify we are on the Login Screen
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);

    // Enter Credentials
    final textBoxes = find.byType(TextBox);
    expect(textBoxes, findsNWidgets(2));

    await tester.enterText(textBoxes.at(0), 'johndoe');
    await tester.enterText(textBoxes.at(1), 'password123');
    await tester.pumpAndSettle();

    // Tap Sign In
    await tester.tap(find.text('Sign in'));

    // Wait for navigation
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify we navigated away from login
    // If successful, we should be at /home.
    // We can check for absence of "Sign in" button.
    expect(find.text('Sign in'), findsNothing);
  });
}
