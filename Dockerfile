# Use Ubuntu as base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV SRVPORT=4499

# Install prerequisites
RUN apt-get update && \
    apt-get install -y \
    fortune-mod \
    cowsay \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Add cowsay to PATH
ENV PATH="/usr/games:${PATH}"

# Create app directory
WORKDIR /app

# Copy the wisecow script
COPY wisecow.sh .

# Make script executable
RUN chmod +x wisecow.sh

# Expose port
EXPOSE 4499

# Create non-root user
RUN useradd -m -s /bin/bash appuser && chown -R appuser:appuser /app
USER appuser

# Run the application
CMD ["./wisecow.sh"]