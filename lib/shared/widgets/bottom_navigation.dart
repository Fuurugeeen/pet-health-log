import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_strings.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/record');
            break;
          case 2:
            context.go('/calendar');
            break;
          case 3:
            context.go('/report');
            break;
          case 4:
            context.go('/settings');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: AppStrings.home,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle),
          label: AppStrings.record,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: AppStrings.calendar,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: AppStrings.report,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: AppStrings.settings,
        ),
      ],
    );
  }
}

// タブ専用のボトムナビゲーション（画面遷移なし）
class TabBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const TabBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: AppStrings.home,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle),
          label: AppStrings.record,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: AppStrings.calendar,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: AppStrings.report,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: AppStrings.settings,
        ),
      ],
    );
  }
}