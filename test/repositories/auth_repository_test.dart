import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:pet_health_log/features/auth/data/auth_repository.dart';
import 'package:pet_health_log/models/user.dart';
import 'package:pet_health_log/services/hive_service.dart';
import '../helpers/hive_test_helper.dart';
import '../fixtures/mock_data.dart';

void main() {
  group('AuthRepository Tests', () {
    late AuthRepository authRepository;
    late Box<User> userBox;
    late Box settingsBox;

    setUp(() async {
      await HiveTestHelper.initializeHive();

      // ボックスを開く
      userBox = await HiveTestHelper.openBox<User>(HiveService.userBoxName);
      settingsBox = await HiveTestHelper.openBox(HiveService.appSettingsBoxName);

      authRepository = AuthRepository();
    });

    tearDown(() async {
      await HiveTestHelper.tearDown();
    });

    group('login', () {
      test('新規ユーザーを作成してログインできる', () async {
        final user = await authRepository.login('新規ユーザー');

        expect(user.name, '新規ユーザー');
        expect(user.type, UserType.owner);
        expect(userBox.containsKey(user.id), true);
      });

      test('既存ユーザーでログインできる', () async {
        // 既存ユーザーを作成
        await userBox.put(MockData.testUser1.id, MockData.testUser1);

        final user = await authRepository.login(MockData.testUser1.name);

        expect(user.id, MockData.testUser1.id);
        expect(user.name, MockData.testUser1.name);
      });

      test('ログイン後、現在のユーザーが設定される', () async {
        final user = await authRepository.login('テストユーザー');

        final currentUserId = settingsBox.get('current_user_id');
        expect(currentUserId, user.id);
      });

      test('同じ名前のユーザーで2回ログインしても新規作成されない', () async {
        final user1 = await authRepository.login('テストユーザー');
        final user2 = await authRepository.login('テストユーザー');

        expect(user1.id, user2.id);
        expect(userBox.length, 1);
      });
    });

    group('logout', () {
      test('ログアウトできる', () async {
        await authRepository.login('テストユーザー');
        expect(await authRepository.isLoggedIn(), true);

        await authRepository.logout();

        expect(await authRepository.isLoggedIn(), false);
        final currentUserId = settingsBox.get('current_user_id');
        expect(currentUserId, null);
      });
    });

    group('getCurrentUser', () {
      test('現在のユーザーを取得できる', () async {
        final loggedInUser = await authRepository.login('テストユーザー');

        final currentUser = await authRepository.getCurrentUser();

        expect(currentUser, isNotNull);
        expect(currentUser!.id, loggedInUser.id);
        expect(currentUser.name, loggedInUser.name);
      });

      test('ログインしていない場合はnullを返す', () async {
        final currentUser = await authRepository.getCurrentUser();

        expect(currentUser, null);
      });

      test('ユーザーIDが存在するがユーザーが削除されている場合', () async {
        // 存在しないユーザーIDを設定
        await settingsBox.put('current_user_id', 'non_existent_id');

        final currentUser = await authRepository.getCurrentUser();

        expect(currentUser, null);
      });
    });

    group('isLoggedIn', () {
      test('ログインしている場合はtrueを返す', () async {
        await authRepository.login('テストユーザー');

        final isLoggedIn = await authRepository.isLoggedIn();

        expect(isLoggedIn, true);
      });

      test('ログインしていない場合はfalseを返す', () async {
        final isLoggedIn = await authRepository.isLoggedIn();

        expect(isLoggedIn, false);
      });

      test('ユーザーIDが存在するがユーザーが削除されている場合はfalseを返す', () async {
        await settingsBox.put('current_user_id', 'non_existent_id');

        final isLoggedIn = await authRepository.isLoggedIn();

        expect(isLoggedIn, false);
      });
    });

    group('getAllUsers', () {
      test('すべてのユーザーを取得できる', () async {
        await userBox.put(MockData.testUser1.id, MockData.testUser1);
        await userBox.put(MockData.testUser2.id, MockData.testUser2);

        final users = await authRepository.getAllUsers();

        expect(users.length, 2);
        expect(users.any((u) => u.id == MockData.testUser1.id), true);
        expect(users.any((u) => u.id == MockData.testUser2.id), true);
      });

      test('ユーザーが存在しない場合は空リストを返す', () async {
        final users = await authRepository.getAllUsers();

        expect(users, isEmpty);
      });
    });

    group('updateUser', () {
      test('ユーザー情報を更新できる', () async {
        await userBox.put(MockData.testUser1.id, MockData.testUser1);

        final updatedUser = MockData.testUser1.copyWith(name: '更新されたユーザー');
        await authRepository.updateUser(updatedUser);

        final savedUser = await userBox.get(MockData.testUser1.id);
        expect(savedUser!.name, '更新されたユーザー');
      });

      test('更新時にupdatedAtが更新される', () async {
        await userBox.put(MockData.testUser1.id, MockData.testUser1);

        // 少し待ってから更新
        await Future.delayed(const Duration(milliseconds: 10));

        await authRepository.updateUser(MockData.testUser1);

        final savedUser = await userBox.get(MockData.testUser1.id);
        expect(
          savedUser!.updatedAt.isAfter(MockData.testUser1.updatedAt),
          true,
        );
      });
    });

    group('deleteUser', () {
      test('ユーザーを削除できる', () async {
        await userBox.put(MockData.testUser1.id, MockData.testUser1);

        await authRepository.deleteUser(MockData.testUser1.id);

        expect(userBox.containsKey(MockData.testUser1.id), false);
      });

      test('現在ログイン中のユーザーを削除した場合、ログアウトされる', () async {
        await authRepository.login(MockData.testUser1.name);
        await userBox.put(MockData.testUser1.id, MockData.testUser1);
        await settingsBox.put('current_user_id', MockData.testUser1.id);

        expect(await authRepository.isLoggedIn(), true);

        await authRepository.deleteUser(MockData.testUser1.id);

        expect(await authRepository.isLoggedIn(), false);
      });

      test('別のユーザーを削除してもログイン状態は維持される', () async {
        await authRepository.login(MockData.testUser1.name);
        await userBox.put(MockData.testUser1.id, MockData.testUser1);
        await userBox.put(MockData.testUser2.id, MockData.testUser2);
        await settingsBox.put('current_user_id', MockData.testUser1.id);

        await authRepository.deleteUser(MockData.testUser2.id);

        expect(await authRepository.isLoggedIn(), true);
        final currentUser = await authRepository.getCurrentUser();
        expect(currentUser!.id, MockData.testUser1.id);
      });
    });
  });
}
