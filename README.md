# Plasma 6 Ping Monitor Widget

A simple KDE Plasma 6 widget that displays network ping latency in the panel.

## Features

- Shows ping time in milliseconds in the panel
- Visual indicator with color coding:
  - Green: Excellent latency (< 60ms)
  - Yellow: Medium latency (60-150ms)
  - Red: High latency or error (> 150ms)
- **Ping history graph** with real-time visualization (similar to gping)
  - Line chart showing last 60 measurements
  - Color-coded data points
  - Reference lines at 60ms and 150ms thresholds
  - Auto-scaling based on ping values
- Configurable target host (default: 8.8.8.8)
- Configurable update interval (default: 5 seconds)
- Compact panel representation
- Detailed view with statistics and history chart

## Installation

### Quick Installation (Recommended)

```bash
# Package the widget
./package.sh

# Install the package
kpackagetool6 -t Plasma/Applet -i output/ping-monitor-1.0.plasmoid

# Or to upgrade if already installed:
kpackagetool6 -t Plasma/Applet -u output/ping-monitor-1.0.plasmoid
```

**Note:** If you don't have `zip` installed:
- Ubuntu/Debian: `sudo apt install zip`
- Fedora: `sudo dnf install zip`
- Arch: `sudo pacman -S zip`
- openSUSE: `sudo zypper install zip`

### Method 2: Manual Installation

```bash
# Create the widget directory (replace with your widget ID from metadata.json)
mkdir -p ~/.local/share/plasma/plasmoids/org.kde.plasma.ping

# Copy all files to the widget directory (excluding unnecessary files)
rsync -av --exclude='.git' --exclude='output' --exclude='package.sh' \
    --exclude='*.plasmoid' . ~/.local/share/plasma/plasmoids/org.kde.plasma.ping/

# Restart Plasma Shell
kquitapp6 plasmashell && kstart plasmashell
```

## Usage

1. Right-click on your panel or desktop
2. Select "Add Widgets..."
3. Search for "Ping Monitor"
4. Drag it to your panel

## Configuration

Right-click the widget and select "Configure Ping Monitor" to:
- Change the target host (IP address or domain name)
- Adjust the update interval

## Requirements

- KDE Plasma 6
- `ping` command available in the system
- `zip` command (for packaging only)

## Development

### Building the Package

The `package.sh` script automatically:
- Checks for required dependencies
- Reads version from metadata.json
- Creates a `.plasmoid` package in the `output/` directory
- Excludes development files (.git, output/, etc.)

### Project Structure

```
.
├── metadata.json              # Widget metadata and info
├── contents/
│   ├── ui/
│   │   ├── main.qml          # Main widget logic
│   │   └── configGeneral.qml # Configuration UI
│   └── config/
│       ├── config.qml        # Config structure
│       └── main.xml          # Config schema
├── package.sh                # Packaging script
├── .gitignore               # Git ignore rules
└── README.md                # This file
```

## Technical Details

The widget uses:
- Qt Quick and QML for the interface
- Plasma's DataSource engine to execute ping commands
- KDE's configuration system for settings

## License

This widget is provided as-is for personal use.
