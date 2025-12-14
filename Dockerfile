# IBHelm Base Image
# All Python services inherit from this to get:
# - Config loading from agent (if available)
# - Fallback to .env file
# - Common utilities

FROM python:3.11-slim

# Image metadata
LABEL org.opencontainers.image.title="IBHelm Base Image"
LABEL org.opencontainers.image.description="Shared base image with config agent support"

# Install utilities for config fetching
# curl: HTTP requests to agent
# jq: Parse JSON response
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Copy and setup entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /app

# All containers use this entrypoint
# It fetches config from agent, then runs the CMD
ENTRYPOINT ["/entrypoint.sh"]

