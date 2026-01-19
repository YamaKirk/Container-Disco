# DevSecOps Pipeline Setup Guide

This guide will walk you through setting up the CI/CD pipeline with container security scanning on GitHub.

## Step 1: Create GitHub Repository

1. Go to [GitHub.com](https://github.com) and log in
2. Click the **+** icon in the top right → **New repository**
3. Fill in the details:
   - **Repository name**: `devsecops-pipeline` (or your preferred name)
   - **Description**: "CI/CD pipeline with automated container security scanning"
   - **Visibility**: Choose **Public** (for unlimited free minutes) or **Private**
   - **DO NOT** initialize with README (we already have files)
4. Click **Create repository**

## Step 2: Push Code to GitHub

Open PowerShell and run these commands:

```powershell
# Navigate to the project directory
cd C:\Users\Admin\.gemini\antigravity\scratch\devsecops-pipeline

# Initialize git repository
git init

# Configure git (if not already configured)
git config user.name "Your Name"
git config user.email "your-email@example.com"

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: DevSecOps CI/CD pipeline with Trivy scanning"

# Add your GitHub repository as remote
# Replace YOUR_USERNAME and YOUR_REPO with your actual values
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 3: Verify Workflows

1. Go to your GitHub repository
2. Click the **Actions** tab
3. You should see two workflows:
   - "Container Security Scan"
   - "Dockerfile Security Scan"
4. Both should start running automatically
5. Click on a workflow run to see detailed logs

## Step 4: View Security Results

### Option A: GitHub Security Tab
1. Click the **Security** tab in your repository
2. Click **Code scanning alerts** on the left
3. View all detected vulnerabilities
4. Filter by severity, status, or category

### Option B: Workflow Logs
1. Go to **Actions** tab
2. Click on a workflow run
3. Click on the job name
4. Expand the "Run Trivy vulnerability scanner (Table format)" step
5. See a formatted table of vulnerabilities

### Option C: Download JSON Report
1. Go to **Actions** tab
2. Click on a workflow run
3. Scroll to the bottom → **Artifacts**
4. Download "trivy-scan-results"
5. Extract and view the JSON file

## Step 5: Update README Badges

Edit `README.md` and replace:
- `YOUR_USERNAME` with your GitHub username
- `YOUR_REPO` with your repository name

Then commit and push:
```powershell
git add README.md
git commit -m "Update README badges"
git push
```

## Step 6: Test with Pull Request

1. Create a new branch:
   ```powershell
   git checkout -b test-scanning
   ```

2. Make a small change to the Dockerfile (e.g., add a comment)

3. Commit and push:
   ```powershell
   git add Dockerfile
   git commit -m "Test security scanning on PR"
   git push -u origin test-scanning
   ```

4. Go to GitHub and create a Pull Request

5. Verify that security scans run automatically on the PR

## Troubleshooting

### Workflows Not Running
- Check that files are in `.github/workflows/` directory
- Ensure you pushed to the `main` branch
- Verify GitHub Actions is enabled in Settings → Actions

### Permission Errors
- Go to Settings → Actions → General
- Under "Workflow permissions", select "Read and write permissions"
- Click Save

### SARIF Upload Fails
- This is normal for private repositories on free tier in some cases
- The table and JSON reports will still work
- Vulnerabilities will still be visible in workflow logs

## Next Steps

- Replace the sample Dockerfile with your own
- Customize severity thresholds in workflow files
- Add more security scanning stages (SAST, dependency scanning)
- Set up automated deployment after successful scans

## Need Help?

- Check the [README.md](README.md) for detailed documentation
- Review [Trivy documentation](https://aquasecurity.github.io/trivy/)
- Check [GitHub Actions documentation](https://docs.github.com/en/actions)
