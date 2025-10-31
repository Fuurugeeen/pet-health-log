import 'package:hive/hive.dart';
import 'package:pet_health_log/models/user.dart';
import 'package:pet_health_log/models/pet.dart';
import 'package:pet_health_log/models/daily_record.dart';

/// Hiveテスト用のヘルパークラス
class HiveTestHelper {
  static bool _isInitialized = false;

  /// テスト用のHiveを初期化する
  static Future<void> initializeHive() async {
    if (_isInitialized) return;

    // テスト用にメモリストレージを使用
    Hive.init(null);

    // アダプターを登録
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(PetAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(PetTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(GenderAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(DailyRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(MealRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(MedicationRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(ExcretionRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(HealthStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(ExcretionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(StoolConditionAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(SymptomAdapter());
    }
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(WalkRecordAdapter());
    }

    _isInitialized = true;
  }

  /// テスト用のボックスを開く
  static Future<Box<T>> openBox<T>(String boxName) async {
    await initializeHive();

    // 既に開いている場合は閉じる
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<T>(boxName).clear();
      return Hive.box<T>(boxName);
    }

    return await Hive.openBox<T>(boxName);
  }

  /// すべてのボックスをクリアして閉じる
  static Future<void> closeAllBoxes() async {
    for (var box in Hive.box.values) {
      if (box.isOpen) {
        await box.clear();
        await box.close();
      }
    }
  }

  /// 特定のボックスをクリアして閉じる
  static Future<void> closeBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      final box = Hive.box(boxName);
      await box.clear();
      await box.close();
    }
  }

  /// テスト終了時のクリーンアップ
  static Future<void> tearDown() async {
    await closeAllBoxes();
  }
}
