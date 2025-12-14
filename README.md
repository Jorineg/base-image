# IBHelm Base Image

Shared Docker base image for all IBHelm Python services.

## What It Does

1. Starts with Python 3.11 slim
2. Adds curl + jq for config fetching
3. Includes smart entrypoint that:
   - Tries to fetch config from the service agent
   - Falls back to .env file if agent not available
   - Then runs your application

## Building

```bash
# Build locally (run from this directory)
docker build -t ibhelm/base:latest .

# Verify it exists
docker images | grep ibhelm/base
```

## Using in Service Dockerfiles

```dockerfile
FROM ibhelm/base:latest

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ ./src/

ENV SERVICE_NAME=your-service-name

CMD ["python", "-m", "src.app"]
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SERVICE_NAME` | `unknown` | Name used for config lookup |
| `CONFIG_AGENT_URL` | `http://host.docker.internal:8100` | URL of config agent |

## For Multiple Machines (HP Z2 G9 + NAS)

Option 1: Build on each machine
```bash
# On HP Z2 G9
cd base-image && docker build -t ibhelm/base:latest .

# On NAS (copy files first, or git clone)
cd base-image && docker build -t ibhelm/base:latest .
```

Option 2: Transfer image file
```bash
# On HP Z2 G9: Save to file
docker save ibhelm/base:latest | gzip > ibhelm-base.tar.gz

# Copy to NAS via scp/rsync
scp ibhelm-base.tar.gz nas:/tmp/

# On NAS: Load from file
gunzip -c /tmp/ibhelm-base.tar.gz | docker load
```

Option 3: Private registry (for larger setups)
```bash
# Run registry on HP Z2 G9
docker run -d -p 5000:5000 --restart always registry:2

# Tag and push
docker tag ibhelm/base:latest localhost:5000/ibhelm/base:latest
docker push localhost:5000/ibhelm/base:latest

# On NAS: pull from HP Z2 G9
docker pull hp-z2-g9:5000/ibhelm/base:latest
```

