# Claude Max OAuth Quick Reference

## 🚀 5-Minute Setup

### 1. Get Credentials
```bash
# Login to Claude
claude login

# Find credentials
cat ~/.claude/.credentials.json
```

### 2. Add GitHub Secrets

Add these three secrets to your repository ([Settings → Secrets → Actions](../../settings/secrets/actions)):

| Secret Name | Where to Find It |
|------------|------------------|
| `CLAUDE_ACCESS_TOKEN` | `access_token` from credentials.json |
| `CLAUDE_REFRESH_TOKEN` | `refresh_token` from credentials.json |
| `CLAUDE_EXPIRES_AT` | `expires_at` from credentials.json |

### 3. Update Workflow

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

### 4. Install GitHub App

https://github.com/apps/claude

## ✅ Test It

Create an issue or PR comment:
```
@claude What does this code do?
```

## 🔧 Troubleshooting

| Problem | Solution |
|---------|----------|
| Authentication failed | Re-run `claude login` and update secrets |
| Workflow not triggering | Check Claude app is installed |
| Token expired | Get fresh credentials and update secrets |

## 📚 More Info

- [Detailed Setup Guide](./OAUTH_SETUP.md)
- [GitHub Secrets Guide](./docs/github-secrets-setup.md)
- [Example Workflows](./examples/)