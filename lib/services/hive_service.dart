import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';

class HiveService {
  static const String userBoxName = 'users';
  static const String petBoxName = 'pets';
  static const String dailyRecordBoxName = 'daily_records';
  static const String shareSettingBoxName = 'share_settings';
  static const String appSettingsBoxName = 'app_settings';
  
  static Future<void> initialize() async {
    // Hiveの初期化
    await Hive.initFlutter();
    
    // モデルのアダプターを登録
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(UserTypeAdapter());
    
    // ボックスを開く
    await openBoxes();
  }
  
  static Future<void> openBoxes() async {
    await Future.wait([
      Hive.openBox(userBoxName),
      Hive.openBox(petBoxName),
      Hive.openBox(dailyRecordBoxName),
      Hive.openBox(shareSettingBoxName),
      Hive.openBox(appSettingsBoxName),
    ]);
  }
  
  static Box<T> getBox<T>(String boxName) {
    return Hive.box<T>(boxName);
  }
  
  static Box getUserBox() => getBox(userBoxName);
  static Box getPetBox() => getBox(petBoxName);
  static Box getDailyRecordBox() => getBox(dailyRecordBoxName);
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