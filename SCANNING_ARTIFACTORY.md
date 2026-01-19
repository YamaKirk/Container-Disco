# Scanning JFrog Artifactory Container Registry

This guide explains how to set up automated scanning of all container images in a JFrog Artifactory SaaS instance.

## Prerequisites

1. **Artifactory Details:**
   - Artifactory URL (e.g., `yourcompany.jfrog.io`)
   - Docker registry name (e.g., `docker-local`)
   - Username or service account
   - API token or password

2. **GitHub Secrets Setup:**
   Go to repository **Settings** → **Secrets and variables** → **Actions** and add:
   - `ARTIFACTORY_URL` - Your Artifactory URL (e.g., `yourcompany.jfrog.io`)
   - `ARTIFACTORY_USERNAME` - Your Artifactory username
   - `ARTIFACTORY_TOKEN` - Your Artifactory API token or password
   - `ARTIFACTORY_REGISTRY` - Your registry name (e.g., `docker-local`)

## Solution 1: Scan All Images from Artifactory Registry

Create: `.github/workflows/scan-artifactory-images.yml`

```yaml
name: Scan Artifactory Container Images

on:
  schedule:
    - cron: '0 2 * * 1'  # Weekly on Monday at 2 AM
  workflow_dispatch:  # Manual trigger
    inputs:
      repository_filter:
        description: 'Filter repositories (e.g., "myapp" to scan only myapp images)'
        required: false
        default: ''

permissions:
  contents: read
  security-events: write

jobs:
  discover-images:
    name: Discover Images in Artifactory
    runs-on: ubuntu-latest
    outputs:
      images: ${{ steps.list-images.outputs.images }}
    
    steps:
      - name: List images from Artifactory
        id: list-images
        run: |
          # Install jq for JSON processing
          sudo apt-get update && sudo apt-get install -y jq curl
          
          # Artifactory AQL query to get all Docker images
          ARTIFACTORY_URL="${{ secrets.ARTIFACTORY_URL }}"
          REGISTRY="${{ secrets.ARTIFACTORY_REGISTRY }}"
          
          # Query Artifactory for all manifest files (represents images)
          QUERY='items.find({
            "repo": "'$REGISTRY'",
            "name": "manifest.json"
          }).include("path", "repo")'
          
          # Execute AQL query
          RESPONSE=$(curl -u "${{ secrets.ARTIFACTORY_USERNAME }}:${{ secrets.ARTIFACTORY_TOKEN }}" \
            -X POST \
            -H "Content-Type: text/plain" \
            -d "$QUERY" \
            "https://${ARTIFACTORY_URL}/artifactory/api/search/aql")
          
          # Parse response and extract image names and tags
          IMAGES=$(echo "$RESPONSE" | jq -r '.results[] | .path' | \
            sed 's|/||g' | \
            awk -F'/' '{print $1":"$2}' | \
            sort -u | \
            jq -R -s -c 'split("\n") | map(select(length > 0))')
          
          echo "images=$IMAGES" >> $GITHUB_OUTPUT
          echo "Found images: $IMAGES"

  scan-images:
    name: Scan ${{ matrix.image }}
    needs: discover-images
    runs-on: ubuntu-latest
    strategy:
      matrix:
        image: ${{ fromJson(needs.discover-images.outputs.images) }}
      fail-fast: false
      max-parallel: 5
    
    steps:
      - name: Login to Artifactory
        run: |
          echo "${{ secrets.ARTIFACTORY_TOKEN }}" | docker login \
            ${{ secrets.ARTIFACTORY_URL }} \
            -u "${{ secrets.ARTIFACTORY_USERNAME }}" \
            --password-stdin
      
      - name: Pull image from Artifactory
        run: |
          FULL_IMAGE="${{ secrets.ARTIFACTORY_URL }}/${{ secrets.ARTIFACTORY_REGISTRY }}/${{ matrix.image }}"
          echo "Pulling: $FULL_IMAGE"
          docker pull "$FULL_IMAGE"
      
      - name: Run Trivy vulnerability scanner (SARIF)
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: '${{ secrets.ARTIFACTORY_URL }}/${{ secrets.ARTIFACTORY_REGISTRY }}/${{ matrix.image }}'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH,MEDIUM'
          exit-code: '0'
      
      - name: Upload to GitHub Security
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'
          category: 'artifactory-${{ matrix.image }}'
      
      - name: Run Trivy scanner (Table format)
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: '${{ secrets.ARTIFACTORY_URL }}/${{ secrets.ARTIFACTORY_REGISTRY }}/${{ matrix.image }}'
          format: 'table'
          severity: 'CRITICAL,HIGH,MEDIUM,LOW'
          exit-code: '0'
      
      - name: Run Trivy scanner (JSON format)
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: '${{ secrets.ARTIFACTORY_URL }}/${{ secrets.ARTIFACTORY_REGISTRY }}/${{ matrix.image }}'
          format: 'json'
          output: 'trivy-results-${{ matrix.image }}.json'
          severity: 'CRITICAL,HIGH,MEDIUM,LOW'
          exit-code: '0'
      
      - name: Upload scan results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: scan-results-${{ matrix.image }}
          path: trivy-results-${{ matrix.image }}.json
          retention-days: 30
```

---

## Solution 2: Scan Specific Images (Simpler Approach)

If you know which images you want to scan, use a static list:

```yaml
name: Scan Specific Artifactory Images

on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM
  workflow_dispatch:

permissions:
  contents: read
  security-events: write

jobs:
  scan-images:
    name: Scan ${{ matrix.image }}
    runs-on: ubuntu-latest
    strategy:
      matrix:
        image:
          - 'myapp/backend:latest'
          - 'myapp/frontend:latest'
          - 'myapp/api:v1.2.3'
          - 'database/postgres:15'
      fail-fast: false
    
    steps:
      - name: Login to Artifactory
        run: |
          echo "${{ secrets.ARTIFACTORY_TOKEN }}" | docker login \
            ${{ secrets.ARTIFACTORY_URL }} \
            -u "${{ secrets.ARTIFACTORY_USERNAME }}" \
            --password-stdin
      
      - name: Pull and scan image
        run: |
          FULL_IMAGE="${{ secrets.ARTIFACTORY_URL }}/${{ secrets.ARTIFACTORY_REGISTRY }}/${{ matrix.image }}"
          docker pull "$FULL_IMAGE"
      
      - name: Scan with Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: '${{ secrets.ARTIFACTORY_URL }}/${{ secrets.ARTIFACTORY_REGISTRY }}/${{ matrix.image }}'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH,MEDIUM'
      
      - name: Upload to GitHub Security
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'
          category: 'artifactory-${{ matrix.image }}'
```

---

## Solution 3: Using Artifactory REST API

For more control, use Artifactory's REST API to list images:

```yaml
name: Scan Artifactory Images via API

on:
  workflow_dispatch:

permissions:
  contents: read
  security-events: write

jobs:
  list-and-scan:
    name: List and Scan Images
    runs-on: ubuntu-latest
    
    steps:
      - name: Get image list from Artifactory API
        id: get-images
        run: |
          # Get all repositories in the registry
          REPOS=$(curl -u "${{ secrets.ARTIFACTORY_USERNAME }}:${{ secrets.ARTIFACTORY_TOKEN }}" \
            "https://${{ secrets.ARTIFACTORY_URL }}/artifactory/api/docker/${{ secrets.ARTIFACTORY_REGISTRY }}/v2/_catalog" | \
            jq -r '.repositories[]')
          
          echo "Found repositories:"
          echo "$REPOS"
          
          # For each repository, get tags
          for REPO in $REPOS; do
            TAGS=$(curl -u "${{ secrets.ARTIFACTORY_USERNAME }}:${{ secrets.ARTIFACTORY_TOKEN }}" \
              "https://${{ secrets.ARTIFACTORY_URL }}/artifactory/api/docker/${{ secrets.ARTIFACTORY_REGISTRY }}/v2/${REPO}/tags/list" | \
              jq -r '.tags[]')
            
            for TAG in $TAGS; do
              echo "${REPO}:${TAG}"
            done
          done
      
      - name: Login to Artifactory
        run: |
          echo "${{ secrets.ARTIFACTORY_TOKEN }}" | docker login \
            ${{ secrets.ARTIFACTORY_URL }} \
            -u "${{ secrets.ARTIFACTORY_USERNAME }}" \
            --password-stdin
      
      # Add scanning steps here for each image
```

---

## Setup Instructions

### Step 1: Get Artifactory Credentials

1. **Login to Artifactory** (yourcompany.jfrog.io)
2. **Generate API Token:**
   - Click your profile → Edit Profile
   - Generate API Key or Access Token
   - Copy the token

### Step 2: Add GitHub Secrets

1. Go to your GitHub repository
2. **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add these secrets:

```
Name: ARTIFACTORY_URL
Value: yourcompany.jfrog.io

Name: ARTIFACTORY_USERNAME
Value: your-username

Name: ARTIFACTORY_TOKEN
Value: your-api-token

Name: ARTIFACTORY_REGISTRY
Value: docker-local
```

### Step 3: Create Workflow File

1. Choose Solution 1 (auto-discover) or Solution 2 (static list)
2. Create the workflow file in `.github/workflows/`
3. Commit and push to GitHub

### Step 4: Run the Workflow

1. Go to **Actions** tab
2. Select your workflow
3. Click **Run workflow**
4. View results in **Security** tab

---

## Advanced: Filter by Repository Pattern

To scan only specific image patterns (e.g., only production images):

```yaml
- name: Filter images by pattern
  run: |
    # Only scan images matching pattern
    IMAGES=$(echo "$ALL_IMAGES" | grep "^prod/" || true)
    
    # Or exclude certain patterns
    IMAGES=$(echo "$ALL_IMAGES" | grep -v "^test/" || true)
```

---

## Monitoring and Alerts

### Option 1: Fail on Critical Vulnerabilities

Change `exit-code: '0'` to `exit-code: '1'` to fail the workflow if critical vulnerabilities are found.

### Option 2: Send Notifications

Add Slack/email notifications:

```yaml
- name: Notify on vulnerabilities
  if: failure()
  uses: slackapi/slack-github-action@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK }}
    payload: |
      {
        "text": "🚨 Vulnerabilities found in ${{ matrix.image }}"
      }
```

---

## Troubleshooting

### Authentication Fails

```bash
# Test authentication locally
docker login yourcompany.jfrog.io -u username -p token
```

### Can't List Images

- Verify user has read permissions on the registry
- Check if registry name is correct
- Ensure API token has appropriate scopes

### Rate Limiting

If scanning many images:
- Use `max-parallel: 5` to limit concurrent scans
- Add delays between scans if needed

---

## Best Practices

1. **Schedule regular scans** - Daily or weekly
2. **Scan on image push** - Trigger when new images are uploaded to Artifactory
3. **Tag-based scanning** - Only scan `latest` or production tags
4. **Retention policy** - Keep scan results for compliance (30+ days)
5. **Separate workflows** - Different workflows for dev/staging/prod registries

---

## Cost Optimization (Free Tier)

Since you're on limited funds:
- **Public repo** = unlimited GitHub Actions minutes
- **Private repo** = 2,000 minutes/month
- **Optimize scans:**
  - Scan only changed images
  - Use `max-parallel` to control concurrency
  - Schedule during off-peak hours

---

## Next Steps

1. Set up GitHub secrets with Artifactory credentials
2. Choose Solution 1 (auto-discover) or Solution 2 (static list)
3. Test with a single image first
4. Scale to all images once working
5. Set up scheduled scans
