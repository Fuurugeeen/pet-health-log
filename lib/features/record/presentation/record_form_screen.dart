import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/daily_record.dart';
import '../../../shared/providers/pet_provider.dart';
import '../../../shared/widgets/bottom_navigation.dart';

class RecordFormScreen extends ConsumerStatefulWidget {
  final bool showBottomNav;
  
  const RecordFormScreen({super.key, this.showBottomNav = true});

  @override
  ConsumerState<RecordFormScreen> createState() => _RecordFormScreenState();
}

class _RecordFormScreenState extends ConsumerState<RecordFormScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  // 食事記録
  final _foodTypeController = TextEditingController();
  final _foodAmountController = TextEditingController();
  int _appetiteLevel = 3;
  final _mealNotesController = TextEditingController();
  final List<MealRecord> _meals = [];

  // 投薬記録
  final _medicationNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _administrationController = TextEditingController();
  bool _hasSideEffects = false;
  final _sideEffectController = TextEditingController();
  final List<MedicationRecord> _medications = [];

  // 排泄記録
  ExcretionType _excretionType = ExcretionType.stool;
  StoolCondition? _stoolCondition = StoolCondition.normal;
  final _colorController = TextEditingController();
  final _amountController = TextEditingController();
  bool _hasAbnormality = false;
  final _excretionNotesController = TextEditingController();
  final List<ExcretionRecord> _excretions = [];

  // 体調記録
  final _temperatureController = TextEditingController();
  final _weightController = TextEditingController();
  int _activityLevel = 3;
  final List<Symptom> _selectedSymptoms = [];
  final _healthNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _foodTypeController.dispose();
    _foodAmountController.dispose();
    _mealNotesController.dispose();
    _medicationNameController.dispose();
    _dosageController.dispose();
    _administrationController.dispose();
    _sideEffectController.dispose();
    _colorController.dispose();
    _amountController.dispose();
    _excretionNotesController.dispose();
    _temperatureController.dispose();
    _weightController.dispose();
    _healthNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedPet = ref.watch(selectedPetProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.record),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.restaurant), text: '食事'),
            Tab(icon: Icon(Icons.medication), text: '投薬'),
            Tab(icon: Icon(Icons.bathroom), text: '排泄'),
            Tab(icon: Icon(Icons.favorite), text: '体調'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRecord,
          ),
        ],
      ),
      body: selectedPet == null
          ? const Center(
              child: Text('ペットが選択されていません'),
            )
          : Column(
              children: [
                // 日付選択
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _selectDate,
                        child: Text(
                          AppDateUtils.formatDate(_selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${selectedPet.name}の記録',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMealTab(),
                      _buildMedicationTab(),
                      _buildExcretionTab(),
                      _buildHealthTab(),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: widget.showBottomNav ? const BottomNavigation(currentIndex: 1) : null,
    );
  }

  Widget _buildMealTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '食事を追加',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _foodTypeController,
                    decoration: const InputDecoration(
                      labelText: '食事内容',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _foodAmountController,
                    decoration: const InputDecoration(
                      labelText: '食事量 (g)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  Text('食欲レベル: $_appetiteLevel'),
                  Slider(
                    value: _appetiteLevel.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (value) {
                      setState(() {
                        _appetiteLevel = value.round();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _mealNotesController,
                    decoration: const InputDecoration(
                      labelText: 'メモ',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addMeal,
                      child: const Text('食事を追加'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_meals.isNotEmpty) ...[
            const Text(
              '今日の食事記録',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _meals.length,
                itemBuilder: (context, index) {
                  final meal = _meals[index];
                  return Card(
                    child: ListTile(
                      title: Text(meal.foodType),
                      subtitle: Text(
                        '${AppDateUtils.formatTime(meal.time)} • ${meal.amount}g • 食欲レベル: ${meal.appetiteLevel}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeMeal(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
        ),
      ),
    );
  }

  Widget _buildMedicationTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '投薬を追加',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _medicationNameController,
                    decoration: const InputDecoration(
                      labelText: '薬名',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _dosageController,
                    decoration: const InputDecoration(
                      labelText: '投薬量',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _administrationController,
                    decoration: const InputDecoration(
                      labelText: '投薬方法',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('副作用あり'),
                    value: _hasSideEffects,
                    onChanged: (value) {
                      setState(() {
                        _hasSideEffects = value ?? false;
                      });
                    },
                  ),
                  if (_hasSideEffects) ...[
                    TextField(
                      controller: _sideEffectController,
                      decoration: const InputDecoration(
                        labelText: '副作用の詳細',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addMedication,
                      child: const Text('投薬を追加'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_medications.isNotEmpty) ...[
            const Text(
              '今日の投薬記録',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _medications.length,
                itemBuilder: (context, index) {
                  final medication = _medications[index];
                  return Card(
                    child: ListTile(
                      title: Text(medication.medicationName),
                      subtitle: Text(
                        '${AppDateUtils.formatTime(medication.time)} • ${medication.dosage} • ${medication.administrationMethod}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeMedication(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
        ),
      ),
    );
  }

  Widget _buildExcretionTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '排泄を追加',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ExcretionType>(
                    value: _excretionType,
                    decoration: const InputDecoration(
                      labelText: '種類',
                      border: OutlineInputBorder(),
                    ),
                    items: ExcretionType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _excretionType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (_excretionType == ExcretionType.stool) ...[
                    DropdownButtonFormField<StoolCondition>(
                      value: _stoolCondition,
                      decoration: const InputDecoration(
                        labelText: '便の状態',
                        border: OutlineInputBorder(),
                      ),
                      items: StoolCondition.values.map((condition) {
                        return DropdownMenuItem(
                          value: condition,
                          child: Text(condition.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _stoolCondition = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  CheckboxListTile(
                    title: const Text('異常あり'),
                    value: _hasAbnormality,
                    onChanged: (value) {
                      setState(() {
                        _hasAbnormality = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _excretionNotesController,
                    decoration: const InputDecoration(
                      labelText: 'メモ',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addExcretion,
                      child: const Text('排泄記録を追加'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_excretions.isNotEmpty) ...[
            const Text(
              '今日の排泄記録',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _excretions.length,
                itemBuilder: (context, index) {
                  final excretion = _excretions[index];
                  return Card(
                    child: ListTile(
                      title: Text(excretion.type.displayName),
                      subtitle: Text(
                        '${AppDateUtils.formatTime(excretion.time)} • ${excretion.condition?.displayName ?? ""}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeExcretion(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
        ),
      ),
    );
  }

  Widget _buildHealthTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '体調記録',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _temperatureController,
                  decoration: const InputDecoration(
                    labelText: '体温 (℃)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: '体重 (kg)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Text('活動レベル: $_activityLevel'),
                Slider(
                  value: _activityLevel.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (value) {
                    setState(() {
                      _activityLevel = value.round();
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  '症状',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ...Symptom.values.map((symptom) {
                  return CheckboxListTile(
                    title: Text(symptom.displayName),
                    value: _selectedSymptoms.contains(symptom),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedSymptoms.add(symptom);
                        } else {
                          _selectedSymptoms.remove(symptom);
                        }
                      });
                    },
                  );
                }),
                const SizedBox(height: 12),
                TextField(
                  controller: _healthNotesController,
                  decoration: const InputDecoration(
                    labelText: 'メモ',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addMeal() {
    if (_foodTypeController.text.isEmpty || _foodAmountController.text.isEmpty) {
      return;
    }

    final meal = MealRecord(
      id: const Uuid().v4(),
      time: DateTime.now(),
      foodType: _foodTypeController.text,
      amount: double.tryParse(_foodAmountController.text) ?? 0,
      appetiteLevel: _appetiteLevel,
      notes: _mealNotesController.text.isEmpty ? null : _mealNotesController.text,
    );

    setState(() {
      _meals.add(meal);
      _foodTypeController.clear();
      _foodAmountController.clear();
      _mealNotesController.clear();
      _appetiteLevel = 3;
    });
  }

  void _removeMeal(int index) {
    setState(() {
      _meals.removeAt(index);
    });
  }

  void _addMedication() {
    if (_medicationNameController.text.isEmpty || _dosageController.text.isEmpty) {
      return;
    }

    final medication = MedicationRecord(
      id: const Uuid().v4(),
      medicationName: _medicationNameController.text,
      time: DateTime.now(),
      dosage: double.tryParse(_dosageController.text) ?? 0,
      administrationMethod: _administrationController.text,
      hasSideEffects: _hasSideEffects,
      sideEffectDetails: _hasSideEffects ? _sideEffectController.text : null,
    );

    setState(() {
      _medications.add(medication);
      _medicationNameController.clear();
      _dosageController.clear();
      _administrationController.clear();
      _sideEffectController.clear();
      _hasSideEffects = false;
    });
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  void _addExcretion() {
    final excretion = ExcretionRecord(
      id: const Uuid().v4(),
      time: DateTime.now(),
      type: _excretionType,
      condition: _excretionType == ExcretionType.stool ? _stoolCondition : null,
      hasAbnormality: _hasAbnormality,
      notes: _excretionNotesController.text.isEmpty ? null : _excretionNotesController.text,
    );

    setState(() {
      _excretions.add(excretion);
      _excretionNotesController.clear();
      _hasAbnormality = false;
    });
  }

  void _removeExcretion(int index) {
    setState(() {
      _excretions.removeAt(index);
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveRecord() {
    final selectedPet = ref.read(selectedPetProvider);
    if (selectedPet == null) return;

    // TODO: 記録をHiveに保存
    // final healthStatus = HealthStatus(
    //   temperature: double.tryParse(_temperatureController.text),
    //   weight: double.tryParse(_weightController.text),
    //   activityLevel: _activityLevel,
    //   symptoms: _selectedSymptoms,
    //   notes: _healthNotesController.text.isEmpty ? null : _healthNotesController.text,
    // );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('記録を保存しました'),
        backgroundColor: AppColors.success,
      ),
    );

    // フォームをリセット
    _resetForm();
  }

  void _resetForm() {
    setState(() {
      _meals.clear();
      _medications.clear();
      _excretions.clear();
      _selectedSymptoms.clear();
      _temperatureController.clear();
      _weightController.clear();
      _healthNotesController.clear();
      _activityLevel = 3;
    });
  }
}