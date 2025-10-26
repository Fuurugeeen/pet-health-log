# CLAUDE.md

このファイルは、このリポジトリでコードを扱う際のClaude Code (claude.ai/code) への指針を提供します。

## プロジェクトルール

1. **プロジェクト構成**
   - フォルダはネストせず、トップディレクトリに配置する
   - 作業ログは必ず `doc/` フォルダに保存する
   - ログファイル名は `work_log_YYYY-MM-DD.md` 形式とする

2. **ドキュメント管理**
   - `doc/` フォルダに以下のドキュメントを作成・管理する：
     - 作業ログ（日次）
     - デザイン仕様書
     - 機能仕様書
   - 重要な変更や実装内容は必ず作業ログに記録する
   - 作業ログには実施内容、理由、結果を明確に記載する
   - デザインや仕様の変更は都度ドキュメントを更新する

3. **開発ルール**
   - 新機能の追加や変更時は、まずドキュメントを更新する
   - コード変更後は必ず対応するドキュメントも更新する
   - ドキュメントは日本語で記載する

4. **モック版開発方針**
   - APIは使用せず、全データをローカルストレージ（Hive）に保存
   - 認証は簡易的なもの（ユーザー名のみ）で実装
   - 初回起動時にサンプルデータを自動生成
   - Repository Patternを採用し、将来的なAPI移行に備える
   - 画像はbase64エンコードでローカル保存

## 開発コマンド

### Make コマンド
```bash
# ヘルプ（利用可能なコマンド一覧）
make help

# 開発サーバーの起動
make run

# プロダクションビルド
make build

# GitHub Pagesへのデプロイ準備
make release

# テストの実行
make test

# コードの静的解析
make analyze

# ビルド成果物のクリーン
make clean
```

### Flutter Web開発（直接コマンド）
```bash
# 開発サーバーの起動
flutter run -d chrome

# ビルド（プロダクション用）
flutter build web

# 依存関係のインストール/更新
flutter pub get

# コードの静的解析
flutter analyze

# テストの実行
flutter test

# パッケージのアップグレード
flutter pub upgrade
```

### GitHub Pages デプロイ手順
1. `make release` を実行
   - Flutter Webアプリをビルド
   - "release" メッセージで空コミットを作成
   - GitHub Actionsで自動デプロイを開始
2. 初回セットアップ時のみ、GitHubリポジトリの Settings > Pages で:
   - Source: GitHub Actions を選択

注: GitHub Actionsはコミットメッセージに "release" が含まれる場合のみ実行されます。

### 開発環境
- プロジェクト名: pet_health_log
- プラットフォーム: Web専用
- 主要ディレクトリ:
  - `lib/` - Dartソースコード
  - `web/` - Web固有の設定とアセット
  - `test/` - テストコード
  - `doc/` - 作業ログとドキュメント