import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pet_health_log/core/constants/app_strings.dart';
import 'package:pet_health_log/features/auth/presentation/login_screen.dart';

void main() {
  group('Pet Health Log App Tests', () {
    testWidgets('Login screen renders correctly', (WidgetTester tester) async {
      // Build login screen with ProviderScope
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Wait for the screen to settle
      await tester.pumpAndSettle();

      // Verify that login screen elements are displayed
      expect(find.text(AppStrings.appName), findsOneWidget);
      expect(find.text('ユーザー名'), findsOneWidget);
      expect(find.text('ログイン'), findsOneWidget);
    });

    testWidgets('Login form validation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap login button without entering username
      final loginButton = find.text('ログイン');
      expect(loginButton, findsOneWidget);
      
      await tester.tap(loginButton);
      await tester.pump();

      // Should show validation error
      expect(find.text('ユーザー名を入力してください'), findsOneWidget);
    });

    testWidgets('Username input works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find username field and enter text
      final usernameField = find.byType(TextFormField);
      expect(usernameField, findsOneWidget);
      
      await tester.enterText(usernameField, 'テストユーザー');
      await tester.pump();

      // Verify text was entered
      expect(find.text('テストユーザー'), findsOneWidget);
    });
  });
}