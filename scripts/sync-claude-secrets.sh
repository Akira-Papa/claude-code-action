#!/bin/bash

# Check if credentials file exists
# First check XDG_CONFIG_HOME, then fall back to ~/.claude
# Note: As of 2025/06/19, Claude may have started using $XDG_CONFIG_HOME/claude for credentials
if [ -n "$XDG_CONFIG_HOME" ] && [ -f "$XDG_CONFIG_HOME/claude/.credentials.json" ]; then
    CREDENTIALS_FILE="$XDG_CONFIG_HOME/claude/.credentials.json"
elif [ -f "$HOME/.claude/.credentials.json" ]; then
    CREDENTIALS_FILE="$HOME/.claude/.credentials.json"
else
    echo "Error: Credentials file not found at $XDG_CONFIG_HOME/claude/.credentials.json or $HOME/.claude/.credentials.json"
    exit 1
fi

# Check if repository argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <repository1,repository2,...>"
    echo "Example: $0 owner/repo1,owner/repo2"
    exit 1
fi

# Read credentials from JSON file
ACCESS_TOKEN=$(jq -r '.claudeAiOauth.accessToken' "$CREDENTIALS_FILE")
REFRESH_TOKEN=$(jq -r '.claudeAiOauth.refreshToken' "$CREDENTIALS_FILE")
EXPIRES_AT=$(jq -r '.claudeAiOauth.expiresAt' "$CREDENTIALS_FILE")

# Check if jq successfully extracted values
if [ "$ACCESS_TOKEN" = "null" ] || [ -z "$ACCESS_TOKEN" ]; then
    echo "Error: Could not read accessToken from credentials file"
    exit 1
fi

if [ "$REFRESH_TOKEN" = "null" ] || [ -z "$REFRESH_TOKEN" ]; then
    echo "Error: Could not read refreshToken from credentials file"
    exit 1
fi

if [ "$EXPIRES_AT" = "null" ] || [ -z "$EXPIRES_AT" ]; then
    echo "Error: Could not read expiresAt from credentials file"
    exit 1
fi

# Split repositories by comma
IFS=',' read -ra REPOS <<< "$1"

# Set secrets for each repository
for repo in "${REPOS[@]}"; do
    # Trim whitespace
    repo=$(echo "$repo" | xargs)
    
    echo "Setting secrets for repository: $repo"
    
    # Set CLAUDE_ACCESS_TOKEN
    echo "$ACCESS_TOKEN" | gh secret set CLAUDE_ACCESS_TOKEN --repo "$repo"
    if [ $? -eq 0 ]; then
        echo "✓ CLAUDE_ACCESS_TOKEN set successfully"
    else
        echo "✗ Failed to set CLAUDE_ACCESS_TOKEN"
    fi
    
    # Set CLAUDE_REFRESH_TOKEN
    echo "$REFRESH_TOKEN" | gh secret set CLAUDE_REFRESH_TOKEN --repo "$repo"
    if [ $? -eq 0 ]; then
        echo "✓ CLAUDE_REFRESH_TOKEN set successfully"
    else
        echo "✗ Failed to set CLAUDE_REFRESH_TOKEN"
    fi
    
    # Set CLAUDE_EXPIRES_AT
    echo "$EXPIRES_AT" | gh secret set CLAUDE_EXPIRES_AT --repo "$repo"
    if [ $? -eq 0 ]; then
        echo "✓ CLAUDE_EXPIRES_AT set successfully"
    else
        echo "✗ Failed to set CLAUDE_EXPIRES_AT"
    fi
    
    echo "---"
done

echo "Done!"