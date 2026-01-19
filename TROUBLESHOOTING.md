# Troubleshooting Guide

## Workflow Failures (Red X's in Actions Tab)

If you see failed workflows with red X's, follow these steps:

### Step 1: Check the Error Message

1. Go to your repository's **Actions** tab
2. Click on the failed workflow run
3. Click on the job name (e.g., "Build and Scan Container Image")
4. Look for the step with a red X
5. Read the error message

### Step 2: Common Issues and Fixes

#### Issue 1: Permission Denied for SARIF Upload

**Error message contains:** `Resource not accessible by integration` or `403 Forbidden`

**Fix:**
1. Go to repository **Settings** → **Actions** → **General**
2. Scroll to "Workflow permissions"
3. Select **"Read and write permissions"**
4. Check **"Allow GitHub Actions to create and approve pull requests"**
5. Click **Save**
6. Re-run the failed workflow

#### Issue 2: Docker Build Failed

**Error message contains:** `docker build` or `Dockerfile` errors

**Fix:**
Check if your Dockerfile is valid. The sample Dockerfile should work, but if you modified it, ensure:
- Base image exists and is accessible
- All commands are valid
- File paths are correct

#### Issue 3: SARIF Upload Not Supported (Private Repos)

**Error message contains:** `Advanced Security must be enabled`

**Fix:**
This is expected for private repositories on the free tier. The workflow will still scan for vulnerabilities, but results won't appear in the Security tab.

**Options:**
1. Make the repository public (unlimited free scanning)
2. Remove the SARIF upload steps from the workflow
3. Rely on the JSON and Table format reports in workflow logs

#### Issue 4: Rate Limiting

**Error message contains:** `rate limit` or `429`

**Fix:**
Wait a few minutes and re-run the workflow. GitHub Actions has rate limits for API calls.

### Step 3: Re-run Failed Workflows

After fixing the issue:
1. Go to the failed workflow run
2. Click **"Re-run all jobs"** button (top right)
3. Wait for the workflow to complete

### Getting Help

If you encounter a different error:
1. Copy the complete error message
2. Check the [GitHub Actions documentation](https://docs.github.com/en/actions)
3. Search for the error on [GitHub Community](https://github.community/)
4. Review [Trivy documentation](https://aquasecurity.github.io/trivy/)

## Workflow Not Triggering

If workflows don't run at all:

1. **Check workflow files location:** Must be in `.github/workflows/`
2. **Check branch name:** Workflows trigger on `main` or `develop` branches
3. **Check Actions enabled:** Settings → Actions → Allow all actions
4. **Manual trigger:** Go to Actions tab → Select workflow → "Run workflow"

## Viewing Scan Results

Even if SARIF upload fails, you can still view results:

### Option 1: Workflow Logs
1. Actions tab → Click workflow run
2. Click job name
3. Expand "Run Trivy vulnerability scanner (Table format)"
4. View formatted vulnerability table

### Option 2: Download JSON Report
1. Actions tab → Click workflow run
2. Scroll to bottom → **Artifacts** section
3. Download "trivy-scan-results"
4. Extract and view JSON file

### Option 3: Local Scanning
Run Trivy locally to test:
```powershell
# Install Trivy (Windows)
# Download from: https://github.com/aquasecurity/trivy/releases

# Scan your Docker image
trivy image myapp:latest
```

## Need More Help?

Create an issue with:
- Error message (full text)
- Workflow file content
- Steps you've already tried
