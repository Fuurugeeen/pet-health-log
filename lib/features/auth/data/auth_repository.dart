import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../models/user.dart';
import '../../../services/hive_service.dart';

class AuthRepository {
  static const String _currentUserKey = 'current_user_id';
  
  Box get _userBox => HiveService.getUserBox();
  Box get _settingsBox => HiveService.getAppSettingsBox();

  Future<User?> getCurrentUser() async {
    final currentUserId = _settingsBox.get(_currentUserKey);
    if (currentUserId == null) return null;
    
    return _userBox.get(currentUserId);
  }

  Future<User> login(String name) async {
    // 既存ユーザーを検索
    final existingUser = _userBox.values
        .cast<User>()
        .where((user) => user.name == name)
        .firstOrNull;

    User user;
    if (existingUser != null) {
      user = existingUser;
    } else {
      // 新規ユーザー作成
      user = User(
        id: const Uuid().v4(),
        name: name,
        type: UserType.owner,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _userBox.put(user.id, user);
    }

    // 現在のユーザーとして設定
    await _settingsBox.put(_currentUserKey, user.id);
    
    return user;
  }

  Future<void> logout() async {
    await _settingsBox.delete(_currentUserKey);
  }

  Future<bool> isLoggedIn() async {
    final currentUserId = _settingsBox.get(_currentUserKey);
    return currentUserId != null && _userBox.containsKey(currentUserId);
  }

  Future<List<User>> getAllUsers() async {
    return _userBox.values.cast<User>().toList();
  }

  Future<void> updateUser(User user) async {
    final updatedUser = user.copyWith(updatedAt: DateTime.now());
    await _userBox.put(user.id, updatedUser);
  }

  Future<void> deleteUser(String userId) async {
    await _userBox.delete(userId);
    
    // 削除されたユーザーが現在のユーザーの場合、ログアウト
    final currentUserId = _settingsBox.get(_currentUserKey);
    if (currentUserId == userId) {
      await logout();
    }
  }
}