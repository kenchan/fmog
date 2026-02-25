# fmog (Feed MogMog)

Ruby製のCLIフィードアグリゲーター。RSS/Atomフィードを購読・閲覧できます。

## インストール

```bash
bundle install
```

## 使い方

### フィード管理

```bash
# フィードを追加
bundle exec fmog feed add https://example.com/feed.xml

# フィード一覧を表示
bundle exec fmog feed list

# フィードを取得（全フィード）
bundle exec fmog feed fetch

# 特定のフィードだけ取得
bundle exec fmog feed fetch 1

# フィードを削除
bundle exec fmog feed remove 1
```

### アイテム（記事）管理

```bash
# アイテム一覧を表示
bundle exec fmog item list

# 未読のみ表示
bundle exec fmog item list --unread

# 特定フィードのアイテムのみ表示
bundle exec fmog item list --feed 1

# 表示件数を指定
bundle exec fmog item list --limit 10

# アイテム詳細を表示
bundle exec fmog item show 1

# 既読にする
bundle exec fmog item read 1

# 未読に戻す
bundle exec fmog item unread 1
```

## 出力フォーマット

- **ターミナル（TTY）**: テーブル形式で見やすく表示
- **パイプ/リダイレクト**: JSON Lines形式（1行1オブジェクト）

```bash
# JSON Linesとして他のコマンドに渡す
bundle exec fmog item list --unread | jq '.title'
```

## データ保存先

`~/.local/share/fmog/fmog.db`（SQLite）
