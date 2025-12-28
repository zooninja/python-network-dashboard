# Python Network Dashboard

Real-time web-based network monitoring dashboard with process management capabilities.

![Python Version](https://img.shields.io/badge/python-3.7+-blue.svg)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## Features

- Real-time network connection monitoring with 5-second auto-refresh
- Interactive filtering by connection state and process name
- Process termination with safety confirmations
- System hostname and IP display for multi-machine monitoring
- Local and remote access modes
- Dark naval theme with smooth animations
- Cross-platform support (Windows, Linux, macOS)

## Quick Start

### Local Monitoring (localhost only)

**Windows:**
```batch
start.bat
```

**Linux/macOS:**
```bash
./start.sh
```

**Linux (Debian 12+/Ubuntu 23.04+):**
```bash
bash start_venv.sh
```

Access at `http://localhost:8081`

### Remote Monitoring (network access)

For remote access from other machines or cloud VMs, edit `config.py`:

```python
HOST = '0.0.0.0'  # Remote access
PORT = 8081
DEBUG = False
```

Default is local-only access:

```python
HOST = 'localhost'  # Local access only (default)
PORT = 8081
DEBUG = False
```

Then access via `http://<server-ip>:8081` (remote) or `http://localhost:8081` (local)

**Security Note:** Remote mode exposes the dashboard on all network interfaces. Use firewall rules or VPN for production deployments.

## Installation

### Standard Installation
```bash
pip install -r requirements.txt
python server.py
```

### Virtual Environment (Recommended for Linux)
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python server.py
```

## Usage

### Filtering Connections
- Click stat cards (Total, Established, Listening, etc.) to filter by connection state
- Click process names in "Top Processes" to filter by application
- Combine state and process filters for precise results
- Remove individual filters by clicking X on filter tags
- Clear all filters with "Clear All Filters" button

### Process Management
- Click any connection row to view detailed process information
- View CPU usage, memory, threads, start time, and executable path
- Terminate processes with confirmation dialogs
- Protected system processes (csrss.exe, lsass.exe, systemd, etc.) cannot be terminated
- **Linux/macOS:** Requires sudo for process information and termination

### System Information
- Hostname and IP address displayed under dashboard title
- Useful for monitoring multiple machines in one browser session

## Configuration

### Local vs Remote Access

Edit `config.py` to switch between modes:

**Local Only (Default):**
```python
HOST = 'localhost'
PORT = 8081
DEBUG = False
```

**Remote Access:**
```python
HOST = '0.0.0.0'
PORT = 8081
DEBUG = False
```

### Change Port

Edit `config.py`:
```python
HOST = '0.0.0.0'
PORT = 8888  # Your custom port
DEBUG = False
```

### Connection Limit
Maximum 50 connections displayed. Modify in `server.py` line 97:
```python
connections = connections[:50]
```

### Auto-refresh Interval
Default 5 seconds. Change in `dashboard.html` line 682:
```javascript
refreshInterval = setInterval(refresh, 5000);
```

## Platform-Specific Notes

### Windows
- Run as Administrator for full process information
- Uses batch script launcher (`start.bat`)

### Linux
- Requires sudo for process details and termination
- Debian 12+/Ubuntu 23.04+ need virtual environment
- Uses shell script launchers (`start.sh`, `start_venv.sh`)

### macOS
- May require sudo for process operations
- Uses shell script launcher (`start.sh`)

## API Reference

### GET /api/connections
Returns active network connections (max 50).

**Response:**
```json
[
  {
    "LocalPort": 8081,
    "RemoteAddress": "95.42.20.232",
    "RemotePort": 55810,
    "State": "ESTABLISHED",
    "ProcessName": "python3",
    "ProcessId": 1491
  }
]
```

### GET /api/stats
Returns connection statistics and top 10 processes.

**Response:**
```json
{
  "Stats": {
    "Total": 44,
    "Established": 12,
    "Listening": 8,
    "TimeWait": 2,
    "CloseWait": 0
  },
  "TopProcesses": [...],
  "Timestamp": "2025-12-28T16:54:23.123456"
}
```

### GET /api/system
Returns hostname and IP address.

**Response:**
```json
{
  "hostname": "UnuntuVM",
  "ip": "10.0.0.4"
}
```

### GET /api/connection/\<local_port\>/\<remote_port\>
Returns detailed connection and process information.

### DELETE /api/connection/\<local_port\>/\<remote_port\>
Terminates the process associated with a connection.

## Requirements

- Python 3.7+
- psutil 5.9.0+
- Flask 2.3.0+
- flask-cors 4.0.0+

## Security Considerations

- Protected system processes cannot be terminated
- Confirmation dialogs prevent accidental termination
- Remote access mode requires proper firewall configuration
- No authentication implemented - use reverse proxy or VPN for production

## Troubleshooting

### Port Already in Use
Change port in `server.py` or stop conflicting application.

### No Process Information (Linux)
Run with sudo: `sudo python3 server.py` or `sudo bash start_venv.sh`

### Permission Denied (Linux Scripts)
Make executable: `chmod +x start.sh start_venv.sh`

### Debian/Ubuntu pip Error
Use virtual environment launcher: `bash start_venv.sh`

## License

MIT License - see LICENSE file for details.
