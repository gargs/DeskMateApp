# DeskMate

A macOS menubar app to control Home Assistant entities from your desktop. Perfect for managing workspace automations like shutters, lights, and scenes.

## Features

- Menubar-only app (no dock icon)
- Open, close, and stop shutter actions
- Visual feedback on action success/failure
- Launch at login support
- Configuration stored securely outside the app
- Universal binary supporting both Intel and Apple Silicon Macs

## Requirements

- macOS 14.0 (Sonoma) or later
- Home Assistant instance with API access
- Long-Lived Access Token from Home Assistant

## Installation

### Download Pre-built App

1. Download the latest `DeskMate.dmg` from [Releases](https://github.com/gargs/DeskMateApp/releases)
2. Open the DMG and drag `DeskMate.app` to the Applications folder
3. Launch DeskMate from Applications

#### First Launch (Gatekeeper Warning)

Since the app isn't notarized by Apple, you'll see a security warning on first launch. To open it:

**Method 1: Right-click to open**
1. Right-click (or Control-click) on `DeskMate.app` in Applications
2. Select **"Open"** from the menu
3. Click **"Open"** in the dialog

**Method 2: Terminal command**
```bash
xattr -cr /Applications/DeskMate.app
open /Applications/DeskMate.app
```

This only needs to be done once. After that, you can open the app normally.

### Build from Source

1. Clone this repository
2. Open `DeskMate.xcodeproj` in Xcode
3. Build and run (⌘R)

## Configuration

On first launch, the app will create a configuration template at:

```
~/Library/Application Support/DeskMate/config.json
```

Edit this file with your Home Assistant details:

```json
{
  "homeAssistantURL": "http://homeassistant.local:8123",
  "token": "YOUR_LONG_LIVED_ACCESS_TOKEN",
  "entityId": "cover.your_shutter_entity_id"
}
```

### Getting a Long-Lived Access Token

1. Open your Home Assistant instance
2. Click on your profile (bottom left)
3. Scroll down to "Long-Lived Access Tokens"
4. Click "Create Token"
5. Give it a name (e.g., "DeskMate")
6. Copy the token and paste it in the config file

### Finding your Entity ID

1. In Home Assistant, go to Settings → Devices & Services → Entities
2. Search for your shutter/cover device
3. Copy the entity ID (e.g., `cover.living_room_shutter`)

## Usage

Click the window shade icon in the menubar to see available actions:

- **Open Shutter** - Opens the shutter
- **Close Shutter** - Closes the shutter
- **Stop Shutter** - Stops the shutter movement
- **Launch at Login** - Toggle automatic startup on login
- **Open Config Folder** - Opens the configuration directory
- **Reload Configuration** - Reloads the config file
- **Quit** (⌘Q) - Quits the app

## Security

- Your Home Assistant token is stored in `~/Library/Application Support/DeskMate/config.json`
- This file is only readable by your user account
- Never commit your config file to version control

## License

MIT License
