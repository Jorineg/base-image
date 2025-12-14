#!/bin/bash
# IBHelm Shared Entrypoint
# 
# This script runs BEFORE the main application starts.
# It tries to fetch config from the service agent.
# If agent is not available, it falls back to .env file (already loaded by docker-compose).
#
# Environment variables:
#   SERVICE_NAME       - Name of this service (for config lookup)
#   CONFIG_AGENT_URL   - URL of the config agent (default: http://host.docker.internal:8100)

set -e

SERVICE_NAME="${SERVICE_NAME:-unknown}"
CONFIG_AGENT_URL="${CONFIG_AGENT_URL:-http://host.docker.internal:8100}"

echo "[ibhelm] Starting ${SERVICE_NAME}..."

# Try to fetch config from agent (2 second connection timeout, 5 second total)
fetch_config() {
    local response
    
    if response=$(curl -sf --connect-timeout 2 --max-time 5 \
        "${CONFIG_AGENT_URL}/config/${SERVICE_NAME}" 2>/dev/null); then
        
        echo "[ibhelm] Config agent available, loading config..."
        
        # Count how many vars we loaded
        local count=0
        
        # Parse JSON and export each key=value pair
        # Agent returns: {"KEY1": "value1", "KEY2": "value2", ...}
        while IFS='=' read -r key value; do
            if [ -n "$key" ]; then
                export "$key"="$value"
                count=$((count + 1))
            fi
        done < <(echo "$response" | jq -r 'to_entries | .[] | "\(.key)=\(.value)"')
        
        echo "[ibhelm] Loaded $count config values from agent"
        
    else
        echo "[ibhelm] Config agent not available, using .env file"
    fi
}

fetch_config

echo "[ibhelm] Starting main process..."

# Execute the CMD passed to this container
# "$@" expands to all arguments (e.g., "python" "-m" "src.app")
exec "$@"

