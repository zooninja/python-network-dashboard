# Docker Deployment Guide

Complete guide for running Python Network Dashboard in Docker containers.

## Quick Start

### Local Mode (Simplest)

```bash
# Build and run
docker-compose --profile local up -d

# Access at http://localhost:8081
```

No authentication required. Safe for local development.

### Exposed Mode (Network Access)

```bash
# Generate strong token
export DASHBOARD_TOKEN=$(python -c "import secrets; print(secrets.token_urlsafe(32))")

# Build and run
docker-compose --profile exposed up -d

# Access at http://<server-ip>:8081
```

Authentication required. Process termination disabled by default.

### Production Mode (With HTTPS)

```bash
# Set token
export DASHBOARD_TOKEN='your-secret-token'

# Generate self-signed cert (or use your own)
mkdir -p certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout certs/key.pem -out certs/cert.pem \
  -subj "/CN=dashboard.example.com"

# Build and run
docker-compose --profile production up -d

# Access at https://<server-ip>
```

Nginx reverse proxy with TLS, rate limiting, and security headers.

## Building the Image

### Simple Build

```bash
docker build -t network-dashboard .
```

### Multi-platform Build (ARM64 + AMD64)

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t network-dashboard:latest \
  .
```

## Running Containers

### Docker Run (Local Mode)

```bash
docker run -d \
  --name network-dashboard \
  --network host \
  --cap-add NET_ADMIN \
  --cap-add SYS_PTRACE \
  --privileged \
  -e HOST=127.0.0.1 \
  -e PORT=8081 \
  network-dashboard
```

### Docker Run (Exposed Mode)

```bash
docker run -d \
  --name network-dashboard \
  --network host \
  --cap-add NET_ADMIN \
  --cap-add SYS_PTRACE \
  --privileged \
  -e HOST=0.0.0.0 \
  -e PORT=8081 \
  -e DASHBOARD_TOKEN='your-secret-token' \
  -e EXPOSE=true \
  -e ALLOW_TERMINATE=false \
  network-dashboard
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HOST` | `0.0.0.0` | Host to bind to |
| `PORT` | `8081` | Port to bind to |
| `DASHBOARD_TOKEN` | *(none)* | Auth token (required for exposed mode) |
| `EXPOSE` | `false` | Enable exposed mode |
| `ALLOW_TERMINATE` | See below | Enable process termination |
| `DEBUG` | `false` | Enable Flask debug mode |

**ALLOW_TERMINATE defaults:**
- Local mode: `true`
- Exposed mode: `false`

## Required Capabilities

The container needs special privileges to access host network information:

- `--network host`: Access host network stack
- `--cap-add NET_ADMIN`: Read network connections
- `--cap-add SYS_PTRACE`: Read process information
- `--privileged`: Full host access (for process termination)

**Security Note:** These privileges give the container significant access to the host. Only run on trusted systems.

## Docker Compose Profiles

### Available Profiles

1. **local** - Local development, no auth
2. **exposed** - Network access with auth
3. **production** - HTTPS with nginx reverse proxy

### Using Profiles

```bash
# Start local profile
docker-compose --profile local up -d

# Start exposed profile
docker-compose --profile exposed up -d

# Start production profile (with nginx)
docker-compose --profile production up -d

# Stop specific profile
docker-compose --profile local down

# View logs
docker-compose --profile local logs -f
```

## Production Setup with Nginx

### 1. Generate SSL Certificates

**Option A: Self-signed (testing)**
```bash
mkdir -p certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout certs/key.pem -out certs/cert.pem \
  -subj "/CN=your-domain.com"
```

**Option B: Let's Encrypt (production)**
```bash
# Use certbot to obtain certificates
certbot certonly --standalone -d your-domain.com

# Copy to certs directory
cp /etc/letsencrypt/live/your-domain.com/fullchain.pem certs/cert.pem
cp /etc/letsencrypt/live/your-domain.com/privkey.pem certs/key.pem
```

### 2. Configure Token

```bash
# Generate strong token
export DASHBOARD_TOKEN=$(python -c "import secrets; print(secrets.token_urlsafe(32))")

# Or set your own
export DASHBOARD_TOKEN='your-very-long-secret-token-here'
```

### 3. Start Services

```bash
docker-compose --profile production up -d
```

### 4. Verify

```bash
# Check containers
docker-compose ps

# Test HTTPS endpoint
curl -k https://localhost/api/config

# View logs
docker-compose logs -f
```

### 5. Access Dashboard

```bash
# Open browser to
https://your-domain.com

# Enter token when prompted
```

## Health Checks

The container includes a health check:

```bash
# Check health status
docker inspect network-dashboard | grep -A 10 Health

# Manual health check
docker exec network-dashboard \
  python -c "import urllib.request; urllib.request.urlopen('http://localhost:8081/api/config')"
```

Health check runs every 30 seconds and checks `/api/config` endpoint.

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker-compose logs dashboard-exposed

# Common issues:
# 1. Missing DASHBOARD_TOKEN
export DASHBOARD_TOKEN='your-token'

# 2. Port already in use
# Change PORT in docker-compose.yml or stop conflicting service
```

### No Network Data

```bash
# Ensure host network mode
docker inspect network-dashboard | grep NetworkMode

# Should show: "NetworkMode": "host"

# Check capabilities
docker inspect network-dashboard | grep -A 10 CapAdd
```

### Permission Denied

```bash
# Container needs privileged mode for process info
docker run --privileged ...

# Or add specific capabilities
docker run --cap-add NET_ADMIN --cap-add SYS_PTRACE ...
```

### Nginx 502 Bad Gateway

```bash
# Check dashboard is running
curl http://localhost:8081/api/config

# Check nginx can reach dashboard
docker exec network-dashboard-nginx curl http://127.0.0.1:8081/api/config

# View nginx logs
docker-compose logs nginx
```

## Security Considerations

### Container Security

1. **Non-root user**: Container runs as user `dashboard` (UID 1000)
2. **Read-only filesystem**: Application files are read-only
3. **No unnecessary packages**: Slim base image with minimal deps
4. **Health checks**: Automatic container restart on failure

### Network Security

1. **Token required**: Exposed mode enforces authentication
2. **Rate limiting**: Nginx limits requests (30/min)
3. **HTTPS only**: Production profile redirects HTTP to HTTPS
4. **Security headers**: HSTS, X-Frame-Options, CSP, etc.

### Host Access

The container needs significant host access:
- Network stack (`--network host`)
- Process information (`--cap-add SYS_PTRACE`)
- Process termination (`--privileged`)

**Only run on systems you trust and control.**

## Production Checklist

- [ ] Generate strong token (`secrets.token_urlsafe(32)`)
- [ ] Obtain valid SSL/TLS certificates
- [ ] Configure firewall (allow only necessary ports)
- [ ] Set `ALLOW_TERMINATE=false` for safety
- [ ] Enable nginx rate limiting
- [ ] Set up log monitoring
- [ ] Configure automated backups (if storing data)
- [ ] Test token authentication
- [ ] Test HTTPS redirect
- [ ] Test rate limiting (try >30 req/min)
- [ ] Document emergency procedures

## Updating

### Update to Latest Version

```bash
# Pull latest changes
git pull origin main

# Rebuild image
docker-compose build

# Restart with new image
docker-compose --profile exposed down
docker-compose --profile exposed up -d
```

### Zero-Downtime Update

```bash
# Build new image
docker build -t network-dashboard:new .

# Start new container
docker run -d --name dashboard-new ... network-dashboard:new

# Test new container
curl http://localhost:8082/api/config

# If good, stop old and rename
docker stop network-dashboard
docker rename network-dashboard dashboard-old
docker rename dashboard-new network-dashboard

# Clean up
docker rm dashboard-old
```

## Resource Limits

Add resource limits to prevent container from consuming too much:

```yaml
# In docker-compose.yml
services:
  dashboard-exposed:
    # ... other config ...
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
```

## Monitoring

### Container Stats

```bash
# Real-time stats
docker stats network-dashboard

# Export metrics
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

### Application Logs

```bash
# Follow logs
docker-compose logs -f

# Last 100 lines
docker-compose logs --tail=100

# Since timestamp
docker-compose logs --since 2024-01-01T00:00:00
```

## Examples

### Development Stack

```bash
# Local mode with live reload
docker run -d \
  --name dashboard-dev \
  --network host \
  --privileged \
  -e DEBUG=true \
  -v $(pwd):/app \
  network-dashboard
```

### Multi-Instance (Different Ports)

```bash
# Instance 1 on port 8081
docker run -d --name dashboard-1 --network host \
  -e PORT=8081 -e DASHBOARD_TOKEN=token1 network-dashboard

# Instance 2 on port 8082
docker run -d --name dashboard-2 --network host \
  -e PORT=8082 -e DASHBOARD_TOKEN=token2 network-dashboard
```

## References

- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Nginx Reverse Proxy Guide](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)
- [Let's Encrypt](https://letsencrypt.org/getting-started/)
