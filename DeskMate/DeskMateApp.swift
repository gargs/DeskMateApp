import SwiftUI
import ServiceManagement

@main
struct DeskMateApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var homeAssistant: HomeAssistantClient?
    private var isConfigured: Bool = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "window.shade.open", accessibilityDescription: "DeskMate")
        }

        loadConfiguration()
    }

    private func loadConfiguration() {
        if let client = HomeAssistantClient() {
            homeAssistant = client
            isConfigured = true
            setupMenu()
        } else {
            isConfigured = false
            AppConfiguration.createTemplate()
            setupUnconfiguredMenu()
        }
    }

    private var isLaunchAtLoginEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    private func setupMenu() {
        let menu = NSMenu()

        let openItem = NSMenuItem(title: "Open Shutter", action: #selector(openShutter), keyEquivalent: "")
        openItem.target = self
        openItem.image = NSImage(systemSymbolName: "window.shade.open", accessibilityDescription: nil)
        menu.addItem(openItem)

        let closeItem = NSMenuItem(title: "Close Shutter", action: #selector(closeShutter), keyEquivalent: "")
        closeItem.target = self
        closeItem.image = NSImage(systemSymbolName: "window.shade.closed", accessibilityDescription: nil)
        menu.addItem(closeItem)

        let stopItem = NSMenuItem(title: "Stop Shutter", action: #selector(stopShutter), keyEquivalent: "")
        stopItem.target = self
        stopItem.image = NSImage(systemSymbolName: "stop.fill", accessibilityDescription: nil)
        menu.addItem(stopItem)

        menu.addItem(NSMenuItem.separator())

        let launchAtLoginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchAtLoginItem.target = self
        launchAtLoginItem.state = isLaunchAtLoginEnabled ? .on : .off
        menu.addItem(launchAtLoginItem)

        menu.addItem(NSMenuItem.separator())

        let configItem = NSMenuItem(title: "Open Config Folder", action: #selector(openConfigFolder), keyEquivalent: "")
        configItem.target = self
        menu.addItem(configItem)

        let reloadItem = NSMenuItem(title: "Reload Configuration", action: #selector(reloadConfiguration), keyEquivalent: "")
        reloadItem.target = self
        menu.addItem(reloadItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func setupUnconfiguredMenu() {
        let menu = NSMenu()

        let infoItem = NSMenuItem(title: "Configuration Required", action: nil, keyEquivalent: "")
        infoItem.isEnabled = false
        menu.addItem(infoItem)

        menu.addItem(NSMenuItem.separator())

        let launchAtLoginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchAtLoginItem.target = self
        launchAtLoginItem.state = isLaunchAtLoginEnabled ? .on : .off
        menu.addItem(launchAtLoginItem)

        menu.addItem(NSMenuItem.separator())

        let configItem = NSMenuItem(title: "Open Config Folder", action: #selector(openConfigFolder), keyEquivalent: "")
        configItem.target = self
        menu.addItem(configItem)

        let reloadItem = NSMenuItem(title: "Reload Configuration", action: #selector(reloadConfiguration), keyEquivalent: "")
        reloadItem.target = self
        menu.addItem(reloadItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)

        statusItem.menu = menu

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: "Configuration Required")
        }
    }

    @objc private func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        do {
            if isLaunchAtLoginEnabled {
                try SMAppService.mainApp.unregister()
                sender.state = .off
            } else {
                try SMAppService.mainApp.register()
                sender.state = .on
            }
        } catch {
            print("Failed to toggle launch at login: \(error)")
        }
    }

    @objc private func openConfigFolder() {
        NSWorkspace.shared.open(AppConfiguration.configDirectory)
    }

    @objc private func reloadConfiguration() {
        loadConfiguration()
        Task { @MainActor in
            if self.isConfigured {
                self.showFeedback(success: true, action: "Configured")
            } else {
                self.showFeedback(success: false, action: "Configure")
            }
        }
    }

    @objc private func openShutter() {
        guard let client = homeAssistant else { return }
        Task {
            do {
                try await client.openCover()
                await showFeedback(success: true, action: "Opening")
            } catch {
                await showFeedback(success: false, action: "Open")
                print("Failed to open shutter: \(error)")
            }
        }
    }

    @objc private func closeShutter() {
        guard let client = homeAssistant else { return }
        Task {
            do {
                try await client.closeCover()
                await showFeedback(success: true, action: "Closing")
            } catch {
                await showFeedback(success: false, action: "Close")
                print("Failed to close shutter: \(error)")
            }
        }
    }

    @objc private func stopShutter() {
        guard let client = homeAssistant else { return }
        Task {
            do {
                try await client.stopCover()
                await showFeedback(success: true, action: "Stopping")
            } catch {
                await showFeedback(success: false, action: "Stop")
                print("Failed to stop shutter: \(error)")
            }
        }
    }

    @MainActor
    private func showFeedback(success: Bool, action: String) {
        if let button = statusItem.button {
            let originalImage = button.image

            if success {
                button.image = NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: "\(action) shutter")
            } else {
                button.image = NSImage(systemSymbolName: "xmark.circle.fill", accessibilityDescription: "Failed to \(action.lowercased()) shutter")
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                button.image = originalImage
            }
        }
    }
}
