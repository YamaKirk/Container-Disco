# Pipeline Architecture Diagram

```mermaid
flowchart TD
    A[Developer Push/PR] --> B{GitHub Actions}
    
    B --> C[Container Security Scan Workflow]
    B --> D[Dockerfile Security Scan Workflow]
    
    C --> C1[Checkout Code]
    C1 --> C2[Build Docker Image]
    C2 --> C3[Trivy Scan - SARIF]
    C3 --> C4[Upload to GitHub Security]
    C2 --> C5[Trivy Scan - Table]
    C2 --> C6[Trivy Scan - JSON]
    C6 --> C7[Upload Artifacts]
    C5 --> C8[Generate Summary]
    
    D --> D1[Checkout Code]
    D1 --> D2[Trivy Config Scan - SARIF]
    D2 --> D3[Upload to GitHub Security]
    D1 --> D4[Trivy Config Scan - Table]
    
    C4 --> E[GitHub Security Tab]
    D3 --> E
    C7 --> F[Downloadable Reports]
    C8 --> G[Workflow Summary]
    D4 --> G
    
    E --> H[Security Alerts]
    F --> I[JSON Analysis]
    G --> J[Quick Overview]
    
    style A fill:#e1f5ff
    style B fill:#fff4e1
    style C fill:#e8f5e9
    style D fill:#e8f5e9
    style E fill:#ffebee
    style F fill:#f3e5f5
    style G fill:#f3e5f5
```

## Workflow Execution Flow

### Container Security Scan
1. **Trigger**: Push to main/develop or Pull Request
2. **Build**: Docker image is built from Dockerfile
3. **Scan**: Trivy scans the built image in three formats:
   - SARIF (for GitHub Security integration)
   - Table (for human-readable logs)
   - JSON (for programmatic analysis)
4. **Report**: Results uploaded to GitHub Security and available as artifacts

### Dockerfile Security Scan
1. **Trigger**: Push to main/develop or Pull Request
2. **Scan**: Trivy analyzes Dockerfile for:
   - Security misconfigurations
   - Best practice violations
   - Potential vulnerabilities
3. **Report**: Results uploaded to GitHub Security

## Security Scanning Stages

```mermaid
graph LR
    A[Code Commit] --> B[Dockerfile Analysis]
    B --> C[Image Build]
    C --> D[Vulnerability Scan]
    D --> E[Report Generation]
    E --> F{Critical Issues?}
    F -->|Yes| G[Alert Developer]
    F -->|No| H[Continue Pipeline]
    G --> I[Review & Fix]
    I --> A
    H --> J[Deploy Ready]
    
    style A fill:#e3f2fd
    style D fill:#fff3e0
    style F fill:#fce4ec
    style G fill:#ffebee
    style J fill:#e8f5e9
```

## Vulnerability Severity Flow

```mermaid
flowchart TD
    A[Vulnerability Detected] --> B{Severity Level}
    
    B -->|CRITICAL| C[🔴 Immediate Action]
    B -->|HIGH| D[🟠 Fix ASAP]
    B -->|MEDIUM| E[🟡 Schedule Fix]
    B -->|LOW| F[🟢 Track for Later]
    
    C --> G[Block Deployment]
    D --> H[Create Issue]
    E --> H
    F --> H
    
    H --> I[Assign to Team]
    I --> J[Implement Fix]
    J --> K[Re-scan]
    K --> L{Fixed?}
    L -->|Yes| M[Close Alert]
    L -->|No| J
    
    style A fill:#fff3e0
    style C fill:#ffcdd2
    style D fill:#ffccbc
    style E fill:#fff9c4
    style F fill:#c8e6c9
    style M fill:#a5d6a7
```
