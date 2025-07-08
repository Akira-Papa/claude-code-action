# Claude Max OAuth Setup Guide for GitHub Actions

This guide will help you set up Claude Code in GitHub Actions using your Claude Max subscription through OAuth authentication.

## Prerequisites

- Active Claude Max subscription
- Claude CLI installed locally
- Admin access to your GitHub repository
- The Claude GitHub app installed on your repository

## Step 1: Obtain OAuth Credentials from Claude Max

1. **Log in to Claude CLI**
   ```bash
   claude login
   ```
   Follow the prompts to authenticate with your Claude Max account.

2. **Locate your credentials file**
   The OAuth credentials are stored in:
   ```
   ~/.claude/.credentials.json
   ```

3. **Extract the required values**
   Open the credentials file and copy these three values:
   ```json
   {
     "access_token": "your-access-token-here",
     "refresh_token": "your-refresh-token-here",
     "expires_at": "timestamp-here"
   }
   ```

   > **Important**: Keep these credentials secure and never commit them to your repository!

## Step 2: Add OAuth Credentials to GitHub Secrets

1. **Navigate to your repository settings**
   - Go to your GitHub repository
   - Click on "Settings" tab
   - In the left sidebar, click "Secrets and variables" → "Actions"

2. **Add the OAuth secrets**
   Click "New repository secret" for each of the following:

   | Secret Name | Value |
   |------------|-------|
   | `CLAUDE_ACCESS_TOKEN` | Your access_token from credentials.json |
   | `CLAUDE_REFRESH_TOKEN` | Your refresh_token from credentials.json |
   | `CLAUDE_EXPIRES_AT` | Your expires_at timestamp from credentials.json |

3. **Verify all secrets are added**
   You should see all three secrets listed in your repository secrets.

## Step 3: Configure GitHub Workflow

1. **Create or update your workflow file**
   Create `.github/workflows/claude.yml` if it doesn't exist:

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
             # Enable OAuth authentication
             use_oauth: "true"
             claude_access_token: ${{ secrets.CLAUDE_ACCESS_TOKEN }}
             claude_refresh_token: ${{ secrets.CLAUDE_REFRESH_TOKEN }}
             claude_expires_at: ${{ secrets.CLAUDE_EXPIRES_AT }}
             
             # Optional: Customize trigger phrase (default: @claude)
             # trigger_phrase: "/claude"
             
             # Optional: Add custom instructions
             # custom_instructions: |
             #   Follow our coding standards and conventions
   ```

2. **Commit and push the workflow**
   ```bash
   git add .github/workflows/claude.yml
   git commit -m "Add Claude Code OAuth workflow"
   git push
   ```

## Step 4: Install Claude GitHub App

If you haven't already installed the Claude GitHub app:

1. Visit https://github.com/apps/claude
2. Click "Install" or "Configure"
3. Select your repository
4. Grant the required permissions:
   - Pull Requests: Read and write
   - Issues: Read and write
   - Contents: Read and write

## Step 5: Test Your Setup

1. **Create a test issue or PR comment**
   ```
   @claude Can you explain what this repository does?
   ```

2. **Verify Claude responds**
   - Check the Actions tab to see if the workflow triggered
   - Claude should post a response to your comment
   - The response will be updated with progress checkboxes

## Troubleshooting

### Common Issues

1. **"Authentication failed" error**
   - Verify all three OAuth secrets are correctly added
   - Check that your Claude Max subscription is active
   - Ensure credentials haven't expired

2. **Workflow doesn't trigger**
   - Verify the Claude GitHub app is installed
   - Check that you're using the correct trigger phrase (default: `@claude`)
   - Ensure the workflow file is in the correct location

3. **Token expiration**
   - OAuth tokens may expire over time
   - Re-run `claude login` to get fresh credentials
   - Update all three GitHub secrets with new values

### Getting Fresh Credentials

If your tokens expire or you need to refresh them:

```bash
# Log out and log back in
claude logout
claude login

# Check new credentials
cat ~/.claude/.credentials.json
```

Then update your GitHub secrets with the new values.

## Security Best Practices

1. **Never commit credentials**
   - Always use GitHub secrets
   - Never hardcode tokens in workflow files

2. **Limit repository access**
   - Only give repository access to trusted users
   - Claude actions can only be triggered by users with write access

3. **Rotate credentials regularly**
   - Periodically refresh your OAuth tokens
   - Update GitHub secrets when tokens change

## Additional Configuration

### Custom Tools

You can allow Claude to use additional tools:

```yaml
allowed_tools: "Bash(npm install),Bash(npm test),Edit,Replace"
```

### Model Selection

While OAuth uses your Claude Max subscription, you can still specify model preferences if supported:

```yaml
model: "claude-3-5-sonnet-20241022"
```

## Need Help?

- For issues with this OAuth fork: https://github.com/Akira-Papa/claude-code-action/issues
- For general Claude Code questions: https://github.com/anthropics/claude-code/issues
- For Claude Max subscription issues: Contact Anthropic support