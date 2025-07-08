# Claude Max OAuth セットアップガイド（GitHub Actions用）

このガイドでは、Claude MaxサブスクリプションのOAuth認証を使用してGitHub ActionsでClaude Codeを設定する方法を説明します。

## 前提条件

- 有効なClaude Maxサブスクリプション
- Claude CLIがローカルにインストールされていること
- GitHubリポジトリへの管理者アクセス
- リポジトリにClaude GitHubアプリがインストールされていること

## ステップ1: Claude MaxからOAuth認証情報を取得

1. **Claude CLIにログイン**
   ```bash
   claude login
   ```
   プロンプトに従ってClaude Maxアカウントで認証してください。

2. **認証情報ファイルの場所を確認**
   OAuth認証情報は以下の場所に保存されています：
   ```
   ~/.claude/.credentials.json
   ```

3. **必要な値を抽出**
   認証情報ファイルを開き、以下の3つの値をコピーしてください：
   ```json
   {
     "access_token": "ここにあなたのアクセストークン",
     "refresh_token": "ここにあなたのリフレッシュトークン",
     "expires_at": "ここにタイムスタンプ"
   }
   ```

   > **重要**: これらの認証情報は安全に保管し、絶対にリポジトリにコミットしないでください！

## ステップ2: 環境変数として設定（ローカル開発用）

### 方法1: シェルの設定ファイルに追加

1. **シェルの設定ファイルを編集**（例：~/.bashrc、~/.zshrc）
   ```bash
   # Claude OAuth認証情報
   export CLAUDE_ACCESS_TOKEN="your-access-token-here"
   export CLAUDE_REFRESH_TOKEN="your-refresh-token-here"
   export CLAUDE_EXPIRES_AT="timestamp-here"
   ```

2. **設定を反映**
   ```bash
   source ~/.bashrc  # または source ~/.zshrc
   ```

### 方法2: 専用の環境変数ファイルを作成

1. **環境変数ファイルを作成**
   ```bash
   # ~/.claude/env.sh を作成
   cat > ~/.claude/env.sh << 'EOF'
   #!/bin/bash
   # Claude OAuth環境変数
   export CLAUDE_ACCESS_TOKEN="your-access-token-here"
   export CLAUDE_REFRESH_TOKEN="your-refresh-token-here"
   export CLAUDE_EXPIRES_AT="timestamp-here"
   EOF
   
   chmod 600 ~/.claude/env.sh  # 読み取り権限を制限
   ```

2. **必要時に環境変数を読み込む**
   ```bash
   source ~/.claude/env.sh
   ```

## ステップ3: GitHub Actionsでの使用

### GitHubシークレットの設定

1. **リポジトリ設定に移動**
   - GitHubリポジトリにアクセス
   - 「Settings」タブをクリック
   - 左サイドバーで「Secrets and variables」→「Actions」を選択

2. **OAuthシークレットを追加**
   以下の各項目について「New repository secret」をクリック：

   | シークレット名 | 値 |
   |--------------|-----|
   | `CLAUDE_ACCESS_TOKEN` | credentials.jsonのaccess_token |
   | `CLAUDE_REFRESH_TOKEN` | credentials.jsonのrefresh_token |
   | `CLAUDE_EXPIRES_AT` | credentials.jsonのexpires_atタイムスタンプ |

3. **すべてのシークレットが追加されたことを確認**
   リポジトリシークレットに3つすべてが表示されているはずです。

## ステップ4: GitHubワークフローの設定

1. **ワークフローファイルを作成または更新**
   `.github/workflows/claude.yml`を作成（存在しない場合）：

   ```yaml
   name: Claude Code Assistant
   
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
     claude-response:
       runs-on: ubuntu-latest
       steps:
         - uses: Akira-Papa/claude-code-action@beta
           with:
             # OAuth認証を有効化
             use_oauth: "true"
             claude_access_token: ${{ secrets.CLAUDE_ACCESS_TOKEN }}
             claude_refresh_token: ${{ secrets.CLAUDE_REFRESH_TOKEN }}
             claude_expires_at: ${{ secrets.CLAUDE_EXPIRES_AT }}
             
             # オプション: トリガーフレーズをカスタマイズ（デフォルト: @claude）
             # trigger_phrase: "/claude"
             
             # オプション: カスタム指示を追加
             # custom_instructions: |
             #   コーディング規約に従ってください
   ```

2. **ワークフローをコミットしてプッシュ**
   ```bash
   git add .github/workflows/claude.yml
   git commit -m "Claude Code OAuthワークフローを追加"
   git push
   ```

## ステップ5: Claude GitHubアプリをインストール

Claude GitHubアプリをまだインストールしていない場合：

1. https://github.com/apps/claude にアクセス
2. 「Install」または「Configure」をクリック
3. リポジトリを選択
4. 必要な権限を付与：
   - Pull Requests: 読み取りと書き込み
   - Issues: 読み取りと書き込み
   - Contents: 読み取りと書き込み

## ステップ6: セットアップのテスト

1. **テスト用のイシューまたはPRコメントを作成**
   ```
   @claude このリポジトリの目的を説明してください
   ```

2. **Claudeの応答を確認**
   - Actionsタブでワークフローがトリガーされたかチェック
   - Claudeがコメントに応答するはずです
   - 進捗状況がチェックボックスで更新されます

## トラブルシューティング

### よくある問題

1. **「認証に失敗しました」エラー**
   - 3つのOAuthシークレットがすべて正しく追加されているか確認
   - Claude Maxサブスクリプションが有効か確認
   - 認証情報の有効期限が切れていないか確認

2. **ワークフローがトリガーされない**
   - Claude GitHubアプリがインストールされているか確認
   - 正しいトリガーフレーズを使用しているか確認（デフォルト: `@claude`）
   - ワークフローファイルが正しい場所にあるか確認

3. **トークンの有効期限切れ**
   - OAuthトークンは時間とともに期限切れになる可能性があります
   - `claude login`を再実行して新しい認証情報を取得
   - 3つのGitHubシークレットをすべて新しい値で更新

### 新しい認証情報の取得

トークンの有効期限が切れた場合や更新が必要な場合：

```bash
# ログアウトして再ログイン
claude logout
claude login

# 新しい認証情報を確認
cat ~/.claude/.credentials.json
```

その後、新しい値でGitHubシークレットを更新してください。

## セキュリティのベストプラクティス

1. **認証情報を絶対にコミットしない**
   - 常にGitHubシークレットを使用
   - ワークフローファイルにトークンをハードコードしない

2. **リポジトリアクセスを制限**
   - 信頼できるユーザーのみにリポジトリアクセスを付与
   - Claudeアクションは書き込み権限を持つユーザーのみがトリガー可能

3. **定期的に認証情報を更新**
   - OAuthトークンを定期的に更新
   - トークンが変更されたらGitHubシークレットを更新

## 追加設定

### カスタムツール

Claudeに追加ツールの使用を許可できます：

```yaml
allowed_tools: "Bash(npm install),Bash(npm test),Edit,Replace"
```

### モデル選択

OAuthはClaude Maxサブスクリプションを使用しますが、サポートされている場合はモデルの優先設定を指定できます：

```yaml
model: "claude-3-5-sonnet-20241022"
```

## ヘルプが必要な場合

- このOAuthフォークに関する問題: https://github.com/Akira-Papa/claude-code-action/issues
- Claude Code全般の質問: https://github.com/anthropics/claude-code/issues
- Claude Maxサブスクリプションの問題: Anthropicサポートに連絡