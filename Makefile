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
	flutter build web --release --base-href /pet-health-log/

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
	@echo "GitHub Actions経由でデプロイを開始します..."
	@git add .
	@git commit --allow-empty -m "release: GitHub Pagesにデプロイ"
	@git push origin main
	@echo ""
	@echo "✅ リリースコミットを作成し、GitHub Actionsでデプロイを開始しました"
	@echo ""
	@echo "デプロイ状況は以下で確認できます:"
	@echo "https://github.com/$(shell git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/actions"