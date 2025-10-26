# ペットヘルスログ - 技術仕様書（モック版）

## 1. 技術スタック

### 1.1 フロントエンド（モック版）
- **フレームワーク**: Flutter Web 3.x
- **状態管理**: Riverpod 2.x
- **ルーティング**: go_router
- **UIコンポーネント**: Material Design 3
- **ローカルストレージ**: hive_flutter（構造化データ用）/ shared_preferences（設定用）
- **画像処理**: image_picker (Web対応) + base64エンコーディング
- **デバイスプレビュー**: device_preview（開発環境用）
- **モックデータ**: faker（テストデータ生成用）

### 1.2 データ永続化（モック版）
- **Hive**：主要データ（ユーザー、ペット、記録）の保存
- **SharedPreferences**：アプリ設定、ユーザー設定の保存
- **IndexedDB**（Web）：ブラウザのローカルストレージとして使用

### 1.3 バックエンド（将来実装予定）
- 現在のモック版ではAPIは使用しない
- 将来的にFirebase/カスタムAPIへの移行を想定した設計

### 1.4 インフラ（モック版）
- **ホスティング**: GitHub Pages（静的ホスティング）
- **CI/CD**: GitHub Actions
- **監視**: Google Analytics（基本的なアクセス解析）

## 2. アーキテクチャ

### 2.1 全体構成（モック版）
```
┌─────────────────┐
│  Flutter Web    │
│   (Frontend)    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Local Storage   │
│  (Hive/Prefs)   │
└─────────────────┘
```

将来的な構成：
```
┌─────────────────┐     ┌─────────────────┐
│  Flutter Web    │────▶│    REST API     │
│   (Frontend)    │◀────│   (Backend)     │
└─────────────────┘     └─────────────────┘
```

### 2.2 フロントエンドアーキテクチャ
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── themes/
│   ├── utils/
│   └── errors/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── pet/
│   ├── record/
│   ├── report/
│   └── share/
├── shared/
│   ├── widgets/
│   └── providers/
└── l10n/
```

### 2.3 状態管理パターン
- **Riverpod** を使用したProvider Pattern
- **Repository Pattern** for data layer
- **UseCase Pattern** for business logic

## 3. データモデル

### 3.1 ユーザー (User)
```dart
class User {
  final String id;
  final String email;
  final String displayName;
  final UserType type; // owner, veterinarian, shop_staff
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 3.2 ペット (Pet)
```dart
class Pet {
  final String id;
  final String ownerId;
  final String name;
  final PetType type; // dog, cat, other
  final String breed;
  final DateTime birthDate;
  final Gender gender;
  final double weight;
  final String? photoUrl;
  final List<String> medicalHistory;
  final List<String> allergies;
  final Map<String, dynamic> metadata;
}
```

### 3.3 日誌記録 (DailyRecord)
```dart
class DailyRecord {
  final String id;
  final String petId;
  final DateTime date;
  final List<MealRecord> meals;
  final List<MedicationRecord> medications;
  final List<ExcretionRecord> excretions;
  final HealthStatus healthStatus;
  final String? notes;
  final List<String> photoUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 3.4 食事記録 (MealRecord)
```dart
class MealRecord {
  final String id;
  final DateTime time;
  final String foodType;
  final double amount;
  final int appetiteLevel; // 1-5
  final String? notes;
}
```

### 3.5 投薬記録 (MedicationRecord)
```dart
class MedicationRecord {
  final String id;
  final String medicationName;
  final DateTime time;
  final double dosage;
  final String administrationMethod;
  final bool hasSideEffects;
  final String? sideEffectDetails;
}
```

### 3.6 排泄記録 (ExcretionRecord)
```dart
class ExcretionRecord {
  final String id;
  final DateTime time;
  final ExcretionType type; // urine, stool
  final StoolCondition? condition; // normal, soft, hard, diarrhea
  final String? color;
  final String? amount;
  final bool hasAbnormality;
  final String? notes;
}
```

### 3.7 健康状態 (HealthStatus)
```dart
class HealthStatus {
  final double? temperature;
  final double? weight;
  final int activityLevel; // 1-5
  final List<Symptom> symptoms;
  final String? notes;
}
```

## 4. データアクセス層（モック版）

### 4.1 ローカルストレージ設計
モック版では全てのデータをローカルストレージに保存します。

#### Hiveボックス構成
```dart
// ユーザーデータ
await Hive.openBox<User>('users');

// ペットデータ
await Hive.openBox<Pet>('pets');

// 記録データ
await Hive.openBox<DailyRecord>('daily_records');

// 共有設定
await Hive.openBox<ShareSetting>('share_settings');
```

### 4.2 Repository実装（モック版）
```dart
abstract class PetRepository {
  Future<List<Pet>> getPets();
  Future<Pet?> getPet(String id);
  Future<Pet> createPet(Pet pet);
  Future<Pet> updatePet(Pet pet);
  Future<void> deletePet(String id);
}

class LocalPetRepository implements PetRepository {
  final Box<Pet> _petBox;
  
  LocalPetRepository(this._petBox);
  
  @override
  Future<List<Pet>> getPets() async {
    return _petBox.values.toList();
  }
  
  // 他のメソッドも同様にローカル実装
}
```

### 4.3 モックデータ生成
初回起動時にサンプルデータを自動生成：
```dart
class MockDataGenerator {
  static Future<void> generateSampleData() async {
    // サンプルペットを生成
    final samplePet = Pet(
      id: Uuid().v4(),
      name: 'ポチ',
      type: PetType.dog,
      breed: '柴犬',
      birthDate: DateTime.now().subtract(Duration(days: 365 * 3)),
      // ...
    );
    
    // 過去30日分の記録を生成
    for (int i = 0; i < 30; i++) {
      final record = DailyRecord(
        // ...
      );
    }
  }
}
```

### 4.4 将来のAPI移行準備
Repository Patternを採用することで、将来的にAPI実装への切り替えが容易：
```dart
// 将来的なAPI実装
class ApiPetRepository implements PetRepository {
  final Dio _dio;
  
  @override
  Future<List<Pet>> getPets() async {
    final response = await _dio.get('/api/pets');
    return (response.data as List).map((e) => Pet.fromJson(e)).toList();
  }
}
```

## 5. セキュリティ仕様（モック版）

### 5.1 認証・認可（モック版）
- ローカルのみでの簡易認証（パスワードなし）
- ユーザー名のみでログイン
- 実際の認証は将来実装

### 5.2 データ保護（モック版）
- ブラウザのローカルストレージに保存
- 画像はbase64エンコードで保存
- 機密情報は保存しない前提

### 5.3 入力検証
- クライアントサイド検証のみ
- 基本的なバリデーション（必須入力、文字数制限など）

## 6. パフォーマンス最適化

### 6.1 フロントエンド
- コード分割 (Code Splitting)
- 遅延読み込み (Lazy Loading)
- 画像最適化 (WebP形式使用)
- Service Worker によるキャッシュ
- Tree Shaking

### 6.2 バックエンド
- データベースインデックス最適化
- クエリ最適化
- Redis によるキャッシング
- CDN 活用

## 7. 開発環境

### 7.1 必要なツール
- Flutter SDK 3.x
- Dart SDK 3.x
- Visual Studio Code / Android Studio
- Git
- Docker (バックエンド開発用)

### 7.2 環境変数
```env
# .env.development
API_BASE_URL=http://localhost:8080
FIREBASE_API_KEY=xxx
FIREBASE_AUTH_DOMAIN=xxx
FIREBASE_PROJECT_ID=xxx
FIREBASE_STORAGE_BUCKET=xxx

# .env.production
API_BASE_URL=https://api.pet-health-log.com
FIREBASE_API_KEY=xxx
FIREBASE_AUTH_DOMAIN=xxx
FIREBASE_PROJECT_ID=xxx
FIREBASE_STORAGE_BUCKET=xxx
```

## 8. テスト戦略

### 8.1 テストの種類
- **Unit Tests**: ビジネスロジック、ユーティリティ
- **Widget Tests**: UIコンポーネント
- **Integration Tests**: E2Eテスト
- **Performance Tests**: パフォーマンス計測

### 8.2 カバレッジ目標
- Unit Tests: 80%以上
- Widget Tests: 70%以上
- Critical Path: 100%

## 9. デプロイメント

### 9.1 ビルドプロセス
```bash
# 開発環境
flutter run -d chrome

# プロダクションビルド
flutter build web --release

# テスト実行
flutter test
```

### 9.2 CI/CD パイプライン
1. GitHub へのプッシュ
2. GitHub Actions トリガー
3. 自動テスト実行
4. ビルド
5. Firebase Hosting へデプロイ

## 10. モニタリング

### 10.1 アプリケーションモニタリング
- Firebase Crashlytics
- Google Analytics
- Sentry (エラー追跡)

### 10.2 インフラモニタリング
- Firebase Performance Monitoring
- Uptime Robot (死活監視)

## 11. データ移行・バックアップ

### 11.1 バックアップ戦略
- 日次自動バックアップ
- 3世代保持
- 地理的冗長性

### 11.2 災害復旧計画
- RTO (目標復旧時間): 4時間
- RPO (目標復旧時点): 24時間

## 12. 開発ツール

### 12.1 デバイスプレビュー
開発環境でモバイルデバイスの表示を確認するため、`device_preview`を使用。

#### 実装例
```dart
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // リリースビルドでは無効化
      builder: (context) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}
```

#### 主な機能
- **デバイスフレーム**: iPhone、Android、iPadなど多数のデバイスフレーム
- **画面回転**: ポートレート/ランドスケープの切り替え
- **スケーリング**: 画面サイズの調整
- **テーマ切り替え**: ライト/ダークモードの切り替え
- **ロケール変更**: 多言語対応のテスト
- **スクリーンショット**: 各デバイスでのスクリーンショット保存

### 12.2 レスポンシブデザイン開発
- `MediaQuery`を使用した画面サイズ判定
- `LayoutBuilder`による動的レイアウト
- ブレークポイント定義:
  - Mobile: < 600px
  - Tablet: 600px - 1200px
  - Desktop: > 1200px