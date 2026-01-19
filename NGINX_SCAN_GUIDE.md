# Quick Guide: Scanning Nginx (or Any Docker Hub Image)

## What I Just Did

Changed your `Dockerfile` from:
```dockerfile
FROM alpine:3.19
```

To:
```dockerfile
FROM nginx:latest
```

## Next Steps

### 1. Commit and Push the Change

```powershell
cd C:\Users\Admin\.gemini\antigravity\scratch\devsecops-pipeline

git add Dockerfile
git commit -m "Change to nginx image for vulnerability scanning"
git push
```

### 2. Watch the Workflow Run

1. Go to your GitHub repository
2. Click **Actions** tab
3. You'll see "Container Security Scan" workflow running
4. Click on it to watch the progress

### 3. View Nginx Scan Results

After the workflow completes:

**Option A: GitHub Security Tab**
- Go to **Security** → **Code scanning**
- You'll see vulnerabilities found in nginx

**Option B: Workflow Summary**
- In the workflow run, scroll down
- See the vulnerability count table

**Option C: Download JSON**
- Scroll to bottom of workflow run
- Download "trivy-scan-results" artifact
- Extract and view the JSON file

## Expected Results

Nginx typically has some vulnerabilities (this is normal for production images). You'll likely see:
- 🔴 A few CRITICAL vulnerabilities
- 🟠 Several HIGH vulnerabilities  
- 🟡 Many MEDIUM vulnerabilities
- 🟢 Lots of LOW vulnerabilities

This is **expected** - even popular images like nginx have known CVEs.

## Scanning Other Images

To scan a different image, just change line 2 of the Dockerfile:

```dockerfile
# Scan PostgreSQL
FROM postgres:15

# Scan Redis
FROM redis:alpine

# Scan Python
FROM python:3.11-slim

# Scan Node.js
FROM node:20-alpine
```

Then commit and push!

## Troubleshooting

### Workflow Didn't Trigger
- Make sure you pushed to the `main` branch
- Check that the workflow file exists in `.github/workflows/`

### No Vulnerabilities Shown
- Check the workflow logs for errors
- Verify Trivy actually ran (look for "Run Trivy" steps)
- Download the JSON artifact to see raw results

### Scan Failed
- Check if the image name is correct
- Ensure Docker can pull the image
- Look at the "Build Docker image" step for errors
