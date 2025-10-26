import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../home/presentation/dashboard_screen.dart';
import '../../record/presentation/record_form_screen.dart';
import '../../calendar/presentation/calendar_screen.dart';
import '../../report/presentation/report_screen.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/bottom_navigation.dart';


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
  int? _recordTabIndex;

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

  void _onTabTapped(int index, {int? recordTabIndex}) {
    setState(() {
      _currentIndex = index;
      if (recordTabIndex != null) {
        _recordTabIndex = recordTabIndex;
      }
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
        children: [
          DashboardScreen(showBottomNav: false, onTabChanged: _onTabTapped), // ボトムナビを表示しない
          RecordFormScreen(showBottomNav: false, initialTabIndex: _recordTabIndex), // ボトムナビを表示しない
          const CalendarScreen(),
          const ReportScreen(),
          const SettingsTabContent(),
        ],
      ),
      bottomNavigationBar: TabBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) => _onTabTapped(index),
      ),
    );
  }
}