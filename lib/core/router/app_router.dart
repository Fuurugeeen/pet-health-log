import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/pet/presentation/pet_list_screen.dart';
import '../../features/record/presentation/record_form_screen.dart';
import '../../features/home/presentation/dashboard_screen.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/widgets/bottom_navigation.dart';

// 仮の画面（Phase 3以降で実装予定）
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen();
  }
}

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RecordFormScreen();
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('カレンダー')),
      body: const Center(child: Text('カレンダー画面（Phase 9で実装予定）')),
      bottomNavigationBar: const BottomNavigation(currentIndex: 2),
    );
  }
}

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('レポート')),
      body: const Center(child: Text('レポート画面（Phase 10で実装予定）')),
      bottomNavigationBar: const BottomNavigation(currentIndex: 3),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.pets),
            title: const Text('ペット管理'),
            subtitle: const Text('ペットの登録・編集・削除'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PetListScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('ログアウト'),
            onTap: () async {
              await ref.read(currentUserProvider.notifier).logout();
            },
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 4),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final currentUser = ref.read(currentUserProvider);
      final isLoggedIn = currentUser.value != null;
      final currentLocation = state.matchedLocation;
      
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
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/record',
        builder: (context, state) => const RecordScreen(),
      ),
      GoRoute(
        path: '/calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/report',
        builder: (context, state) => const ReportScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});