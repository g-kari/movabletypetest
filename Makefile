# MovableType Docker環境 管理用Makefile

.PHONY: help start stop restart build logs clean reset

# デフォルトタスク
help:
	@echo "MovableType Docker環境 管理コマンド:"
	@echo ""
	@echo "  make start     - 環境を起動"
	@echo "  make stop      - 環境を停止" 
	@echo "  make restart   - 環境を再起動"
	@echo "  make build     - イメージを再ビルド"
	@echo "  make logs      - ログを表示"
	@echo "  make clean     - 停止してイメージを削除"
	@echo "  make reset     - 完全リセット（データも削除）"
	@echo ""

# 環境起動
start:
	@echo "🚀 MovableType環境を起動しています..."
	docker compose up -d
	@echo "✅ 起動完了！ http://localhost/cgi-bin/mt/mt.cgi"

# 環境停止
stop:
	@echo "🛑 MovableType環境を停止しています..."
	docker compose down
	@echo "✅ 停止完了"

# 環境再起動
restart: stop start

# イメージ再ビルド
build:
	@echo "🔨 イメージを再ビルドしています..."
	docker compose build --no-cache
	@echo "✅ ビルド完了"

# ログ表示
logs:
	docker compose logs -f

# 環境削除（イメージも削除）
clean:
	@echo "🧹 環境とイメージを削除しています..."
	docker compose down --rmi all
	@echo "✅ 削除完了"

# 完全リセット（データベースのデータも削除）
reset:
	@echo "⚠️  完全リセット（全データ削除）を実行しています..."
	docker compose down -v --rmi all
	@echo "✅ リセット完了"

# 開発用コマンド
dev-mysql:
	docker compose exec mysql mysql -u mt -p mt

dev-redis:
	docker compose exec redis redis-cli

dev-shell:
	docker compose exec movabletype /bin/bash