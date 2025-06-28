#!/bin/bash

# Claude OAuth環境変数セットアップスクリプト
# このスクリプトは、Claude OAuth認証用の環境変数を設定するのに役立ちます

set -e

echo "================================================"
echo "Claude OAuth 環境変数セットアップ"
echo "================================================"
echo ""

# カラー出力用
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Claude CLIがインストールされているか確認
if ! command -v claude &> /dev/null; then
    echo -e "${RED}エラー: Claude CLIがインストールされていません${NC}"
    echo "まずClaude CLIをインストールしてください: https://claude.ai/code"
    exit 1
fi

# ユーザーがログインしているか確認
echo -e "${YELLOW}Claudeのログイン状態を確認中...${NC}"
if ! claude whoami &> /dev/null; then
    echo -e "${YELLOW}まずClaudeにログインする必要があります${NC}"
    claude login
fi

# 認証情報ファイルの確認
CREDS_FILE="$HOME/.claude/.credentials.json"
if [ ! -f "$CREDS_FILE" ]; then
    echo -e "${RED}エラー: 認証情報ファイルが見つかりません: $CREDS_FILE${NC}"
    echo "claude login を使用してログインしてください"
    exit 1
fi

echo -e "${GREEN}✓ Claude認証情報が見つかりました${NC}"
echo ""

# 認証情報を抽出
ACCESS_TOKEN=$(jq -r '.access_token' "$CREDS_FILE" 2>/dev/null)
REFRESH_TOKEN=$(jq -r '.refresh_token' "$CREDS_FILE" 2>/dev/null)
EXPIRES_AT=$(jq -r '.expires_at' "$CREDS_FILE" 2>/dev/null)

if [ -z "$ACCESS_TOKEN" ] || [ -z "$REFRESH_TOKEN" ] || [ -z "$EXPIRES_AT" ]; then
    echo -e "${RED}エラー: $CREDS_FILE から認証情報を抽出できませんでした${NC}"
    echo "ファイルにaccess_token、refresh_token、expires_atが含まれていることを確認してください"
    exit 1
fi

echo -e "${GREEN}✓ OAuth認証情報を正常に抽出しました${NC}"
echo ""

# 環境変数ファイルのパス
ENV_FILE="$HOME/.claude/env.sh"

# .claudeディレクトリが存在しない場合は作成
mkdir -p "$HOME/.claude"

# 環境変数ファイルを作成
echo "================================================"
echo "環境変数ファイルの作成"
echo "================================================"
echo ""

cat > "$ENV_FILE" << EOF
#!/bin/bash
# Claude OAuth環境変数
# 生成日時: $(date)

export CLAUDE_ACCESS_TOKEN="$ACCESS_TOKEN"
export CLAUDE_REFRESH_TOKEN="$REFRESH_TOKEN"
export CLAUDE_EXPIRES_AT="$EXPIRES_AT"

echo "Claude OAuth環境変数が読み込まれました"
EOF

# ファイルの権限を設定（所有者のみ読み取り可能）
chmod 600 "$ENV_FILE"

echo -e "${GREEN}✓ 環境変数ファイルを作成しました: $ENV_FILE${NC}"
echo ""

# シェル設定ファイルへの追加オプション
echo "================================================"
echo "シェル設定への追加"
echo "================================================"
echo ""

# 使用中のシェルを検出
SHELL_RC=""
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

if [ -n "$SHELL_RC" ]; then
    echo "シェル設定ファイル ($SHELL_RC) に自動読み込みを追加しますか？"
    echo "これにより、新しいターミナルセッションで自動的に環境変数が設定されます。"
    echo ""
    read -p "追加しますか？ (y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # 既存の設定があるか確認
        if grep -q "source $ENV_FILE" "$SHELL_RC" 2>/dev/null; then
            echo -e "${YELLOW}既に設定が追加されています${NC}"
        else
            echo "" >> "$SHELL_RC"
            echo "# Claude OAuth環境変数" >> "$SHELL_RC"
            echo "[ -f $ENV_FILE ] && source $ENV_FILE" >> "$SHELL_RC"
            echo -e "${GREEN}✓ $SHELL_RC に設定を追加しました${NC}"
        fi
    fi
fi

# GitHubシークレット設定の案内
echo ""
echo "================================================"
echo "GitHub Actionsでの使用方法"
echo "================================================"
echo ""
echo "GitHub Actionsで使用する場合は、以下の手順でシークレットを設定してください："
echo ""
echo "1. GitHubリポジトリの Settings → Secrets and variables → Actions に移動"
echo "2. 以下の3つのシークレットを追加："
echo ""
echo -e "${YELLOW}CLAUDE_ACCESS_TOKEN${NC}"
echo -e "${YELLOW}CLAUDE_REFRESH_TOKEN${NC}"
echo -e "${YELLOW}CLAUDE_EXPIRES_AT${NC} (値: $EXPIRES_AT)"
echo ""

# 使用方法の説明
echo "================================================"
echo "ローカルでの使用方法"
echo "================================================"
echo ""
echo "環境変数を読み込むには："
echo -e "${GREEN}source $ENV_FILE${NC}"
echo ""
echo "または、新しいターミナルセッションを開始してください（自動読み込みを設定した場合）"
echo ""

# セキュリティの注意
echo "================================================"
echo "セキュリティに関する注意"
echo "================================================"
echo ""
echo -e "${RED}重要:${NC}"
echo "- 環境変数ファイルは安全に保管してください"
echo "- これらの値を公開リポジトリにコミットしないでください"
echo "- 定期的にトークンを更新してください"
echo ""

echo -e "${GREEN}✓ セットアップが完了しました！${NC}"
echo ""
echo "詳細な手順については、OAUTH_SETUP_JP.md を参照してください。"