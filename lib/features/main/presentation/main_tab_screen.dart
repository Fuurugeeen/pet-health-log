import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../home/presentation/dashboard_screen.dart';
import '../../record/presentation/record_form_screen.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/bottom_navigation.dart';

// カレンダー画面（仮実装）
class CalendarTabContent extends StatelessWidget {
  const CalendarTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('カレンダー')),
      body: const Center(
        child: Text('カレンダー画面（Phase 9で実装予定）'),
      ),
    );
  }
}

// レポート画面（仮実装）
class ReportTabContent extends StatelessWidget {
  const ReportTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('レポート')),
      body: const Center(
        child: Text('レポート画面（Phase 10で実装予定）'),
      ),
    );
  }
}

// 設定画面
class SettingsTabContent extends ConsumerWidget {
  const SettingsTabContent({super.key});

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
              context.go('/pets');
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
    );
  }
}

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          DashboardScreen(showBottomNav: false), // ボトムナビを表示しない
          RecordFormScreen(),
          CalendarTabContent(),
          ReportTabContent(),
          SettingsTabContent(),
        ],
      ),
      bottomNavigationBar: TabBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}