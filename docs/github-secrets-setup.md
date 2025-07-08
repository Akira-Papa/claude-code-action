# GitHub Secrets Setup for Claude OAuth

This visual guide walks you through adding OAuth credentials as GitHub secrets.

## Step-by-Step Instructions

### 1. Navigate to Repository Settings

1. Go to your GitHub repository
2. Click on the **Settings** tab at the top of the page

![Settings Tab](https://via.placeholder.com/800x100/e1e4e8/495057?text=Click+on+Settings+Tab)

### 2. Access Secrets Configuration

1. In the left sidebar, find **Secrets and variables**
2. Click on **Actions**

![Secrets Menu](https://via.placeholder.com/300x400/e1e4e8/495057?text=Secrets+and+variables+%3E+Actions)

### 3. Add New Repository Secret

Click the **New repository secret** button:

![New Secret Button](https://via.placeholder.com/200x50/0969da/ffffff?text=New+repository+secret)

### 4. Add Each OAuth Secret

You need to add three secrets. For each secret:

#### Secret 1: CLAUDE_ACCESS_TOKEN

1. **Name**: `CLAUDE_ACCESS_TOKEN`
2. **Secret**: Paste your access_token value from `~/.claude/.credentials.json`
3. Click **Add secret**

![Add Access Token](https://via.placeholder.com/600x200/e1e4e8/495057?text=Name%3A+CLAUDE_ACCESS_TOKEN)

#### Secret 2: CLAUDE_REFRESH_TOKEN

1. **Name**: `CLAUDE_REFRESH_TOKEN`
2. **Secret**: Paste your refresh_token value from `~/.claude/.credentials.json`
3. Click **Add secret**

![Add Refresh Token](https://via.placeholder.com/600x200/e1e4e8/495057?text=Name%3A+CLAUDE_REFRESH_TOKEN)

#### Secret 3: CLAUDE_EXPIRES_AT

1. **Name**: `CLAUDE_EXPIRES_AT`
2. **Secret**: Paste your expires_at timestamp from `~/.claude/.credentials.json`
3. Click **Add secret**

![Add Expires At](https://via.placeholder.com/600x200/e1e4e8/495057?text=Name%3A+CLAUDE_EXPIRES_AT)

### 5. Verify All Secrets Are Added

After adding all three secrets, your secrets page should show:

- ✓ CLAUDE_ACCESS_TOKEN
- ✓ CLAUDE_REFRESH_TOKEN  
- ✓ CLAUDE_EXPIRES_AT

![Secrets List](https://via.placeholder.com/600x150/e1e4e8/495057?text=All+three+OAuth+secrets+configured)

## Important Security Notes

⚠️ **Never share or expose these secrets**
- Secrets are encrypted and only visible to repository admins
- Never commit these values to your code
- Rotate tokens regularly for security

## Updating Secrets

To update a secret (e.g., when tokens expire):

1. Click on the secret name
2. Click **Update**
3. Paste the new value
4. Click **Update secret**

## Organization Secrets (Optional)

For multiple repositories, you can use organization secrets:

1. Go to Organization Settings
2. Navigate to Secrets and variables → Actions
3. Add secrets at organization level
4. Select which repositories can access them

## Verification

To verify your secrets are working:

1. Create a PR or issue
2. Comment with `@claude help`
3. Check the Actions tab to see if the workflow runs successfully

If you see authentication errors, double-check that all three secrets are correctly added with the exact values from your credentials file.