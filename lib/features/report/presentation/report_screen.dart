import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/pet.dart';
import '../../../shared/providers/pet_provider.dart';

enum ReportPeriod {
  week('1週間'),
  month('1ヶ月'),
  threeMonths('3ヶ月');

  const ReportPeriod(this.displayName);
  final String displayName;
}

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  ReportPeriod _selectedPeriod = ReportPeriod.month;
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final selectedPet = ref.watch(selectedPetProvider);
    final petsAsync = ref.watch(petsProvider);

    if (selectedPet == null) {
      return _buildNoPetSelected();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.report),
        actions: [
          // ペット切り替えドロップダウン
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
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // 期間選択
          _buildPeriodSelector(),
          
          // タブバー
          _buildTabBar(),
          
          // コンテンツ
          Expanded(
            child: _buildTabContent(selectedPet),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPetSelected() {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pets,
                size: 80,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 24),
              Text(
                'ペットが登録されていません',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '設定画面からペットを登録してください',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.date_range, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text(
            '期間:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<ReportPeriod>(
              value: _selectedPeriod,
              isExpanded: true,
              items: ReportPeriod.values.map((period) {
                return DropdownMenuItem(
                  value: period,
                  child: Text(period.displayName),
                );
              }).toList(),
              onChanged: (period) {
                if (period != null) {
                  setState(() {
                    _selectedPeriod = period;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: TabBar(
        controller: null,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        tabs: const [
          Tab(text: '体重'),
          Tab(text: '食事量'),
          Tab(text: '活動'),
          Tab(text: '統計'),
        ],
      ),
    );
  }

  Widget _buildTabContent(Pet selectedPet) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_selectedTabIndex == 0) _buildWeightChart(),
          if (_selectedTabIndex == 1) _buildFoodChart(),
          if (_selectedTabIndex == 2) _buildActivityChart(),
          if (_selectedTabIndex == 3) _buildStatisticsSummary(selectedPet),
        ],
      ),
    );
  }

  Widget _buildWeightChart() {
    final dummyData = _generateDummyWeightData();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '体重推移',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toStringAsFixed(1)}kg',
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.now().subtract(
                            Duration(days: (dummyData.length - value.toInt() - 1)),
                          );
                          return Text(
                            DateFormat('M/d').format(date),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: dummyData,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodChart() {
    final dummyData = _generateDummyFoodData();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '食事量推移',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}g',
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.now().subtract(
                            Duration(days: (dummyData.length - value.toInt() - 1)),
                          );
                          return Text(
                            DateFormat('M/d').format(date),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: dummyData,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    final dummyData = _generateDummyActivityData();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '活動レベル推移',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.now().subtract(
                            Duration(days: (dummyData.length - value.toInt() - 1)),
                          );
                          return Text(
                            DateFormat('M/d').format(date),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  minY: 1,
                  maxY: 5,
                  lineBarsData: [
                    LineChartBarData(
                      spots: dummyData,
                      isCurved: true,
                      color: AppColors.accent,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSummary(Pet selectedPet) {
    return Column(
      children: [
        // 統計カード
        _buildStatCard(
          '平均体重',
          '${selectedPet.weight.toStringAsFixed(1)}kg',
          Icons.monitor_weight,
          AppColors.primary,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          '平均食事量',
          '120g/日',
          Icons.restaurant,
          AppColors.secondary,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          '平均活動レベル',
          '★★★★☆',
          Icons.directions_run,
          AppColors.accent,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          '記録日数',
          '28日',
          Icons.calendar_today,
          AppColors.success,
        ),
        const SizedBox(height: 32),
        
        // エクスポートボタン
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDF出力機能は開発中です'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('PDFでエクスポート'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ダミーデータ生成メソッド
  List<FlSpot> _generateDummyWeightData() {
    final random = math.Random();
    final dataCount = _getPeriodDays();
    final baseWeight = 5.0; // 基準体重
    
    return List.generate(dataCount, (index) {
      final weight = baseWeight + (random.nextDouble() - 0.5) * 0.4; // ±0.2kg のばらつき
      return FlSpot(index.toDouble(), weight);
    });
  }

  List<BarChartGroupData> _generateDummyFoodData() {
    final random = math.Random();
    final dataCount = _getPeriodDays();
    
    return List.generate(dataCount, (index) {
      final amount = 100 + random.nextInt(40); // 100-140g の範囲
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: amount.toDouble(),
            color: AppColors.secondary,
            width: 16,
          ),
        ],
      );
    });
  }

  List<FlSpot> _generateDummyActivityData() {
    final random = math.Random();
    final dataCount = _getPeriodDays();
    
    return List.generate(dataCount, (index) {
      final activity = 3 + random.nextInt(3); // 3-5 の範囲
      return FlSpot(index.toDouble(), activity.toDouble());
    });
  }

  int _getPeriodDays() {
    switch (_selectedPeriod) {
      case ReportPeriod.week:
        return 7;
      case ReportPeriod.month:
        return 30;
      case ReportPeriod.threeMonths:
        return 90;
    }
  }
}