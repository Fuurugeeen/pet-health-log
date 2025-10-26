# Pet Health Log

ペットの健康管理を支援するFlutter Webアプリケーションです。日常の記録（食事、投薬、排泄、散歩、体調）を管理し、健康状態を可視化できます。

## 🐾 主な機能

- **ペット管理**: 複数のペットの登録・管理
- **日常記録**: 食事、投薬、排泄、散歩、体調の記録
- **クイック記録**: ホーム画面から素早く記録入力
- **カレンダービュー**: 日付別の記録確認
- **レポート**: 健康状態の統計とグラフ表示
- **簡易認証**: ユーザー名による認証

## 🏗️ アーキテクチャ

- **Frontend**: Flutter Web
- **状態管理**: Riverpod
- **データ永続化**: Hive (ローカルストレージ)
- **ナビゲーション**: GoRouter
- **UI**: Material Design 3

### ディレクトリ構造

```
lib/
├── core/                    # コア機能
│   ├── constants/          # 定数定義
│   ├── router/             # ルーティング設定
│   ├── themes/             # テーマ設定
│   └── utils/              # ユーティリティ
├── features/               # 機能別モジュール
│   ├── auth/              # 認証機能
│   ├── home/              # ホーム画面
│   ├── pet/               # ペット管理
│   ├── record/            # 記録入力
│   ├── calendar/          # カレンダー
│   └── report/            # レポート
├── models/                # データモデル
├── services/              # サービス層
└── shared/                # 共有コンポーネント
    ├── providers/         # Riverpodプロバイダー
    └── widgets/           # 共有ウィジェット
```

## 🚀 開発環境のセットアップ

### 必要条件

- Flutter SDK 3.24.5+
- Dart 3.6.1+
- Chrome (開発用ブラウザ)

### セットアップ手順

1. **リポジトリのクローン**
   ```bash
   git clone <repository-url>
   cd pet-health-log
   ```

2. **依存関係のインストール**
   ```bash
   flutter pub get
   ```

3. **コード生成の実行**
   ```bash
   dart run build_runner build
   ```

4. **開発サーバーの起動**
   ```bash
   make run
   # または
   flutter run -d chrome
   ```

## 📝 開発コマンド

### Makeコマンド

```bash
make help      # 利用可能なコマンド一覧
make run       # 開発サーバー起動
make build     # プロダクションビルド
make test      # テスト実行
make analyze   # 静的解析
make clean     # ビルド成果物クリーン
make release   # GitHub Pagesにデプロイ
```

### Flutterコマンド

```bash
flutter run -d chrome              # 開発サーバー起動
flutter build web --release        # プロダクションビルド
flutter test                       # テスト実行
flutter analyze                    # 静的解析
flutter pub get                    # 依存関係インストール
dart run build_runner build        # コード生成
```

## 🔧 データモデル

### 主要なモデル

- **User**: ユーザー情報
- **Pet**: ペット情報（名前、種類、生年月日など）
- **DailyRecord**: 日次記録の親モデル
  - **MealRecord**: 食事記録
  - **MedicationRecord**: 投薬記録
  - **ExcretionRecord**: 排泄記録
  - **WalkRecord**: 散歩記録
  - **HealthStatus**: 体調記録

### データ永続化

- **Hive**: 構造化データの保存（ユーザー、ペット、記録）
- **SharedPreferences**: アプリ設定の保存
- **Base64エンコード**: 画像データの保存

## 🎨 デザインシステム

- **カラーパレット**: プライマリ、セカンダリ、アクセントカラー
- **タイポグラフィ**: Material Design 3準拠
- **レスポンシブ対応**: モバイル・タブレット・デスクトップ
- **アクセシビリティ**: スクリーンリーダー対応

## 📦 デプロイ

### GitHub Pages

```bash
make release
```

このコマンドで以下が自動実行されます：
1. Flutter Webアプリをビルド
2. "release"メッセージで空コミットを作成
3. GitHub Actionsで自動デプロイ開始

初回セットアップ時のみ、GitHubリポジトリの Settings > Pages で Source: GitHub Actions を選択してください。

## 🧪 テスト

```bash
make test                    # 全テスト実行
flutter test test/specific_test.dart  # 特定のテスト実行
```

## 📊 モック版仕様

このアプリケーションはモック版として開発されており、以下の特徴があります：

- **オフライン動作**: API不使用、ローカルストレージのみ
- **簡易認証**: ユーザー名のみによる認証
- **サンプルデータ**: 初回起動時にデモデータを自動生成
- **Repository Pattern**: 将来のAPI移行に備えた設計

## 🔮 今後の拡張

- バックエンドAPI実装
- リアルタイム同期
- プッシュ通知
- データエクスポート機能
- 獣医師・ペットショップとの連携

## 🤝 開発ガイドライン

詳細な開発ルールについては [CLAUDE.md](CLAUDE.md) を参照してください。

## 📄 ライセンス

このプロジェクトはプライベートです。