import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/pet/presentation/pet_list_screen.dart';
import '../../features/pet/presentation/pet_form_screen.dart';
import '../../features/main/presentation/main_tab_screen.dart';
import '../../shared/providers/auth_provider.dart';
import '../../models/pet.dart';

// メインタブ画面
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainTabScreen();
  }
}


final routerProvider = Provider<GoRouter>((ref) {
  // 認証状態の変更を監視
  ref.watch(currentUserProvider);
  
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final currentUserAsync = ref.read(currentUserProvider);
      final currentLocation = state.matchedLocation;
      
      // AsyncValueの状態に応じて処理
      return currentUserAsync.when(
        loading: () => null, // ローディング中は現在の画面を維持
        error: (_, __) => '/login', // エラーの場合はログイン画面へ
        data: (user) {
          final isLoggedIn = user != null;
          
          // ログインしていない場合はログイン画面へ
          if (!isLoggedIn && currentLocation != '/login') {
            return '/login';
          }
          
          // ログインしている場合はログイン画面からホームへ
          if (isLoggedIn && currentLocation == '/login') {
            return '/home';
          }
          
          return null;
        },
      );
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      // ペット管理画面（設定から直接アクセス）
      GoRoute(
        path: '/pets',
        builder: (context, state) => const PetListScreen(),
      ),
      // ペット登録・編集画面
      GoRoute(
        path: '/pets/form',
        builder: (context, state) {
          final pet = state.extra as Pet?;
          return PetFormScreen(pet: pet);
        },
      ),
    ],
  );
});