import Foundation

enum HomeAssistantError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case apiError(String)
    case configurationMissing

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Home Assistant URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from Home Assistant"
        case .apiError(let message):
            return "API error: \(message)"
        case .configurationMissing:
            return "Configuration file not found"
        }
    }
}

class HomeAssistantClient {
    private let baseURL: String
    private let token: String
    private let entityId: String

    init?(configuration: AppConfiguration? = nil) {
        guard let config = configuration ?? AppConfiguration.load() else {
            return nil
        }

        self.baseURL = config.homeAssistantURL
        self.token = config.token
        self.entityId = config.entityId
    }

    func openCover() async throws {
        try await callService(domain: "cover", service: "open_cover")
    }

    func closeCover() async throws {
        try await callService(domain: "cover", service: "close_cover")
    }

    func stopCover() async throws {
        try await callService(domain: "cover", service: "stop_cover")
    }

    private func callService(domain: String, service: String) async throws {
        let urlString = "\(baseURL)/api/services/\(domain)/\(service)"

        guard let url = URL(string: urlString) else {
            throw HomeAssistantError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "entity_id": entityId
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw HomeAssistantError.invalidResponse
            }

            if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                print("Successfully called \(service) on \(entityId)")
                return
            }

            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = errorJson["message"] as? String {
                throw HomeAssistantError.apiError(message)
            }

            throw HomeAssistantError.apiError("HTTP \(httpResponse.statusCode)")
        } catch let error as HomeAssistantError {
            throw error
        } catch {
            throw HomeAssistantError.networkError(error)
        }
    }
}
