import Foundation

struct AppConfiguration: Codable {
    let homeAssistantURL: String
    let token: String
    let entityId: String

    static let configFileName = "config.json"

    static var configDirectory: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupport.appendingPathComponent("DeskMate", isDirectory: true)
    }

    static var configFileURL: URL {
        configDirectory.appendingPathComponent(configFileName)
    }

    static func load() -> AppConfiguration? {
        let fileURL = configFileURL

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let config = try JSONDecoder().decode(AppConfiguration.self, from: data)
            return config
        } catch {
            print("Failed to load configuration: \(error)")
            return nil
        }
    }

    static func createTemplate() {
        let template = AppConfiguration(
            homeAssistantURL: "http://homeassistant.local:8123",
            token: "YOUR_LONG_LIVED_ACCESS_TOKEN",
            entityId: "cover.your_shutter_entity_id"
        )

        do {
            try FileManager.default.createDirectory(at: configDirectory, withIntermediateDirectories: true)
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(template)
            try data.write(to: configFileURL)
            print("Created configuration template at: \(configFileURL.path)")
        } catch {
            print("Failed to create configuration template: \(error)")
        }
    }
}
