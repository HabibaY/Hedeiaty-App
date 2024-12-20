import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_application_1/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Friend Event Gift Pledge Test', (WidgetTester tester) async {
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
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Step 4: Verify navigation to Home Screen
    expect(find.text('Home'), findsWidgets);

    // Step 5: Click the > button of the first friend
    final friendArrowButton = find.byIcon(Icons.arrow_forward_ios).first;
    await tester.tap(friendArrowButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Step 6: Select 'Show Gifts' button for the second event
    await tester.pumpAndSettle(const Duration(seconds: 3));
    final showGiftsButton = find.widgetWithText(TextButton, 'Show Gifts').at(1);
    await tester.tap(showGiftsButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Step 7: Click the 'Pledge' button
    await tester.pumpAndSettle(const Duration(seconds: 3));
    final pledgeButton = find.widgetWithText(ElevatedButton, 'Pledge').first;
    await tester.tap(pledgeButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Step 8: Click the back button
    await tester.pumpAndSettle(const Duration(seconds: 1));
    final backButton = find.byTooltip('Back');
    await tester.tap(backButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // // Step 9: Click the 'Close' button
    // await tester.pumpAndSettle(const Duration(seconds: 4));
    // final closeButton = find.widgetWithText(TextButton, 'Close');
    // expect(closeButton, findsOneWidget);
    // await tester.tap(closeButton);
    // await tester.pumpAndSettle(const Duration(seconds: 4));

    // Step 10: Tap the 'Profile' icon in the navigation bar
    final profileNavBarButton = find.byIcon(Icons.person).first;
    await tester.tap(profileNavBarButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Step 11: Tap 'My Pledged Gifts'
    final myPledgedGiftsButton =
        find.widgetWithText(ListTile, 'My Pledged Gifts');
    await tester.tap(myPledgedGiftsButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Step 12: Verify the name of the pledged gift
    expect(find.text('Bouquet'),
        findsOneWidget); // Replace 'Bouquet' with the actual name of the gift

    // Step 13: Navigate back to Home
    final backFromPledgedGiftsButton = find.byTooltip('Back');
    await tester.tap(backFromPledgedGiftsButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final homeNavBarButton = find.byIcon(Icons.home).first;
    await tester.tap(homeNavBarButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
