# DevSecOps CI/CD Pipeline

[![Container Security Scan](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/container-security-scan.yml/badge.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/container-security-scan.yml)
[![Dockerfile Security Scan](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/dockerfile-security-scan.yml/badge.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/dockerfile-security-scan.yml)

A production-ready CI/CD pipeline implementing DevSecOps best practices with automated container security scanning using **free and open-source tools**.

## 🎯 Overview

This repository provides a complete CI/CD pipeline that automatically scans Docker container images for vulnerabilities and security misconfigurations. The pipeline is designed to work with **any Docker container**, regardless of the programming language or framework used inside.

## 🔒 Security Features

- **Container Image Vulnerability Scanning** - Detects known vulnerabilities (CVEs) in container images
- **Dockerfile Security Analysis** - Identifies misconfigurations and security issues in Dockerfiles
- **Multi-Format Reporting** - SARIF, JSON, and table formats for different use cases
- **GitHub Security Integration** - Automatic upload of findings to GitHub Security tab
- **Severity Classification** - CRITICAL, HIGH, MEDIUM, and LOW severity levels
- **Automated Scanning** - Runs on every push and pull request

## 🛠️ Tools Used (All Free)

| Tool | Purpose | Cost |
|------|---------|------|
| **GitHub Actions** | CI/CD Platform | Free (2,000 min/month private, unlimited public) |
| **Trivy** | Container & Dockerfile Scanner | Free & Open Source |

## 🚀 Quick Start

### Prerequisites

- GitHub account
- Docker installed locally (optional, for local testing)
- A Dockerfile in your repository

### Setup Instructions

1. **Create a new GitHub repository**
   ```bash
   # On GitHub.com, create a new repository
   # Then clone it locally
   git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
   cd YOUR_REPO
   ```

2. **Copy the pipeline files**
   ```bash
   # Copy all files from this repository to your new repository
   # Make sure to include:
   # - .github/workflows/container-security-scan.yml
   # - .github/workflows/dockerfile-security-scan.yml
   # - Dockerfile (or use your own)
   # - .dockerignore
   ```

3. **Update the README badges**
   - Replace `YOUR_USERNAME` and `YOUR_REPO` in the badge URLs at the top of this file

4. **Push to GitHub**
   ```bash
   git add .
   git commit -m "Add DevSecOps CI/CD pipeline"
   git push origin main
   ```

5. **View Results**
   - Go to the **Actions** tab to see workflow runs
   - Go to the **Security** tab → **Code scanning** to see vulnerability findings

## 📊 Understanding Scan Results

### Where to Find Results

1. **GitHub Actions Tab**
   - View real-time workflow execution
   - See detailed logs and table-formatted vulnerability reports
   - Download JSON artifacts for offline analysis

2. **GitHub Security Tab**
   - Navigate to **Security** → **Code scanning alerts**
   - View all vulnerabilities with severity levels
   - Filter by severity, status, or category
   - Track remediation progress

3. **Pull Request Checks**
   - Security scans run automatically on PRs
   - Results appear in the PR checks section
   - Prevents merging without security review

### Severity Levels

| Severity | Description | Action Required |
|----------|-------------|-----------------|
| 🔴 **CRITICAL** | Actively exploited vulnerabilities | Fix immediately |
| 🟠 **HIGH** | Serious vulnerabilities with known exploits | Fix as soon as possible |
| 🟡 **MEDIUM** | Moderate risk vulnerabilities | Fix in next release |
| 🟢 **LOW** | Minor issues or informational | Fix when convenient |

## 🔧 Customization

### Scanning Your Own Container

Replace the sample `Dockerfile` with your own. The pipeline will automatically:
1. Build your container image
2. Scan it for vulnerabilities
3. Report findings

### Adjusting Severity Thresholds

Edit `.github/workflows/container-security-scan.yml`:

```yaml
- name: Run Trivy vulnerability scanner
  uses: aquasecurity/trivy-action@master
  with:
    severity: 'CRITICAL,HIGH'  # Only scan for critical and high
    exit-code: '1'  # Fail the build if vulnerabilities found
```

### Scanning Specific Directories

To scan only specific parts of your Dockerfile or configuration:

```yaml
- name: Run Trivy config scanner
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: 'config'
    scan-ref: './path/to/configs'  # Specify directory
```

## 📁 Repository Structure

```
.
├── .github/
│   └── workflows/
│       ├── container-security-scan.yml      # Main container scanning workflow
│       └── dockerfile-security-scan.yml     # Dockerfile security analysis
├── Dockerfile                                # Sample Dockerfile (replace with yours)
├── .dockerignore                            # Files to exclude from Docker build
├── README.md                                # This file
└── SECURITY.md                              # Security policy
```

## 🐛 Troubleshooting

### Workflow Not Running

- Ensure workflows are in `.github/workflows/` directory
- Check that you've pushed to `main` or `develop` branch
- Verify GitHub Actions is enabled in repository settings

### No Vulnerabilities Detected

- This is good! It means your container is secure
- Verify the scan ran by checking the Actions tab
- Try using an older base image to test (e.g., `alpine:3.10`)

### SARIF Upload Fails

- Ensure `security-events: write` permission is set in workflow
- Check that you're using a supported GitHub plan (free tier supports this)
- Verify the SARIF file was generated in previous steps

## 🔐 Security Best Practices

1. **Use Specific Image Tags** - Avoid `latest` tag, use specific versions
2. **Run as Non-Root User** - Always specify a non-root user in Dockerfile
3. **Minimize Base Image** - Use minimal base images like Alpine
4. **Multi-Stage Builds** - Reduce final image size and attack surface
5. **Regular Updates** - Keep base images and dependencies updated
6. **Secret Management** - Never hardcode secrets in Dockerfiles

## 📚 Additional Resources

- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
- [OWASP Container Security](https://owasp.org/www-project-docker-top-10/)

## 📝 License

This pipeline configuration is provided as-is for educational and production use.

## 🤝 Contributing

Feel free to customize this pipeline for your specific needs. Common enhancements:
- Add SAST (Static Application Security Testing)
- Integrate dependency scanning
- Add automated deployment stages
- Implement custom notification systems

---

**Note**: Replace `YOUR_USERNAME` and `YOUR_REPO` with your actual GitHub username and repository name throughout this file.
