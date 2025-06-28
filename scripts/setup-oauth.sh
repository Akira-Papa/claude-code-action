#!/bin/bash

# Claude Code OAuth Setup Script
# This script helps you set up OAuth authentication for Claude Code GitHub Action

set -e

echo "================================================"
echo "Claude Code OAuth Setup for GitHub Actions"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if claude CLI is installed
if ! command -v claude &> /dev/null; then
    echo -e "${RED}Error: Claude CLI is not installed${NC}"
    echo "Please install Claude CLI first: https://claude.ai/code"
    exit 1
fi

# Check if user is logged in
echo -e "${YELLOW}Checking Claude login status...${NC}"
if ! claude whoami &> /dev/null; then
    echo -e "${YELLOW}You need to log in to Claude first${NC}"
    claude login
fi

# Check for credentials file
CREDS_FILE="$HOME/.claude/.credentials.json"
if [ ! -f "$CREDS_FILE" ]; then
    echo -e "${RED}Error: Credentials file not found at $CREDS_FILE${NC}"
    echo "Please log in to Claude using: claude login"
    exit 1
fi

echo -e "${GREEN}✓ Found Claude credentials${NC}"
echo ""

# Extract credentials
ACCESS_TOKEN=$(jq -r '.access_token' "$CREDS_FILE" 2>/dev/null)
REFRESH_TOKEN=$(jq -r '.refresh_token' "$CREDS_FILE" 2>/dev/null)
EXPIRES_AT=$(jq -r '.expires_at' "$CREDS_FILE" 2>/dev/null)

if [ -z "$ACCESS_TOKEN" ] || [ -z "$REFRESH_TOKEN" ] || [ -z "$EXPIRES_AT" ]; then
    echo -e "${RED}Error: Could not extract credentials from $CREDS_FILE${NC}"
    echo "Please ensure the file contains access_token, refresh_token, and expires_at"
    exit 1
fi

echo -e "${GREEN}✓ Successfully extracted OAuth credentials${NC}"
echo ""

# Display instructions
echo "================================================"
echo "Next Steps: Add these secrets to your GitHub repository"
echo "================================================"
echo ""
echo "1. Go to your GitHub repository"
echo "2. Navigate to Settings → Secrets and variables → Actions"
echo "3. Click 'New repository secret' and add these three secrets:"
echo ""
echo -e "${YELLOW}Secret 1:${NC}"
echo "  Name: CLAUDE_ACCESS_TOKEN"
echo "  Value: [Hidden for security]"
echo ""
echo -e "${YELLOW}Secret 2:${NC}"
echo "  Name: CLAUDE_REFRESH_TOKEN"
echo "  Value: [Hidden for security]"
echo ""
echo -e "${YELLOW}Secret 3:${NC}"
echo "  Name: CLAUDE_EXPIRES_AT"
echo "  Value: $EXPIRES_AT"
echo ""

# Option to copy to clipboard
if command -v pbcopy &> /dev/null; then
    echo "================================================"
    echo "Copy credentials to clipboard?"
    echo "================================================"
    echo ""
    echo "Would you like to copy each credential to clipboard?"
    echo "(You'll paste them one by one into GitHub secrets)"
    echo ""
    read -p "Copy credentials? (y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${YELLOW}1. CLAUDE_ACCESS_TOKEN${NC}"
        echo "$ACCESS_TOKEN" | pbcopy
        echo -e "${GREEN}✓ Copied to clipboard!${NC} Add this as CLAUDE_ACCESS_TOKEN in GitHub"
        read -p "Press Enter when ready for next credential..."
        
        echo ""
        echo -e "${YELLOW}2. CLAUDE_REFRESH_TOKEN${NC}"
        echo "$REFRESH_TOKEN" | pbcopy
        echo -e "${GREEN}✓ Copied to clipboard!${NC} Add this as CLAUDE_REFRESH_TOKEN in GitHub"
        read -p "Press Enter when ready for next credential..."
        
        echo ""
        echo -e "${YELLOW}3. CLAUDE_EXPIRES_AT${NC}"
        echo "$EXPIRES_AT" | pbcopy
        echo -e "${GREEN}✓ Copied to clipboard!${NC} Add this as CLAUDE_EXPIRES_AT in GitHub"
        echo ""
    fi
fi

# Show workflow example
echo "================================================"
echo "Workflow Configuration"
echo "================================================"
echo ""
echo "Add this to your .github/workflows/claude.yml:"
echo ""
cat << 'EOF'
name: Claude Code with OAuth

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
          use_oauth: "true"
          claude_access_token: ${{ secrets.CLAUDE_ACCESS_TOKEN }}
          claude_refresh_token: ${{ secrets.CLAUDE_REFRESH_TOKEN }}
          claude_expires_at: ${{ secrets.CLAUDE_EXPIRES_AT }}
EOF

echo ""
echo -e "${GREEN}✓ Setup instructions complete!${NC}"
echo ""
echo "Remember to:"
echo "1. Add all three secrets to your GitHub repository"
echo "2. Install the Claude GitHub app: https://github.com/apps/claude"
echo "3. Create or update your workflow file"
echo ""
echo "For detailed instructions, see OAUTH_SETUP.md"