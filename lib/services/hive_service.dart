import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/pet.dart';
import '../models/daily_record.dart';

class HiveService {
  static const String userBoxName = 'users';
  static const String petBoxName = 'pets';
  static const String dailyRecordBoxName = 'daily_records';
  static const String shareSettingBoxName = 'share_settings';
  static const String appSettingsBoxName = 'app_settings';
  
  static Future<void> initialize() async {
    // Hiveの初期化
    await Hive.initFlutter();
    
    // モデルのアダプターを登録（重複チェック付き）
    _registerAdapterSafely(() => Hive.registerAdapter(UserAdapter()));
    _registerAdapterSafely(() => Hive.registerAdapter(UserTypeAdapter()));
    _registerAdapterSafely(() => Hive.registerAdapter(PetAdapter()));
    _registerAdapterSafely(() => Hive.registerAdapter(PetTypeAdapter()));
    _registerAdapterSafely(() => Hive.registerAdapter(GenderAdapter()));
    _registerAdapterSafely(() => Hive.registerAdapter(DailyRecordAdapter()));
    _registerAdapterSafely(() => Hive.registerAdapter(MealRecordAdapter()));
    _registerAdapterSafely(() => Hive.registerAdapter(MedicationRecordAdapter()));
    _registerAdapterSafely(() => Hive.registerAdapter(ExcretionRecordAdapter()));
    _registerAdapterSafely(() => Hive.registerAdapter(WalkRecordAdapter()));
    _registerAdapterSafely(() => Hive.registerAdapter(HealthStatusAdapter()));
    _registerAdapterSafely(() => Hive.registerAdapter(ExcretionTypeAdapter()));
    _registerAdapterSafely(() => Hive.registerAdapter(StoolConditionAdapter()));
    _registerAdapterSafely(() => Hive.registerAdapter(SymptomAdapter()));
    
    // ボックスを開く
    await openBoxes();
  }
  
  static void _registerAdapterSafely(void Function() registerFunction) {
    try {
      registerFunction();
    } catch (e) {
      // アダプターが既に登録済みの場合は無視
      // print('Adapter already registered: $e');
    }
  }
  
  static Future<void> openBoxes() async {
    await Future.wait([
      Hive.openBox<User>(userBoxName),
      Hive.openBox<Pet>(petBoxName),
      Hive.openBox<DailyRecord>(dailyRecordBoxName),
      Hive.openBox(shareSettingBoxName),
      Hive.openBox(appSettingsBoxName),
    ]);
  }
  
  static Box<T> getBox<T>(String boxName) {
    return Hive.box<T>(boxName);
  }
  
  static Box<User> getUserBox() => getBox<User>(userBoxName);
  static Box<Pet> getPetBox() => getBox<Pet>(petBoxName);
  static Box<DailyRecord> getDailyRecordBox() => getBox<DailyRecord>(dailyRecordBoxName);
  static Box getShareSettingBox() => getBox(shareSettingBoxName);
  static Box getAppSettingsBox() => getBox(appSettingsBoxName);
  
  static Future<void> clearAllData() async {
    await Future.wait([
      getUserBox().clear(),
      getPetBox().clear(),
      getDailyRecordBox().clear(),
      getShareSettingBox().clear(),
      // アプリ設定は保持
    ]);
  }
  
  static Future<void> closeBoxes() async {
    await Hive.close();
  }
}