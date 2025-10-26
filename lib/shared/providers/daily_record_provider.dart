import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/record/data/daily_record_repository.dart';
import '../../models/daily_record.dart';

final dailyRecordRepositoryProvider = Provider<DailyRecordRepository>((ref) {
  return DailyRecordRepository();
});

// 特定のペットの記録リスト
final petRecordsProvider = FutureProvider.family<List<DailyRecord>, String>((ref, petId) async {
  final repository = ref.read(dailyRecordRepositoryProvider);
  return await repository.getRecordsByPetId(petId);
});

// 特定の日付の記録
final recordByDateProvider = FutureProvider.family<DailyRecord?, ({String petId, DateTime date})>((ref, params) async {
  final repository = ref.read(dailyRecordRepositoryProvider);
  return await repository.getRecordByDate(params.petId, params.date);
});

// 期間内の記録
final recordsByDateRangeProvider = FutureProvider.family<List<DailyRecord>, ({String petId, DateTime start, DateTime end})>((ref, params) async {
  final repository = ref.read(dailyRecordRepositoryProvider);
  return await repository.getRecordsByDateRange(params.petId, params.start, params.end);
});

// 記録統計
final recordStatisticsProvider = FutureProvider.family<Map<String, int>, String>((ref, petId) async {
  final repository = ref.read(dailyRecordRepositoryProvider);
  return await repository.getRecordStatistics(petId);
});

// 記録の作成/更新/削除用のNotifier
class DailyRecordNotifier extends StateNotifier<AsyncValue<void>> {
  final DailyRecordRepository _repository;

  DailyRecordNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createRecord(DailyRecord record) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createRecord(record);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateRecord(DailyRecord record) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateRecord(record);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteRecord(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteRecord(id);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final dailyRecordNotifierProvider = StateNotifierProvider<DailyRecordNotifier, AsyncValue<void>>((ref) {
  final repository = ref.read(dailyRecordRepositoryProvider);
  return DailyRecordNotifier(repository);
});