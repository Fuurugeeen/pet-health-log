import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/daily_record.dart';
import '../../../models/pet.dart';
import '../../../shared/providers/daily_record_provider.dart';
import '../../../shared/providers/pet_provider.dart';
import 'daily_record_detail_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final selectedPet = ref.watch(selectedPetProvider);
    final petsAsync = ref.watch(petsProvider);

    if (selectedPet == null) {
      return _buildNoPetSelected();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.calendar),
        actions: [
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
          _buildCalendar(selectedPet),
          const Divider(),
          Expanded(
            child: _buildSelectedDayRecords(selectedPet),
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

  Widget _buildCalendar(Pet selectedPet) {
    // 今月の記録を取得
    final startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    final recordsAsync = ref.watch(recordsByDateRangeProvider((
      petId: selectedPet.id,
      start: startOfMonth,
      end: endOfMonth,
    )));

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: recordsAsync.when(
          data: (records) => _buildCalendarWidget(records),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('エラー: $error'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarWidget(List<DailyRecord> records) {
    // 記録がある日付のマップを作成
    final recordDates = <DateTime, DailyRecord>{};
    for (final record in records) {
      final date =
          DateTime(record.date.year, record.date.month, record.date.day);
      recordDates[date] = record;
    }

    return TableCalendar<DailyRecord>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarFormat: _calendarFormat,
      availableCalendarFormats: const {
        CalendarFormat.month: '月',
        CalendarFormat.twoWeeks: '2週間',
        CalendarFormat.week: '週',
      },
      eventLoader: (day) {
        final dateKey = DateTime(day.year, day.month, day.day);
        return recordDates.containsKey(dateKey) ? [recordDates[dateKey]!] : [];
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: const HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonShowsNext: false,
        formatButtonDecoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        formatButtonTextStyle: TextStyle(
          color: Colors.white,
        ),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: const TextStyle(color: AppColors.error),
        holidayTextStyle: const TextStyle(color: AppColors.error),
        selectedDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
    );
  }

  Widget _buildSelectedDayRecords(Pet selectedPet) {
    if (_selectedDay == null) {
      return const Center(child: Text('日付を選択してください'));
    }

    final recordAsync = ref.watch(recordByDateProvider((
      petId: selectedPet.id,
      date: _selectedDay!,
    )));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('yyyy年M月d日 (E)', 'ja').format(_selectedDay!),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (recordAsync.hasValue && recordAsync.value != null)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DailyRecordDetailScreen(
                          date: _selectedDay!,
                          pet: selectedPet,
                          existingRecord: recordAsync.value,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: recordAsync.when(
              data: (record) => record != null
                  ? _buildRecordSummary(record)
                  : _buildNoRecord(selectedPet),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('エラー: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordSummary(DailyRecord record) {
    return ListView(
      children: [
        if (record.meals.isNotEmpty) ...[
          _buildSectionHeader('食事記録', Icons.restaurant, record.meals.length),
          ...record.meals.map((meal) => _buildMealItem(meal)),
          const SizedBox(height: 16),
        ],
        if (record.medications.isNotEmpty) ...[
          _buildSectionHeader(
              '投薬記録', Icons.medication, record.medications.length),
          ...record.medications
              .map((medication) => _buildMedicationItem(medication)),
          const SizedBox(height: 16),
        ],
        if (record.excretions.isNotEmpty) ...[
          _buildSectionHeader('排泄記録', Icons.bathroom, record.excretions.length),
          ...record.excretions
              .map((excretion) => _buildExcretionItem(excretion)),
          const SizedBox(height: 16),
        ],
        _buildSectionHeader('健康状態', Icons.favorite, 1),
        if (record.healthStatus != null)
          _buildHealthStatusItem(record.healthStatus!),
        if (record.notes != null && record.notes!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionHeader('メモ', Icons.note, 1),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(record.notes!),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNoRecord(Pet selectedPet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.note_add,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          const Text(
            'この日の記録はありません',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DailyRecordDetailScreen(
                    date: _selectedDay!,
                    pet: selectedPet,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('記録を追加'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealItem(MealRecord meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.restaurant, color: AppColors.primary),
        title: Text(meal.foodType),
        subtitle: Text('${meal.amount.toStringAsFixed(0)}g'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(
                5,
                (index) => Icon(
                      index < meal.appetiteLevel
                          ? Icons.star
                          : Icons.star_border,
                      size: 16,
                      color: AppColors.warning,
                    )),
            const SizedBox(width: 8),
            Text(DateFormat('HH:mm').format(meal.time)),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationItem(MedicationRecord medication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.medication, color: AppColors.secondary),
        title: Text(medication.medicationName),
        subtitle:
            Text('${medication.dosage} ${medication.administrationMethod}'),
        trailing: Text(DateFormat('HH:mm').format(medication.time)),
      ),
    );
  }

  Widget _buildExcretionItem(ExcretionRecord excretion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          excretion.type == ExcretionType.stool
              ? Icons.circle
              : Icons.water_drop,
          color: AppColors.accent,
        ),
        title: Text(excretion.type == ExcretionType.stool ? '便' : '尿'),
        subtitle: Text(_getConditionText(excretion.condition)),
        trailing: Text(DateFormat('HH:mm').format(excretion.time)),
      ),
    );
  }

  Widget _buildHealthStatusItem(HealthStatus healthStatus) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.thermostat, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Text(
                    '体温: ${healthStatus.temperature?.toStringAsFixed(1) ?? '未記録'}°C'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.monitor_weight,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                    '体重: ${healthStatus.weight?.toStringAsFixed(1) ?? '未記録'}kg'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.directions_run,
                    color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                const Text('活動レベル: '),
                ...List.generate(
                    5,
                    (index) => Icon(
                          index < healthStatus.activityLevel
                              ? Icons.star
                              : Icons.star_border,
                          size: 16,
                          color: AppColors.warning,
                        )),
              ],
            ),
            if (healthStatus.symptoms.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('症状:'),
                        ...healthStatus.symptoms.map((symptom) => Text(
                              '• ${_getSymptomText(symptom)}',
                              style: const TextStyle(fontSize: 14),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getConditionText(StoolCondition? condition) {
    if (condition == null) return '不明';
    switch (condition) {
      case StoolCondition.normal:
        return '正常';
      case StoolCondition.soft:
        return '軟便';
      case StoolCondition.hard:
        return '硬便';
      case StoolCondition.diarrhea:
        return '下痢';
    }
  }

  String _getSymptomText(Symptom symptom) {
    switch (symptom) {
      case Symptom.cough:
        return '咳';
      case Symptom.sneeze:
        return 'くしゃみ';
      case Symptom.vomiting:
        return '嘔吐';
      case Symptom.diarrhea:
        return '下痢';
      case Symptom.lossOfAppetite:
        return '食欲不振';
      case Symptom.lethargy:
        return '元気がない';
      case Symptom.fever:
        return '発熱';
      case Symptom.other:
        return 'その他';
    }
  }
}
