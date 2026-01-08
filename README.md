# Plasma 6 Ping Monitor Widget

A simple KDE Plasma 6 widget that displays network ping latency in the panel.

## Features

- Shows ping time in milliseconds
- Visual indicator with color coding:
  - Green: Good latency (< 100ms)
  - Yellow: Medium latency (> 100ms)
  - Red: Error or timeout
- Configurable target host (default: 8.8.8.8)
- Configurable update interval (default: 5 seconds)
- Compact panel representation
- Detailed view on click

## Installation

### Method 1: Manual Installation

```bash
# Create the widget directory
mkdir -p ~/.local/share/plasma/plasmoids/org.kde.plasma.ping

# Copy all files to the widget directory
cp -r * ~/.local/share/plasma/plasmoids/org.kde.plasma.ping/

# Restart Plasma Shell
kquitapp6 plasmashell && kstart5 plasmashell
```

### Method 2: Using plasmapkg2

```bash
# Package the widget
cd ..
zip -r ping-widget.plasmoid custom/*

# Install the package
kpackagetool6 -t Plasma/Applet -i ping-widget.plasmoid

# Or to upgrade if already installed:
kpackagetool6 -t Plasma/Applet -u ping-widget.plasmoid
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

## Technical Details

The widget uses:
- Qt Quick and QML for the interface
- Plasma's DataSource engine to execute ping commands
- KDE's configuration system for settings

## License

This widget is provided as-is for personal use.
