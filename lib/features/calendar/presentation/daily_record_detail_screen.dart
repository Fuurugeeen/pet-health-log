import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/daily_record.dart';
import '../../../models/pet.dart';
import '../../../shared/providers/daily_record_provider.dart';

class DailyRecordDetailScreen extends ConsumerStatefulWidget {
  final DateTime date;
  final Pet pet;
  final DailyRecord? existingRecord;

  const DailyRecordDetailScreen({
    super.key,
    required this.date,
    required this.pet,
    this.existingRecord,
  });

  @override
  ConsumerState<DailyRecordDetailScreen> createState() => _DailyRecordDetailScreenState();
}

class _DailyRecordDetailScreenState extends ConsumerState<DailyRecordDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _notesController = TextEditingController();
  
  List<MealRecord> _meals = [];
  List<MedicationRecord> _medications = [];
  List<ExcretionRecord> _excretions = [];
  List<Symptom> _selectedSymptoms = [];
  
  final _temperatureController = TextEditingController(text: '38.5');
  final _weightController = TextEditingController();
  final _healthNotesController = TextEditingController();
  int _activityLevel = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // 既存の記録がある場合は初期値を設定
    if (widget.existingRecord != null) {
      final record = widget.existingRecord!;
      _meals = List.from(record.meals);
      _medications = List.from(record.medications);
      _excretions = List.from(record.excretions);
      _selectedSymptoms = List.from(record.healthStatus?.symptoms ?? []);
      _temperatureController.text = record.healthStatus?.temperature?.toString() ?? '38.5';
      _weightController.text = record.healthStatus?.weight?.toString() ?? widget.pet.weight.toString();
      _activityLevel = record.healthStatus?.activityLevel ?? 3;
      _notesController.text = record.notes ?? '';
    } else {
      // ペットの体重をデフォルト値として設定
      _weightController.text = widget.pet.weight.toString();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    _temperatureController.dispose();
    _weightController.dispose();
    _healthNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.pet.name}の記録'),
            Text(
              DateFormat('yyyy年M月d日 (E)', 'ja').format(widget.date),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _saveRecord,
            child: const Text(
              '保存',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '食事'),
            Tab(text: '投薬'),
            Tab(text: '排泄'),
            Tab(text: '健康'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMealTab(),
          _buildMedicationTab(),
          _buildExcretionTab(),
          _buildHealthTab(),
        ],
      ),
    );
  }

  Widget _buildMealTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '食事記録',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _addMeal,
                icon: const Icon(Icons.add),
                label: const Text('追加'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _meals.isEmpty
                ? const Center(
                    child: Text(
                      '食事記録を追加してください',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    itemCount: _meals.length,
                    itemBuilder: (context, index) {
                      final meal = _meals[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.restaurant, color: AppColors.primary),
                          title: Text(meal.foodType),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${meal.amount.toStringAsFixed(0)}g'),
                              Row(
                                children: [
                                  const Text('食欲: '),
                                  ...List.generate(5, (i) => Icon(
                                    i < meal.appetiteLevel ? Icons.star : Icons.star_border,
                                    size: 16,
                                    color: AppColors.warning,
                                  )),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(DateFormat('HH:mm').format(meal.time)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.error),
                                onPressed: () => _removeMeal(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '投薬記録',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _addMedication,
                icon: const Icon(Icons.add),
                label: const Text('追加'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _medications.isEmpty
                ? const Center(
                    child: Text(
                      '投薬記録を追加してください',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    itemCount: _medications.length,
                    itemBuilder: (context, index) {
                      final medication = _medications[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.medication, color: AppColors.secondary),
                          title: Text(medication.medicationName),
                          subtitle: Text('${medication.dosage} ${medication.administrationMethod}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(DateFormat('HH:mm').format(medication.time)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.error),
                                onPressed: () => _removeMedication(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildExcretionTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '排泄記録',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _addExcretion,
                icon: const Icon(Icons.add),
                label: const Text('追加'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _excretions.isEmpty
                ? const Center(
                    child: Text(
                      '排泄記録を追加してください',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    itemCount: _excretions.length,
                    itemBuilder: (context, index) {
                      final excretion = _excretions[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            excretion.type == ExcretionType.stool ? Icons.circle : Icons.water_drop,
                            color: AppColors.accent,
                          ),
                          title: Text(excretion.type == ExcretionType.stool ? '便' : '尿'),
                          subtitle: Text(_getConditionText(excretion.condition)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(DateFormat('HH:mm').format(excretion.time)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.error),
                                onPressed: () => _removeExcretion(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '健康状態',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.thermostat, color: AppColors.error),
                        const SizedBox(width: 8),
                        const Text('体温 (°C)'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _temperatureController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.monitor_weight, color: AppColors.primary),
                        const SizedBox(width: 8),
                        const Text('体重 (kg)'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.directions_run, color: AppColors.accent),
                        const SizedBox(width: 8),
                        const Text('活動レベル'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            children: List.generate(5, (index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _activityLevel = index + 1;
                                  });
                                },
                                child: Icon(
                                  index < _activityLevel ? Icons.star : Icons.star_border,
                                  color: AppColors.warning,
                                  size: 24,
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '症状',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: Symptom.values.map((symptom) {
                    final isSelected = _selectedSymptoms.contains(symptom);
                    return FilterChip(
                      label: Text(_getSymptomText(symptom)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSymptoms.add(symptom);
                          } else {
                            _selectedSymptoms.remove(symptom);
                          }
                        });
                      },
                      selectedColor: AppColors.primaryLight,
                      checkmarkColor: AppColors.primary,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'メモ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: '今日の様子や気になることがあれば記入してください',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addMeal() {
    // 簡易的な追加実装
    showDialog(
      context: context,
      builder: (context) => _MealAddDialog(
        onAdd: (meal) {
          setState(() {
            _meals.add(meal);
          });
        },
      ),
    );
  }

  void _addMedication() {
    // 簡易的な追加実装
    showDialog(
      context: context,
      builder: (context) => _MedicationAddDialog(
        onAdd: (medication) {
          setState(() {
            _medications.add(medication);
          });
        },
      ),
    );
  }

  void _addExcretion() {
    // 簡易的な追加実装
    showDialog(
      context: context,
      builder: (context) => _ExcretionAddDialog(
        onAdd: (excretion) {
          setState(() {
            _excretions.add(excretion);
          });
        },
      ),
    );
  }

  void _removeMeal(int index) {
    setState(() {
      _meals.removeAt(index);
    });
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  void _removeExcretion(int index) {
    setState(() {
      _excretions.removeAt(index);
    });
  }

  void _saveRecord() async {
    try {
      final healthStatus = HealthStatus(
        temperature: double.tryParse(_temperatureController.text) ?? 38.5,
        weight: double.tryParse(_weightController.text) ?? widget.pet.weight,
        activityLevel: _activityLevel,
        symptoms: _selectedSymptoms,
      );

      final record = DailyRecord(
        id: widget.existingRecord?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        petId: widget.pet.id,
        date: widget.date,
        meals: _meals,
        medications: _medications,
        excretions: _excretions,
        healthStatus: healthStatus,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdAt: widget.existingRecord?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final notifier = ref.read(dailyRecordNotifierProvider.notifier);
      
      if (widget.existingRecord != null) {
        await notifier.updateRecord(record);
      } else {
        await notifier.createRecord(record);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('記録を保存しました'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存に失敗しました: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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

// 簡易的なダイアログ実装
class _MealAddDialog extends StatefulWidget {
  final Function(MealRecord) onAdd;

  const _MealAddDialog({required this.onAdd});

  @override
  State<_MealAddDialog> createState() => _MealAddDialogState();
}

class _MealAddDialogState extends State<_MealAddDialog> {
  final _foodTypeController = TextEditingController(text: 'ドライフード');
  final _amountController = TextEditingController(text: '50');
  int _appetiteLevel = 5;
  TimeOfDay _time = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('食事記録を追加'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _foodTypeController,
            decoration: const InputDecoration(labelText: '食事の種類'),
          ),
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: '量 (g)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('食欲レベル: '),
              ...List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _appetiteLevel = index + 1),
                  child: Icon(
                    index < _appetiteLevel ? Icons.star : Icons.star_border,
                    color: AppColors.warning,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('時間: '),
              TextButton(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _time,
                  );
                  if (time != null) {
                    setState(() => _time = time);
                  }
                },
                child: Text('${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            final meal = MealRecord(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              time: DateTime.now().copyWith(hour: _time.hour, minute: _time.minute),
              foodType: _foodTypeController.text,
              amount: double.tryParse(_amountController.text) ?? 0,
              appetiteLevel: _appetiteLevel,
            );
            widget.onAdd(meal);
            Navigator.of(context).pop();
          },
          child: const Text('追加'),
        ),
      ],
    );
  }
}

class _MedicationAddDialog extends StatefulWidget {
  final Function(MedicationRecord) onAdd;

  const _MedicationAddDialog({required this.onAdd});

  @override
  State<_MedicationAddDialog> createState() => _MedicationAddDialogState();
}

class _MedicationAddDialogState extends State<_MedicationAddDialog> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController(text: '1.0');
  final _methodController = TextEditingController(text: '経口');
  TimeOfDay _time = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('投薬記録を追加'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '薬品名'),
          ),
          TextFormField(
            controller: _dosageController,
            decoration: const InputDecoration(labelText: '投与量'),
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            controller: _methodController,
            decoration: const InputDecoration(labelText: '投与方法'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('時間: '),
              TextButton(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _time,
                  );
                  if (time != null) {
                    setState(() => _time = time);
                  }
                },
                child: Text('${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            final medication = MedicationRecord(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              medicationName: _nameController.text,
              time: DateTime.now().copyWith(hour: _time.hour, minute: _time.minute),
              dosage: double.tryParse(_dosageController.text) ?? 1.0,
              administrationMethod: _methodController.text,
              hasSideEffects: false,
            );
            widget.onAdd(medication);
            Navigator.of(context).pop();
          },
          child: const Text('追加'),
        ),
      ],
    );
  }
}

class _ExcretionAddDialog extends StatefulWidget {
  final Function(ExcretionRecord) onAdd;

  const _ExcretionAddDialog({required this.onAdd});

  @override
  State<_ExcretionAddDialog> createState() => _ExcretionAddDialogState();
}

class _ExcretionAddDialogState extends State<_ExcretionAddDialog> {
  ExcretionType _type = ExcretionType.stool;
  StoolCondition _condition = StoolCondition.normal;
  TimeOfDay _time = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('排泄記録を追加'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<ExcretionType>(
            value: _type,
            decoration: const InputDecoration(labelText: '種類'),
            items: ExcretionType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type == ExcretionType.stool ? '便' : '尿'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _type = value!),
          ),
          DropdownButtonFormField<StoolCondition>(
            value: _condition,
            decoration: const InputDecoration(labelText: '状態'),
            items: StoolCondition.values.map((condition) {
              return DropdownMenuItem(
                value: condition,
                child: Text(_getConditionText(condition)),
              );
            }).toList(),
            onChanged: (value) => setState(() => _condition = value!),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('時間: '),
              TextButton(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _time,
                  );
                  if (time != null) {
                    setState(() => _time = time);
                  }
                },
                child: Text('${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            final excretion = ExcretionRecord(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              time: DateTime.now().copyWith(hour: _time.hour, minute: _time.minute),
              type: _type,
              condition: _condition,
              hasAbnormality: _condition != StoolCondition.normal,
            );
            widget.onAdd(excretion);
            Navigator.of(context).pop();
          },
          child: const Text('追加'),
        ),
      ],
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
}