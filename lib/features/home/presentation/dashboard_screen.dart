import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/daily_record.dart';
import '../../../models/pet.dart';
import '../../../shared/providers/daily_record_provider.dart';
import '../../../shared/providers/pet_provider.dart';
import '../../../shared/widgets/bottom_navigation.dart';

class DashboardScreen extends ConsumerWidget {
  final bool showBottomNav;
  final Function(int, {int? recordTabIndex})? onTabChanged;

  const DashboardScreen(
      {super.key, this.showBottomNav = true, this.onTabChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPet = ref.watch(selectedPetProvider);
    final petsAsync = ref.watch(petsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.home),
        actions: [
          if (selectedPet != null)
            DropdownButton<String>(
              value: selectedPet.id,
              underline: Container(),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              dropdownColor: AppColors.primary,
              onChanged: (petId) {
                if (petId != null) {
                  petsAsync.whenData((pets) {
                    final pet = pets.firstWhere((p) => p.id == petId);
                    ref.read(selectedPetProvider.notifier).state = pet;
                  });
                }
              },
              items: petsAsync.when(
                data: (pets) => pets.map((pet) {
                  return DropdownMenuItem(
                    value: pet.id,
                    child: Text(
                      pet.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                loading: () => [],
                error: (_, __) => [],
              ),
            ),
        ],
      ),
      body: selectedPet == null
          ? _buildNoPetSelected(context)
          : _buildDashboard(context, ref, selectedPet),
      bottomNavigationBar:
          showBottomNav ? const BottomNavigation(currentIndex: 0) : null,
    );
  }

  Widget _buildNoPetSelected(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pets,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            const Text(
              'ペットが登録されていません',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '最初のペットを登録して\n健康管理を始めましょう',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // 直接ペット追加画面へ遷移
                context.go('/pets/form');
              },
              icon: const Icon(Icons.add),
              label: const Text('ペットを登録'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref, pet) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ペット情報カード
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryLight,
                  child: pet.photoBase64 != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: const Icon(Icons.pets, size: 30),
                        )
                      : const Icon(Icons.pets, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_getPetTypeDisplayName(pet.type)} • ${AppDateUtils.getAgeString(pet.birthDate)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // クイック記録
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'クイック記録',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        context,
                        '食事',
                        Icons.restaurant,
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickActionButton(
                        context,
                        '投薬',
                        Icons.medication,
                        AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        context,
                        '排泄',
                        Icons.bathroom,
                        AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickActionButton(
                        context,
                        '散歩',
                        Icons.directions_walk,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        context,
                        '体調',
                        Icons.favorite,
                        AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Container()), // 空のスペース
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 最近の記録
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '最近の記録',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRecentRecordsWidget(context, ref, pet),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return ElevatedButton(
      onPressed: () {
        // 記録画面に切り替えて、対応するタブを選択
        if (onTabChanged != null) {
          final tabIndex = _getRecordTabIndex(title);
          onTabChanged!(1, recordTabIndex: tabIndex); // 記録タブに移動し、対応するタブを指定
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRecordsWidget(BuildContext context, WidgetRef ref, pet) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    // 日付の時間部分を削除して正規化
    final startDate =
        DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day);
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final recordsAsync = ref.watch(recordsByDateRangeProvider((
      petId: pet.id,
      start: startDate,
      end: endDate,
    )));

    return recordsAsync.when(
      data: (records) {
        if (records.isEmpty) {
          return const Text(
            'まだ記録がありません',
            style: TextStyle(color: AppColors.textSecondary),
          );
        }

        // 最新の記録からリスト作成
        final allItems = <Map<String, dynamic>>[];

        for (final record in records) {
          // 食事記録
          for (final meal in record.meals) {
            allItems.add({
              'title': '食事',
              'subtitle':
                  '${meal.foodType} (${_getAppetiteText(meal.appetiteLevel)})',
              'time': meal.time,
            });
          }

          // 散歩記録
          for (final walk in record.walks) {
            allItems.add({
              'title': '散歩',
              'subtitle': '${walk.duration}分',
              'time': walk.startTime,
            });
          }

          // 投薬記録
          for (final medication in record.medications) {
            allItems.add({
              'title': '投薬',
              'subtitle': medication.medicationName,
              'time': medication.time,
            });
          }

          // 排泄記録
          for (final excretion in record.excretions) {
            allItems.add({
              'title': '排泄',
              'subtitle': excretion.type.displayName,
              'time': excretion.time,
            });
          }
        }

        // 時間でソートして最新3件
        allItems.sort(
            (a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));
        final displayItems = allItems.take(3);

        if (displayItems.isEmpty) {
          return const Text(
            'まだ記録がありません',
            style: TextStyle(color: AppColors.textSecondary),
          );
        }

        return Column(
          children: displayItems
              .map((item) => _buildRecentRecord(
                    item['title']!,
                    item['subtitle']!,
                    AppDateUtils.getRelativeTime(item['time'] as DateTime),
                  ))
              .toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const Text(
        '記録の読み込みに失敗しました',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  String _getAppetiteText(int level) {
    switch (level) {
      case 1:
        return '食べない';
      case 2:
        return '少し';
      case 3:
        return '普通';
      case 4:
        return 'よく食べる';
      case 5:
        return '完食';
      default:
        return '普通';
    }
  }

  Widget _buildRecentRecord(String title, String subtitle, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getPetTypeDisplayName(PetType type) {
    switch (type) {
      case PetType.dog:
        return '犬';
      case PetType.cat:
        return '猫';
      case PetType.other:
        return 'その他';
    }
  }

  int _getRecordTabIndex(String title) {
    switch (title) {
      case '食事':
        return 0;
      case '投薬':
        return 1;
      case '排泄':
        return 2;
      case '散歩':
        return 3;
      case '体調':
        return 4;
      default:
        return 0;
    }
  }
}
