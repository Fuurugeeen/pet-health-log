.PHONY: help build run test analyze clean release

help:
	@echo "利用可能なコマンド:"
	@echo "  make build    - Flutter Webアプリケーションをビルド"
	@echo "  make run      - 開発サーバーを起動"
	@echo "  make test     - テストを実行"
	@echo "  make analyze  - コードの静的解析を実行"
	@echo "  make clean    - ビルド成果物をクリーン"
	@echo "  make release  - GitHub Pagesにデプロイ"

build:
	@echo "Flutter Webアプリケーションをビルド中..."
	flutter build web --release

run:
	@echo "開発サーバーを起動中..."
	flutter run -d chrome

test:
	@echo "テストを実行中..."
	flutter test

analyze:
	@echo "コードの静的解析を実行中..."
	flutter analyze

clean:
	@echo "ビルド成果物をクリーン中..."
	flutter clean

release: build
	@echo "GitHub Pagesへのデプロイを準備中..."
	@echo "ビルド完了！"
	@echo ""
	@echo "GitHub Pagesでデプロイする場合:"
	@echo "1. GitHubリポジトリの Settings > Pages で:"
	@echo "   - Source: GitHub Actions を選択"
	@echo ""
	@echo "2. または、build/webフォルダを手動でデプロイ"
	@echo ""
	@echo "注: build/webフォルダにビルド済みファイルが作成されています。"