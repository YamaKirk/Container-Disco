# Use a specific version for reproducibility
FROM alpine:3.19

# Add metadata
LABEL maintainer="your-email@example.com"
LABEL description="Sample container for DevSecOps pipeline demonstration"

# Install basic utilities (example - customize as needed)
RUN apk add --no-cache \
    curl \
    ca-certificates

# Create a non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

# Set working directory
WORKDIR /app

# Copy application files (if any)
# COPY . /app

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port (example)
EXPOSE 8080

# Health check (example)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Default command
CMD ["sh", "-c", "echo 'Container is running' && tail -f /dev/null"]
