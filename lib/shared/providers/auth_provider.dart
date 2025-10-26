import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AsyncValue<User?>>((ref) {
  return CurrentUserNotifier(ref.read(authRepositoryProvider));
});

class CurrentUserNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _authRepository;

  CurrentUserNotifier(this._authRepository) : super(const AsyncValue.loading()) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> login(String name) async {
    try {
      state = const AsyncValue.loading();
      final user = await _authRepository.login(name);
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await _authRepository.updateUser(user);
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void refresh() {
    _loadCurrentUser();
  }
}

final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final authRepository = ref.read(authRepositoryProvider);
  return await authRepository.isLoggedIn();
});