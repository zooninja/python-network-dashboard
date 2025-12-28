# Changelog

## [2.0.0] - Security and UX Overhaul

### Security Improvements

#### Safe-by-Default Architecture
- **Local mode (default)**: No authentication required, binds to `127.0.0.1`
- **Exposed mode**: Requires `DASHBOARD_TOKEN` environment variable
- **Automatic validation**: Server refuses to start in exposed mode without token

#### Enhanced Process Protection
- **Expanded denylist**: Added Windows (wininit.exe) and Linux (sshd, NetworkManager, etc.) critical processes
- **PID 1 protection**: Prevents termination of init/systemd on Linux
- **Smart defaults**: `ALLOW_TERMINATE` defaults to `false` in exposed mode

#### Rate Limiting
- **Terminate endpoint**: 10 requests per minute per IP
- **In-memory implementation**: Simple, no external dependencies
- **Per-IP tracking**: Prevents abuse from single source

#### Authentication System
- **Token-based auth**: Bearer token in Authorization header
- **Frontend integration**: Auto-prompt and localStorage persistence
- **Flexible enforcement**: Optional in local mode, required in exposed mode

### UX Improvements

#### Command Line Interface
```bash
# New CLI arguments
python server.py --help
python server.py --expose
python server.py --host 0.0.0.0 --port 8082
```

#### Environment Variables
- `DASHBOARD_TOKEN`: Authentication token
- `EXPOSE`: Enable exposed mode
- `ALLOW_TERMINATE`: Control process termination
- `HOST`, `PORT`, `DEBUG`: Server configuration

#### Enhanced Startup Banner
```
============================================================
Python Network Dashboard Server
============================================================
Mode: Exposed
Bind: 0.0.0.0:8081
Access: http://<server-ip>:8081
Auth: Enabled
Terminate: Disabled

Authorization Header:
  Authorization: Bearer abc123...

Press Ctrl+C to stop the server
============================================================
```

#### Browser Experience
- **Auto-detection**: Frontend checks `/api/config` for auth requirements
- **Token prompt**: Modal dialog for token entry
- **Persistent storage**: Token saved in localStorage
- **401 handling**: Auto-prompt on authentication failure

### API Enhancements

#### Pagination Support
```bash
GET /api/connections?limit=100&offset=50
```
- Default limit: 50
- Maximum limit: 500
- Returns total count for client-side pagination

#### Advanced Filtering
```bash
# Filter by connection state
GET /api/connections?state=ESTABLISHED

# Filter by process name (substring match)
GET /api/connections?process=python

# Combine filters
GET /api/connections?state=LISTEN&process=nginx
```

#### New Endpoints
- `GET /api/config`: Returns auth and terminate status for frontend
- Enhanced response format with metadata

#### Backward Compatibility
- Old clients still work (connections array format maintained)
- New clients get enhanced pagination data

### Quality & Documentation

#### GitHub Actions CI
- Automated linting with ruff
- Import validation
- Runs on every push/PR

#### Security Documentation
- **SECURITY.md**: Vulnerability reporting process
- **Best practices**: Token generation, firewall rules, VPN usage
- **Known limitations**: Transparent about security boundaries

#### README Overhaul
- **Quick start**: Three clear scenarios (local, exposed, exposed+terminate)
- **Configuration table**: All environment variables documented
- **API reference**: Complete with curl examples
- **Troubleshooting**: Common issues and solutions
- **Security section**: Critical process list, rate limits, best practices

### Breaking Changes

⚠️ **Exposed mode now requires DASHBOARD_TOKEN**
- Previous versions allowed `--expose` without auth
- Server now exits with error if token not set
- Migration: Set `DASHBOARD_TOKEN` environment variable before starting

⚠️ **ALLOW_TERMINATE defaults to false in exposed mode**
- Previous versions enabled terminate by default
- Now requires explicit `ALLOW_TERMINATE=true` in exposed mode
- Local mode still defaults to true

⚠️ **API response format for /api/connections**
- New format includes pagination metadata
- Old format: `[{connection}, ...]`
- New format: `{connections: [...], total: N, limit: M, offset: K}`
- Backward compatible: Frontend handles both formats

### Migration Guide

#### From 1.x to 2.0

**Local usage (no changes required):**
```bash
# Still works exactly the same
python server.py
```

**Exposed usage (requires token):**
```bash
# Old way (no longer works):
python server.py --host 0.0.0.0

# New way:
export DASHBOARD_TOKEN=$(python -c "import secrets; print(secrets.token_urlsafe(32))")
python server.py --expose
```

**With process termination:**
```bash
# Explicitly enable terminate in exposed mode
DASHBOARD_TOKEN='...' ALLOW_TERMINATE=true python server.py --expose
```

**Update frontend calls:**
```javascript
// Old
const connections = await fetch('/api/connections').then(r => r.json());

// New (backward compatible)
const data = await fetch('/api/connections').then(r => r.json());
const connections = data.connections || data; // Works with both formats
```

### Files Changed

- `server.py`: Complete rewrite with auth, rate limiting, pagination
- `dashboard.html`: Updated to handle new API format
- `dashboard_auth.js`: New authentication module
- `README.md`: Complete documentation overhaul
- `SECURITY.md`: New security documentation
- `.github/workflows/ci.yml`: New CI pipeline
- `config.py`: Default changed to `localhost` from `0.0.0.0`

### Dependencies

No new dependencies added. Still uses:
- Flask
- flask-cors
- psutil

### Testing

Validated on:
- Windows 10/11
- Ubuntu 22.04 (Debian 12+)
- macOS (via compatible Linux paths)

All platforms tested with:
- Local mode (no auth)
- Exposed mode (with auth)
- Process termination (enabled/disabled)
- Rate limiting
- Token validation
