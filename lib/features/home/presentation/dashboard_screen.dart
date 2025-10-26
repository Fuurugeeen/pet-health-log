import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/pet.dart';
import '../../../shared/providers/pet_provider.dart';
import '../../../shared/widgets/bottom_navigation.dart';

class DashboardScreen extends ConsumerWidget {
  final bool showBottomNav;
  final Function(int)? onTabChanged;
  
  const DashboardScreen({super.key, this.showBottomNav = true, this.onTabChanged});

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
          : _buildDashboard(context, selectedPet),
      bottomNavigationBar: showBottomNav ? const BottomNavigation(currentIndex: 0) : null,
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, pet) {
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

        // 今日の記録状況
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '今日の記録状況',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildProgressItem('食事記録', 0.8, Icons.restaurant),
                const SizedBox(height: 8),
                _buildProgressItem('投薬記録', 1.0, Icons.medication),
                const SizedBox(height: 8),
                _buildProgressItem('排泄記録', 0.6, Icons.bathroom),
                const SizedBox(height: 8),
                _buildProgressItem('体調記録', 0.5, Icons.favorite),
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
                        '体調',
                        Icons.favorite,
                        AppColors.warning,
                      ),
                    ),
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
                _buildRecentRecord('朝食', '完食', '2時間前'),
                _buildRecentRecord('散歩', '30分', '4時間前'),
                _buildRecentRecord('投薬', 'アレルギー薬', '昨日'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressItem(String title, double progress, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.divider,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ],
          ),
        ),
        Text('${(progress * 100).round()}%'),
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
        // 記録画面（タブインデックス1）に切り替え
        if (onTabChanged != null) {
          onTabChanged!(1);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(title),
        ],
      ),
    );
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
}