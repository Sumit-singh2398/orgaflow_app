// Basic smoke test for the Orgaflow app.
//
// The app starts on the LoginScreen, so this test verifies that the
// app builds and the login screen renders its expected content.

import 'package:flutter_test/flutter_test.dart';

import 'package:orgaflow_app/main.dart';

void main() {
  testWidgets('App builds and shows the login screen',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AssetFlowApp());
    await tester.pumpAndSettle();

    // Verify that the login screen content is visible.
    expect(find.text('Welcome to Orgaflow'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
