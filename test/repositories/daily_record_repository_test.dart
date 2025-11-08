import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:pet_health_log/features/record/data/daily_record_repository.dart';
import 'package:pet_health_log/models/daily_record.dart';
import 'package:pet_health_log/services/hive_service.dart';
import '../helpers/hive_test_helper.dart';
import '../fixtures/mock_data.dart';

void main() {
  group('DailyRecordRepository Tests', () {
    late DailyRecordRepository repository;
    late Box<DailyRecord> recordBox;

    setUp(() async {
      await HiveTestHelper.initializeHive();
      recordBox = await HiveTestHelper.openBox<DailyRecord>(
        HiveService.dailyRecordBoxName,
      );
      repository = DailyRecordRepository();
    });

    tearDown(() async {
      await HiveTestHelper.tearDown();
    });

    group('createRecord', () {
      test('記録を作成できる', () async {
        await repository.createRecord(MockData.testDailyRecord1);

        expect(recordBox.containsKey(MockData.testDailyRecord1.id), true);
        final saved = recordBox.get(MockData.testDailyRecord1.id);
        expect(saved!.petId, MockData.testDailyRecord1.petId);
      });

      test('複数の記録を作成できる', () async {
        await repository.createRecord(MockData.testDailyRecord1);
        await repository.createRecord(MockData.testDailyRecord2);

        expect(recordBox.length, 2);
      });
    });

    group('updateRecord', () {
      test('記録を更新できる', () async {
        await recordBox.put(
          MockData.testDailyRecord1.id,
          MockData.testDailyRecord1,
        );

        final updated = MockData.testDailyRecord1.copyWith(
          notes: '更新されたメモ',
        );
        await repository.updateRecord(updated);

        final saved = recordBox.get(MockData.testDailyRecord1.id);
        expect(saved!.notes, '更新されたメモ');
      });
    });

    group('deleteRecord', () {
      test('記録を削除できる', () async {
        await recordBox.put(
          MockData.testDailyRecord1.id,
          MockData.testDailyRecord1,
        );

        await repository.deleteRecord(MockData.testDailyRecord1.id);

        expect(recordBox.containsKey(MockData.testDailyRecord1.id), false);
      });

      test('存在しない記録を削除してもエラーにならない', () async {
        await repository.deleteRecord('non_existent_id');
        // テスト成功
      });
    });

    group('getRecordsByPetId', () {
      test('特定のペットの記録を取得できる', () async {
        await recordBox.put(
          MockData.testDailyRecord1.id,
          MockData.testDailyRecord1,
        );
        await recordBox.put(
          MockData.testDailyRecord2.id,
          MockData.testDailyRecord2,
        );
        await recordBox.put(
          MockData.testDailyRecord3.id,
          MockData.testDailyRecord3,
        );

        final records = await repository.getRecordsByPetId('pet1');

        expect(records.length, 2);
        expect(records.every((r) => r.petId == 'pet1'), true);
      });

      test('記録は日付の降順でソートされる', () async {
        final oldRecord = MockData.testDailyRecord2; // 10月30日
        final newRecord = MockData.testDailyRecord1; // 10月31日

        await recordBox.put(oldRecord.id, oldRecord);
        await recordBox.put(newRecord.id, newRecord);

        final records = await repository.getRecordsByPetId('pet1');

        expect(records.first.date.isAfter(records.last.date), true);
        expect(records.first.id, newRecord.id);
      });

      test('該当する記録がない場合は空リストを返す', () async {
        final records = await repository.getRecordsByPetId('pet1');

        expect(records, isEmpty);
      });
    });

    group('getRecordByDate', () {
      test('特定の日付の記録を取得できる', () async {
        await recordBox.put(
          MockData.testDailyRecord1.id,
          MockData.testDailyRecord1,
        );

        final record = await repository.getRecordByDate(
          'pet1',
          DateTime(2024, 10, 31),
        );

        expect(record, isNotNull);
        expect(record!.id, MockData.testDailyRecord1.id);
      });

      test('時刻が異なっても同じ日付なら取得できる', () async {
        await recordBox.put(
          MockData.testDailyRecord1.id,
          MockData.testDailyRecord1,
        );

        final record = await repository.getRecordByDate(
          'pet1',
          DateTime(2024, 10, 31, 23, 59, 59),
        );

        expect(record, isNotNull);
        expect(record!.id, MockData.testDailyRecord1.id);
      });

      test('該当する記録がない場合はnullを返す', () async {
        final record = await repository.getRecordByDate(
          'pet1',
          DateTime(2024, 11, 1),
        );

        expect(record, null);
      });

      test('同じ日付でも別のペットの記録は取得しない', () async {
        await recordBox.put(
          MockData.testDailyRecord1.id,
          MockData.testDailyRecord1, // pet1, 10/31
        );
        await recordBox.put(
          MockData.testDailyRecord3.id,
          MockData.testDailyRecord3, // pet2, 10/31
        );

        final record = await repository.getRecordByDate(
          'pet2',
          DateTime(2024, 10, 31),
        );

        expect(record, isNotNull);
        expect(record!.id, MockData.testDailyRecord3.id);
        expect(record.petId, 'pet2');
      });
    });

    group('getRecordsByDateRange', () {
      test('期間内の記録を取得できる', () async {
        final record1 = MockData.testDailyRecord1.copyWith(
          date: DateTime(2024, 10, 31),
        );
        final record2 = MockData.testDailyRecord2.copyWith(
          date: DateTime(2024, 10, 30),
        );
        final record3 = MockData.testDailyRecord1.copyWith(
          id: 'record4',
          date: DateTime(2024, 10, 29),
        );

        await recordBox.put(record1.id, record1);
        await recordBox.put(record2.id, record2);
        await recordBox.put(record3.id, record3);

        final records = await repository.getRecordsByDateRange(
          'pet1',
          DateTime(2024, 10, 29),
          DateTime(2024, 10, 31),
        );

        expect(records.length, 3);
      });

      test('記録は日付の昇順でソートされる', () async {
        final record1 = MockData.testDailyRecord1.copyWith(
          date: DateTime(2024, 10, 31),
        );
        final record2 = MockData.testDailyRecord2.copyWith(
          date: DateTime(2024, 10, 29),
        );

        await recordBox.put(record1.id, record1);
        await recordBox.put(record2.id, record2);

        final records = await repository.getRecordsByDateRange(
          'pet1',
          DateTime(2024, 10, 29),
          DateTime(2024, 10, 31),
        );

        expect(records.first.date.isBefore(records.last.date), true);
      });

      test('期間外の記録は含まれない', () async {
        final inRange = MockData.testDailyRecord1.copyWith(
          date: DateTime(2024, 10, 31),
        );
        final outOfRange = MockData.testDailyRecord2.copyWith(
          date: DateTime(2024, 9, 1),
        );

        await recordBox.put(inRange.id, inRange);
        await recordBox.put(outOfRange.id, outOfRange);

        final records = await repository.getRecordsByDateRange(
          'pet1',
          DateTime(2024, 10, 1),
          DateTime(2024, 10, 31),
        );

        expect(records.length, 1);
        expect(records.first.id, inRange.id);
      });

      test('該当する記録がない場合は空リストを返す', () async {
        final records = await repository.getRecordsByDateRange(
          'pet1',
          DateTime(2024, 11, 1),
          DateTime(2024, 11, 30),
        );

        expect(records, isEmpty);
      });
    });

    group('hasRecordForDate', () {
      test('記録が存在する場合はtrueを返す', () async {
        await recordBox.put(
          MockData.testDailyRecord1.id,
          MockData.testDailyRecord1,
        );

        final has = await repository.hasRecordForDate(
          'pet1',
          DateTime(2024, 10, 31),
        );

        expect(has, true);
      });

      test('記録が存在しない場合はfalseを返す', () async {
        final has = await repository.hasRecordForDate(
          'pet1',
          DateTime(2024, 11, 1),
        );

        expect(has, false);
      });
    });

    group('getAllRecords', () {
      test('すべての記録を取得できる', () async {
        await recordBox.put(
          MockData.testDailyRecord1.id,
          MockData.testDailyRecord1,
        );
        await recordBox.put(
          MockData.testDailyRecord2.id,
          MockData.testDailyRecord2,
        );
        await recordBox.put(
          MockData.testDailyRecord3.id,
          MockData.testDailyRecord3,
        );

        final records = await repository.getAllRecords();

        expect(records.length, 3);
      });

      test('記録は日付の降順でソートされる', () async {
        final old = MockData.testDailyRecord2; // 10月30日
        final new1 = MockData.testDailyRecord1; // 10月31日

        await recordBox.put(old.id, old);
        await recordBox.put(new1.id, new1);

        final records = await repository.getAllRecords();

        expect(records.first.date.isAfter(records.last.date), true);
      });

      test('記録がない場合は空リストを返す', () async {
        final records = await repository.getAllRecords();

        expect(records, isEmpty);
      });
    });

    group('getRecordStatistics', () {
      test('統計情報を正しく計算できる', () async {
        await recordBox.put(
          MockData.testDailyRecord1.id,
          MockData.testDailyRecord1,
        );
        await recordBox.put(
          MockData.testDailyRecord2.id,
          MockData.testDailyRecord2,
        );

        final stats = await repository.getRecordStatistics('pet1');

        expect(stats['totalRecords'], 2);
        expect(stats['totalMeals'], 3); // record1: 2食, record2: 1食
        expect(stats['totalMedications'], 1); // record2のみ
        expect(stats['totalExcretions'], 3); // record1: 2回, record2: 1回
        expect(stats['daysWithSymptoms'], 1); // record2のみ
      });

      test('記録がない場合は全て0を返す', () async {
        final stats = await repository.getRecordStatistics('pet1');

        expect(stats['totalRecords'], 0);
        expect(stats['totalMeals'], 0);
        expect(stats['totalMedications'], 0);
        expect(stats['totalExcretions'], 0);
        expect(stats['daysWithSymptoms'], 0);
      });

      test('症状のない日はカウントしない', () async {
        final noSymptoms = MockData.testDailyRecord1.copyWith(
          healthStatus: HealthStatus(
            activityLevel: 5,
            symptoms: [], // 症状なし
          ),
        );

        await recordBox.put(noSymptoms.id, noSymptoms);

        final stats = await repository.getRecordStatistics('pet1');

        expect(stats['daysWithSymptoms'], 0);
      });

      test('健康状態がnullの日もカウントしない', () async {
        final noHealth = MockData.testDailyRecord1.copyWith(
          healthStatus: null,
        );

        await recordBox.put(noHealth.id, noHealth);

        final stats = await repository.getRecordStatistics('pet1');

        expect(stats['daysWithSymptoms'], 0);
      });
    });
  });
}
