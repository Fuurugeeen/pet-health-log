import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_health_log/features/pet/presentation/pet_list_screen.dart';
import 'package:pet_health_log/models/pet.dart';
import 'package:pet_health_log/shared/providers/pet_provider.dart';
import '../fixtures/mock_data.dart';

void main() {
  group('PetListScreen Widget Tests', () {
    testWidgets('空の状態を正しく表示する', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            petsProvider.overrideWith(
              (ref) => Stream.value(const AsyncValue<List<Pet>>.data([])),
            ),
          ],
          child: const MaterialApp(
            home: PetListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 空の状態メッセージを確認
      expect(find.text('登録されているペットがいません'), findsOneWidget);
      expect(find.text('右下のボタンから'), findsOneWidget);
    });

    testWidgets('ローディング状態を表示する', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            petsProvider.overrideWith(
              (ref) => Stream.value(const AsyncValue<List<Pet>>.loading()),
            ),
          ],
          child: const MaterialApp(
            home: PetListScreen(),
          ),
        ),
      );

      // ローディングインジケーターを確認
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ペットのリストを表示する', (WidgetTester tester) async {
      final testPets = [MockData.testDog, MockData.testCat];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            petsProvider.overrideWith(
              (ref) => Stream.value(AsyncValue<List<Pet>>.data(testPets)),
            ),
          ],
          child: const MaterialApp(
            home: PetListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // ペットの名前が表示されることを確認
      expect(find.text('ポチ'), findsOneWidget);
      expect(find.text('タマ'), findsOneWidget);

      // ペットの種類が表示されることを確認
      expect(find.text('柴犬'), findsOneWidget);
      expect(find.text('アメリカンショートヘア'), findsOneWidget);
    });

    testWidgets('AppBarに正しいタイトルが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            petsProvider.overrideWith(
              (ref) => Stream.value(const AsyncValue<List<Pet>>.data([])),
            ),
          ],
          child: const MaterialApp(
            home: PetListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('ペット一覧'), findsOneWidget);
    });

    testWidgets('FloatingActionButtonが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            petsProvider.overrideWith(
              (ref) => Stream.value(const AsyncValue<List<Pet>>.data([])),
            ),
          ],
          child: const MaterialApp(
            home: PetListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('エラー状態を表示する', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            petsProvider.overrideWith(
              (ref) => Stream.value(
                AsyncValue<List<Pet>>.error(
                  'テストエラー',
                  StackTrace.current,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: PetListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // エラーメッセージを確認
      expect(find.textContaining('エラー'), findsOneWidget);
    });
  });
}
