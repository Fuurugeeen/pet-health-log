import 'package:flutter_test/flutter_test.dart';
import 'package:pet_health_log/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils Tests', () {
    group('formatDate', () {
      test('日付を正しくフォーマットする', () {
        final date = DateTime(2024, 10, 31);
        expect(AppDateUtils.formatDate(date), '2024年10月31日');
      });

      test('1桁の月日を正しくフォーマットする', () {
        final date = DateTime(2024, 1, 5);
        expect(AppDateUtils.formatDate(date), '2024年01月05日');
      });
    });

    group('formatTime', () {
      test('時刻を正しくフォーマットする', () {
        final time = DateTime(2024, 10, 31, 15, 30);
        expect(AppDateUtils.formatTime(time), '15:30');
      });

      test('0時を正しくフォーマットする', () {
        final time = DateTime(2024, 10, 31, 0, 0);
        expect(AppDateUtils.formatTime(time), '00:00');
      });
    });

    group('formatDateTime', () {
      test('日時を正しくフォーマットする', () {
        final dateTime = DateTime(2024, 10, 31, 15, 30);
        expect(AppDateUtils.formatDateTime(dateTime), '2024年10月31日 15:30');
      });
    });

    group('formatMonthYear', () {
      test('年月を正しくフォーマットする', () {
        final date = DateTime(2024, 10, 31);
        expect(AppDateUtils.formatMonthYear(date), '2024年10月');
      });
    });

    group('formatDay', () {
      test('日を正しくフォーマットする', () {
        final date = DateTime(2024, 10, 31);
        expect(AppDateUtils.formatDay(date), '31');
      });

      test('1桁の日を正しくフォーマットする', () {
        final date = DateTime(2024, 10, 5);
        expect(AppDateUtils.formatDay(date), '5');
      });
    });

    group('getRelativeTime', () {
      test('たった今を正しく表示する', () {
        final now = DateTime.now();
        expect(AppDateUtils.getRelativeTime(now), 'たった今');
      });

      test('数分前を正しく表示する', () {
        final now = DateTime.now();
        final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
        expect(AppDateUtils.getRelativeTime(fiveMinutesAgo), '5分前');
      });

      test('数時間前を正しく表示する', () {
        final now = DateTime.now();
        final threeHoursAgo = now.subtract(const Duration(hours: 3));
        expect(AppDateUtils.getRelativeTime(threeHoursAgo), '3時間前');
      });

      test('数日前を正しく表示する', () {
        final now = DateTime.now();
        final threeDaysAgo = now.subtract(const Duration(days: 3));
        expect(AppDateUtils.getRelativeTime(threeDaysAgo), '3日前');
      });

      test('7日より前は日付で表示する', () {
        final now = DateTime.now();
        final tenDaysAgo = now.subtract(const Duration(days: 10));
        final expected = AppDateUtils.formatDate(tenDaysAgo);
        expect(AppDateUtils.getRelativeTime(tenDaysAgo), expected);
      });
    });

    group('isSameDay', () {
      test('同じ日を正しく判定する', () {
        final date1 = DateTime(2024, 10, 31, 10, 0);
        final date2 = DateTime(2024, 10, 31, 15, 30);
        expect(AppDateUtils.isSameDay(date1, date2), true);
      });

      test('異なる日を正しく判定する', () {
        final date1 = DateTime(2024, 10, 31);
        final date2 = DateTime(2024, 11, 1);
        expect(AppDateUtils.isSameDay(date1, date2), false);
      });

      test('同じ時刻で異なる日を正しく判定する', () {
        final date1 = DateTime(2024, 10, 31, 10, 0);
        final date2 = DateTime(2024, 11, 1, 10, 0);
        expect(AppDateUtils.isSameDay(date1, date2), false);
      });
    });

    group('startOfDay', () {
      test('日の開始時刻を正しく取得する', () {
        final date = DateTime(2024, 10, 31, 15, 30, 45);
        final startOfDay = AppDateUtils.startOfDay(date);
        expect(startOfDay.year, 2024);
        expect(startOfDay.month, 10);
        expect(startOfDay.day, 31);
        expect(startOfDay.hour, 0);
        expect(startOfDay.minute, 0);
        expect(startOfDay.second, 0);
      });
    });

    group('endOfDay', () {
      test('日の終了時刻を正しく取得する', () {
        final date = DateTime(2024, 10, 31, 10, 30, 45);
        final endOfDay = AppDateUtils.endOfDay(date);
        expect(endOfDay.year, 2024);
        expect(endOfDay.month, 10);
        expect(endOfDay.day, 31);
        expect(endOfDay.hour, 23);
        expect(endOfDay.minute, 59);
        expect(endOfDay.second, 59);
      });
    });

    group('getAge', () {
      test('年齢を正しく計算する', () {
        final birthDate = DateTime(2020, 5, 15);
        final now = DateTime(2024, 10, 31);
        final age = AppDateUtils.getAge(birthDate);
        // この時点では4歳
        expect(age, 4);
      });

      test('誕生日前の年齢を正しく計算する', () {
        final birthDate = DateTime(2020, 12, 15);
        final now = DateTime(2024, 10, 31);
        final age = AppDateUtils.getAge(birthDate);
        // 12月生まれで10月時点では3歳
        expect(age, 3);
      });

      test('誕生日当日の年齢を正しく計算する', () {
        final today = DateTime.now();
        final birthDate = DateTime(today.year - 5, today.month, today.day);
        final age = AppDateUtils.getAge(birthDate);
        expect(age, 5);
      });
    });

    group('getAgeString', () {
      test('1歳以上を正しく表示する', () {
        final birthDate = DateTime(2020, 5, 15);
        final ageString = AppDateUtils.getAgeString(birthDate);
        expect(ageString.endsWith('歳'), true);
      });

      test('1歳未満1ヶ月以上をヶ月で表示する', () {
        final now = DateTime.now();
        final twoMonthsAgo = DateTime(now.year, now.month - 2, now.day);
        final ageString = AppDateUtils.getAgeString(twoMonthsAgo);
        expect(ageString.endsWith('ヶ月'), true);
      });

      test('1ヶ月未満を日数で表示する', () {
        final now = DateTime.now();
        final tenDaysAgo = now.subtract(const Duration(days: 10));
        final ageString = AppDateUtils.getAgeString(tenDaysAgo);
        expect(ageString.endsWith('日'), true);
      });

      test('0日を正しく表示する', () {
        final today = DateTime.now();
        final ageString = AppDateUtils.getAgeString(today);
        expect(ageString, '0日');
      });
    });
  });
}
