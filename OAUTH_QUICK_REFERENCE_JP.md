# Claude Max OAuth クイックリファレンス

## 🚀 5分でセットアップ

### 1. 認証情報を取得
```bash
# Claudeにログイン
claude login

# 認証情報を確認
cat ~/.claude/.credentials.json
```

### 2. 環境変数を設定（ローカル用）

```bash
# セットアップスクリプトを実行
./scripts/setup-env-vars.sh

# または手動で環境変数を読み込み
source ~/.claude/env.sh
```

### 3. GitHubシークレットを追加

リポジトリの[Settings → Secrets → Actions](../../settings/secrets/actions)で以下を追加：

| シークレット名 | 取得元 |
|--------------|--------|
| `CLAUDE_ACCESS_TOKEN` | credentials.jsonの`access_token` |
| `CLAUDE_REFRESH_TOKEN` | credentials.jsonの`refresh_token` |
| `CLAUDE_EXPIRES_AT` | credentials.jsonの`expires_at` |

### 4. ワークフローを更新

```yaml
# .github/workflows/claude.yml
name: Claude Code
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
  issues:
    types: [opened, assigned]
  pull_request_review:
    types: [submitted]

jobs:
  claude:
    runs-on: ubuntu-latest
    steps:
      - uses: Akira-Papa/claude-code-action@beta
        with:
          use_oauth: "true"
          claude_access_token: ${{ secrets.CLAUDE_ACCESS_TOKEN }}
          claude_refresh_token: ${{ secrets.CLAUDE_REFRESH_TOKEN }}
          claude_expires_at: ${{ secrets.CLAUDE_EXPIRES_AT }}
```

### 5. GitHub Appをインストール

https://github.com/apps/claude

## ✅ テスト方法

イシューまたはPRでコメント：
```
@claude このコードの説明をしてください
```

## 🔧 トラブルシューティング

| 問題 | 解決方法 |
|------|---------|
| 認証失敗 | `claude login`を再実行してシークレットを更新 |
| ワークフローが動作しない | Claude appがインストールされているか確認 |
| トークン期限切れ | 新しい認証情報を取得してシークレットを更新 |

## 📚 詳細情報

- [詳細セットアップガイド](./OAUTH_SETUP_JP.md)
- [環境変数セットアップ](./scripts/setup-env-vars.sh)
- [ワークフロー例](./examples/)