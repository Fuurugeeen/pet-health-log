import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/daily_record.dart';
import '../../../services/hive_service.dart';

class DailyRecordRepository {
  Box<DailyRecord> get _box => HiveService.getDailyRecordBox();

  // 記録を作成
  Future<void> createRecord(DailyRecord record) async {
    await _box.put(record.id, record);
  }

  // 記録を更新
  Future<void> updateRecord(DailyRecord record) async {
    await _box.put(record.id, record);
  }

  // 記録を削除
  Future<void> deleteRecord(String id) async {
    await _box.delete(id);
  }

  // 特定のペットの記録を取得
  Future<List<DailyRecord>> getRecordsByPetId(String petId) async {
    return _box.values
        .where((record) => record.petId == petId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // 特定の日付の記録を取得
  Future<DailyRecord?> getRecordByDate(String petId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    for (final record in _box.values) {
      if (record.petId == petId) {
        final recordDate = DateTime(
          record.date.year,
          record.date.month,
          record.date.day,
        );
        if (recordDate.isAtSameMomentAs(dateOnly)) {
          return record;
        }
      }
    }
    return null;
  }

  // 期間内の記録を取得
  Future<List<DailyRecord>> getRecordsByDateRange(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Boxが開いているかチェック
    if (!_box.isOpen) {
      throw StateError('DailyRecord box is not open');
    }

    final allRecords = _box.values.toList();

    final filteredRecords = allRecords
        .where((record) =>
            record.petId == petId &&
            record.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            record.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return filteredRecords;
  }

  // 記録があるかチェック
  Future<bool> hasRecordForDate(String petId, DateTime date) async {
    final record = await getRecordByDate(petId, date);
    return record != null;
  }

  // 全ての記録を取得
  Future<List<DailyRecord>> getAllRecords() async {
    return _box.values
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // 記録の統計情報を取得
  Future<Map<String, int>> getRecordStatistics(String petId) async {
    final records = await getRecordsByPetId(petId);
    
    int totalMeals = 0;
    int totalMedications = 0;
    int totalExcretions = 0;
    int daysWithSymptoms = 0;

    for (final record in records) {
      totalMeals += record.meals.length;
      totalMedications += record.medications.length;
      totalExcretions += record.excretions.length;
      if (record.healthStatus?.symptoms.isNotEmpty == true) {
        daysWithSymptoms++;
      }
    }

    return {
      'totalRecords': records.length,
      'totalMeals': totalMeals,
      'totalMedications': totalMedications,
      'totalExcretions': totalExcretions,
      'daysWithSymptoms': daysWithSymptoms,
    };
  }
}