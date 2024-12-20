// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:integration_test/integration_test.dart';
// import 'package:flutter_application_1/main.dart' as app;

// void main() {
//   IntegrationTestWidgetsFlutterBinding.ensureInitialized();

//   testWidgets('Login Test: Navigate to login and sign in',
//       (WidgetTester tester) async {
//     // Launch the app
//     app.main();
//     await tester.pumpAndSettle(const Duration(seconds: 5));

//     // Step 1: Navigate to Sign In
//     final signInTextButton =
//         find.text('Already have an account? Sign In here!');
//     expect(signInTextButton, findsOneWidget); // Ensure the button is present
//     await tester.tap(signInTextButton);
//     await tester.pumpAndSettle();

//     // Step 2: Enter email and password
//     final emailField =
//         find.byType(TextField).first; // First TextField is for email
//     final passwordField =
//         find.byType(TextField).at(1); // Second TextField is for password
//     final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');

//     await tester.enterText(emailField, 'menna@gmail.com'); // Input email
//     await tester.enterText(passwordField, 'menna123'); // Input password
//     await tester.tap(signInButton); // Tap the Sign In button
//     await tester.pumpAndSettle();

//     // Step 3: Verify navigation to the next screen (assumes '/loading' route is used)
//     expect(find.byType(CircularProgressIndicator),
//         findsOneWidget); // Check loading indicator
//   });
// }
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_application_1/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login Test: Navigate to login and sign in',
      (WidgetTester tester) async {
    // Launch the app
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Step 1: Navigate to Sign In
    final signInTextButton =
        find.text('Already have an account? Sign In here!');
    expect(signInTextButton, findsOneWidget);
    await tester.tap(signInTextButton);
    await tester.pumpAndSettle();

    // Step 2: Enter email and password
    final emailField = find.byType(TextField).first;
    final passwordField = find.byType(TextField).at(1);
    final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');

    await tester.enterText(emailField, 'menna@gmail.com');
    await tester.enterText(passwordField, 'menna123');

    // Dismiss the keyboard by tapping outside the input fields
    await tester.tapAt(const Offset(0, 0));
    await tester.pumpAndSettle();

    // Step 3: Tap the Sign In button
    await tester.tap(signInButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Step 4: Verify navigation to the Loading Screen
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Step 5: Wait for navigation to the Home Screen
    await tester.pumpAndSettle(const Duration(seconds: 6));
    expect(find.text('Home'), findsOneWidget);
  });
}
