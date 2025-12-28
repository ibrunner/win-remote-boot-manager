# Windows Remote Boot Manager

A lightweight web-based tool to remotely change boot order on Windows machines with multi-boot setups (Windows/Ubuntu). Control which OS boots next from any device with a browser.

## Background

If you dual-boot Windows and Ubuntu, you typically need to be at your computer to select which OS to boot. This tool provides a simple web interface accessible from your phone, tablet, or any other device to change the boot order and reboot into your desired OS remotely.

**Use Cases:**
- Switch to Ubuntu remotely when you need Linux tools
- Boot back to Windows from your phone without physically accessing the machine
- Manage boot order across multiple dual-boot machines from one interface

## How It Works

The tool uses Windows `bcdedit` command to modify UEFI firmware boot order, then reboots the system. A Flask web server provides a browser-accessible interface for triggering these actions.

## Requirements

- Windows 10/11 with UEFI boot (not legacy BIOS)
- Dual-boot setup with Ubuntu (or other Linux distro)
- Administrator privileges
- Python 3.8+ (for running the web server)

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/ibrunner/win-remote-boot-manager.git
cd win-remote-boot-manager
```

### 2. Detect Your Boot Entry UUIDs

Windows and Ubuntu each have unique boot entry identifiers (UUIDs) that vary per installation. You need to find these.

**Run the detection script as administrator:**

1. Navigate to `scripts\detect-boot-entries.bat`
2. Right-click → **Run as administrator**
3. Look for entries like:
   - **Ubuntu**: May appear as "ubuntu" or "Linux Boot Manager"
   - **Windows**: Usually "Windows Boot Manager"
4. Copy the **identifier** (GUID in curly braces, e.g., `{12345678-1234-1234-1234-123456789012}`)

**Example output:**
```
Firmware Boot Manager
---------------------
identifier              {fwbootmgr}

Firmware Application (101fffff)
-------------------------------
identifier              {85e3790e-bc6e-11f0-8f85-dbeafe36350d}
description             ubuntu

Windows Boot Manager
--------------------
identifier              {9dea862c-5cdd-4e70-acc1-f32b344d4795}
description             Windows Boot Manager
```

In this example:
- Ubuntu UUID: `{85e3790e-bc6e-11f0-8f85-dbeafe36350d}`
- Windows UUID: `{9dea862c-5cdd-4e70-acc1-f32b344d4795}`

### 3. Configure Environment Variables

1. Copy the example environment file:
   ```bash
   copy .env.example .env
   ```

2. Edit `.env` and fill in your actual values:
   ```ini
   # Boot Entry UUIDs (from step 2)
   UBUNTU_BOOT_UUID={your-ubuntu-uuid-here}
   WINDOWS_BOOT_UUID={your-windows-uuid-here}

   # Web Server Configuration
   SERVER_HOST=0.0.0.0
   SERVER_PORT=5000

   # Authentication (generate a new token for security)
   AUTH_TOKEN=your-secure-token-here

   # Optional: Restrict to specific IPs
   ALLOWED_IPS=
   ```

3. **Generate a secure auth token** (optional but recommended):
   ```powershell
   # PowerShell
   [Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 }))
   ```

   Or with Python:
   ```bash
   python -c "import secrets; print(secrets.token_urlsafe(32))"
   ```

### 4. Install Dependencies

```bash
# Create virtual environment (recommended)
python -m venv venv
venv\Scripts\activate

# Install required packages
pip install -r requirements.txt
```

### 5. Run the Web Server

```bash
python app.py
```

Access the web interface at: `http://localhost:5000`

From other devices on your network: `http://<your-pc-ip>:5000`

## Remote Access

### Local Network Access

By default, the server is accessible from any device on your local network. Find your PC's IP address:

```powershell
ipconfig | findstr IPv4
```

Then access from your phone/tablet at `http://<pc-ip>:5000`

### Remote Access (Outside Your Network)

For access from anywhere, use one of these options:

**Option 1: Tailscale (Recommended)**
- Free, secure VPN mesh network
- Install Tailscale on your PC and remote devices
- Access via Tailscale IP (e.g., `http://100.x.x.x:5000`)
- [Download Tailscale](https://tailscale.com/download)

**Option 2: Cloudflare Tunnel**
- Free permanent tunnel
- Provides public HTTPS URL
- [Cloudflare Tunnel docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)

**Option 3: ngrok**
- Quick temporary tunnels (good for testing)
- Free tier available
- `ngrok http 5000`

## Security Notes

- **Authentication Required**: The `AUTH_TOKEN` in your `.env` protects against unauthorized access
- **HTTPS Recommended**: Use Tailscale or a reverse proxy for encrypted connections
- **Admin Privileges**: The app needs admin rights to modify boot order
- **IP Whitelisting**: Configure `ALLOWED_IPS` in `.env` to restrict access to specific devices

## Project Structure

```
win-remote-boot-manager/
├── README.md                 # This file
├── .env.example              # Environment variable template
├── .env                      # Your actual config (not in git)
├── requirements.txt          # Python dependencies
├── app.py                    # Flask web server (coming soon)
├── scripts/
│   └── detect-boot-entries.bat   # Helper to find boot UUIDs
├── static/                   # CSS/JavaScript (coming soon)
└── templates/                # HTML templates (coming soon)
```

## Troubleshooting

**"bcdedit is not recognized"**
- Ensure you're on Windows and running with administrator privileges

**"Permission denied" when running bcdedit**
- Right-click the script and select "Run as administrator"

**Can't find Ubuntu entry in bcdedit output**
- Your Ubuntu installation may not have created a UEFI boot entry
- Check your BIOS/UEFI settings to see available boot options

**Web server not accessible from other devices**
- Check Windows Firewall - you may need to allow port 5000
- Verify your PC and device are on the same network
- Try accessing via IP address, not hostname

## Deployment to Other Machines

To use this on another dual-boot machine:

1. Clone the repository
2. Run `scripts\detect-boot-entries.bat` as admin
3. Copy `.env.example` to `.env` and configure with that machine's UUIDs
4. Install dependencies and run

## Future Enhancements

- [ ] Support for multiple boot entries
- [ ] Scheduled boot changes
- [ ] Wake-on-LAN integration
- [ ] Multi-machine dashboard
- [ ] Mobile-optimized UI
- [ ] Windows service for auto-start

## License

MIT

## Contributing

Issues and pull requests welcome!
