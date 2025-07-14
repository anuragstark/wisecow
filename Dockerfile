# Use Ubuntu as base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PORT=4499

# Install required packages
RUN apt-get update && apt-get install -y \
    netcat-openbsd \
    fortune-mod \
    cowsay \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy application files
COPY . .

# Make the script executable
RUN chmod +x wisecow.sh

# Expose port
EXPOSE 4499

# Create non-root user
RUN useradd -m -s /bin/bash appuser && chown -R appuser:appuser /app
USER appuser

# Run the application
CMD ["./wisecow.sh"]