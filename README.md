# DeskMate

A macOS menubar app to control Home Assistant entities from your desktop. Perfect for managing workspace automations like shutters, lights, and scenes.

## Features

- Menubar-only app (no dock icon)
- Open, close, and stop shutter actions
- Visual feedback on action success/failure
- Launch at login support
- Configuration stored securely outside the app

## Requirements

- macOS 14.0 (Sonoma) or later
- Home Assistant instance with API access
- Long-Lived Access Token from Home Assistant

## Installation

### Option 1: Build from source

1. Clone this repository
2. Open `DeskMate.xcodeproj` in Xcode
3. Build and run (⌘R)

### Option 2: Use pre-built app

1. Download the latest release
2. Move `DeskMate.app` to `/Applications`

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
