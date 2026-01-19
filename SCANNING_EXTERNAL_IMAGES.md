# Scanning External Container Images

This guide explains how to scan container images from Docker Hub or other registries without building them yourself.

## Quick Example: Scan an Image from Docker Hub

### Option 1: Create a New Workflow for External Images

Create a new file: `.github/workflows/scan-external-image.yml`

```yaml
name: Scan External Container Image

on:
  workflow_dispatch:  # Manual trigger only
    inputs:
      image_name:
        description: 'Container image to scan (e.g., nginx:latest, postgres:15)'
        required: true
        default: 'nginx:latest'

permissions:
  contents: read
  security-events: write

jobs:
  scan-external-image:
    name: Scan External Image
    runs-on: ubuntu-latest
    
    steps:
      - name: Pull Docker image
        run: |
          echo "Pulling image: ${{ github.event.inputs.image_name }}"
          docker pull ${{ github.event.inputs.image_name }}
          docker images
      
      - name: Run Trivy vulnerability scanner (SARIF)
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: '${{ github.event.inputs.image_name }}'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH,MEDIUM'
          exit-code: '0'
      
      - name: Upload results to GitHub Security
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'
          category: 'external-image-scan'
      
      - name: Run Trivy scanner (Table format)
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: '${{ github.event.inputs.image_name }}'
          format: 'table'
          severity: 'CRITICAL,HIGH,MEDIUM,LOW'
          exit-code: '0'
      
      - name: Run Trivy scanner (JSON format)
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: '${{ github.event.inputs.image_name }}'
          format: 'json'
          output: 'trivy-results.json'
          severity: 'CRITICAL,HIGH,MEDIUM,LOW'
          exit-code: '0'
      
      - name: Upload JSON results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: external-image-scan-results
          path: trivy-results.json
          retention-days: 30
```

**How to use:**
1. Create this file in your repository
2. Push to GitHub
3. Go to **Actions** tab → **Scan External Container Image**
4. Click **Run workflow**
5. Enter the image name (e.g., `nginx:latest`, `postgres:15`, `redis:alpine`)
6. Click **Run workflow**

---

## Option 2: Modify Existing Workflow

If you want to replace the current Dockerfile scanning with external image scanning:

### Step 1: Edit the Dockerfile

Replace your `Dockerfile` with a simple reference:

```dockerfile
# Scan this external image
FROM nginx:latest
```

The pipeline will automatically pull and scan whatever base image you specify.

### Step 2: Change Base Image Anytime

Just update the `FROM` line in the Dockerfile:

```dockerfile
FROM postgres:15
# or
FROM redis:7-alpine
# or
FROM python:3.11-slim
```

Commit and push - the pipeline will scan the new image!

---

## Option 3: Scan Multiple Images

Create a workflow that scans multiple images at once:

```yaml
name: Scan Multiple Images

on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday
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
          - 'nginx:latest'
          - 'postgres:15'
          - 'redis:alpine'
          - 'python:3.11-slim'
    
    steps:
      - name: Pull image
        run: docker pull ${{ matrix.image }}
      
      - name: Scan with Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: '${{ matrix.image }}'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH,MEDIUM'
      
      - name: Upload to GitHub Security
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'
          category: 'image-${{ matrix.image }}'
```

This scans all images in the matrix automatically!

---

## Scanning Private Registry Images

If your image is in a private registry (Docker Hub private repo, AWS ECR, etc.):

```yaml
- name: Login to Docker Hub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKERHUB_USERNAME }}
    password: ${{ secrets.DOCKERHUB_TOKEN }}

- name: Pull private image
  run: docker pull your-username/private-image:tag

- name: Scan with Trivy
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: 'your-username/private-image:tag'
    format: 'sarif'
    output: 'trivy-results.sarif'
```

**Setup secrets:**
1. Go to repository **Settings** → **Secrets and variables** → **Actions**
2. Add `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`

---

## Common Images to Scan

Here are popular images you might want to scan:

**Web Servers:**
- `nginx:latest`, `nginx:alpine`
- `httpd:latest`

**Databases:**
- `postgres:15`, `postgres:16-alpine`
- `mysql:8`, `mysql:latest`
- `redis:7-alpine`, `redis:latest`
- `mongodb:latest`

**Languages/Runtimes:**
- `python:3.11-slim`, `python:3.12-alpine`
- `node:20-alpine`, `node:latest`
- `golang:1.21-alpine`
- `openjdk:17-slim`

**Operating Systems:**
- `ubuntu:22.04`, `ubuntu:latest`
- `alpine:3.19`, `alpine:latest`
- `debian:bookworm-slim`

---

## Tips

1. **Use specific tags** instead of `latest` for reproducible scans
2. **Scan regularly** - set up scheduled workflows to catch new vulnerabilities
3. **Compare images** - scan both `nginx:latest` and `nginx:alpine` to see which is more secure
4. **Check before deployment** - scan production images before deploying

---

## Quick Start

**Easiest method:**
1. Create `.github/workflows/scan-external-image.yml` with the Option 1 code above
2. Push to GitHub
3. Go to Actions → Run workflow
4. Enter any Docker Hub image name
5. View results in Security tab!
