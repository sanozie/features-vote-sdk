import Foundation

/// Protocol for API client to allow for mocking in tests
public protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func request<T: Decodable>(_ endpoint: APIEndpoint, body: Encodable) async throws -> T
    func upload<T: Decodable>(_ endpoint: APIEndpoint, formData: MultipartFormData) async throws -> T
    func requestString(_ endpoint: APIEndpoint, body: Encodable) async throws -> String
    func uploadString(_ endpoint: APIEndpoint, formData: MultipartFormData) async throws -> String
}

/// Main API client for making requests to Features.Vote API
public final class APIClient: APIClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    public init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()

        // Configure date decoding
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try ISO8601 with milliseconds
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: dateString) {
                return date
            }

            // Try ISO8601 without milliseconds
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateString) {
                return date
            }

            // Try standard date formatter
            let standardFormatter = DateFormatter()
            standardFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let date = standardFormatter.date(from: dateString) {
                return date
            }

            // Fallback
            standardFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let date = standardFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date string: \(dateString)"
            )
        }
    }

    // MARK: - Public Methods

    /// Make a GET request
    public func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return try await performRequest(request)
    }

    /// Make a POST request with JSON body
    public func request<T: Decodable>(_ endpoint: APIEndpoint, body: Encodable) async throws -> T {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try encoder.encode(body)
        } catch {
            throw APIError.unknown("Failed to encode request body: \(error.localizedDescription)")
        }

        return try await performRequest(request)
    }

    /// Make a POST request with multipart form data
    public func upload<T: Decodable>(_ endpoint: APIEndpoint, formData: MultipartFormData) async throws -> T {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = formData.finalize()

        return try await performRequest(request)
    }

    /// Make a POST request with JSON body and return raw string response
    public func requestString(_ endpoint: APIEndpoint, body: Encodable) async throws -> String {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try encoder.encode(body)
        } catch {
            throw APIError.unknown("Failed to encode request body: \(error.localizedDescription)")
        }

        return try await performStringRequest(request)
    }

    /// Make a POST request with multipart form data and return raw string response
    public func uploadString(_ endpoint: APIEndpoint, formData: MultipartFormData) async throws -> String {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = formData.finalize()

        return try await performStringRequest(request)
    }

    // MARK: - Private Methods

    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        FVLog.request(
            method: request.httpMethod ?? "UNKNOWN",
            url: request.url?.absoluteString ?? "no URL"
        )

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        FVLog.response(
            statusCode: httpResponse.statusCode,
            url: request.url?.absoluteString ?? "",
            bytes: data.count
        )

        #if DEBUG
        if let responseString = String(data: data, encoding: .utf8) {
            FVLog.debug("Response body: \(String(responseString.prefix(500)))", category: .network)
        }
        #endif

        try validateResponse(httpResponse, data: data)

        // Handle empty responses
        if data.isEmpty {
            FVLog.warning("Empty response received", category: .network)
            // For arrays, return empty array
            let typeString = String(describing: T.self)
            if typeString.hasPrefix("Array<") || typeString.hasPrefix("Swift.Array<") {
                guard let emptyArrayData = "[]".data(using: .utf8) else {
                    throw APIError.decodingError("Failed to create empty array data")
                }
                return try decoder.decode(T.self, from: emptyArrayData)
            }
            // For other types, provide a more descriptive error
            throw APIError.decodingError("Empty response body received from server. Expected type: \(typeString)")
        }

        do {
            let result = try decoder.decode(T.self, from: data)
            FVLog.debug("Successfully decoded \(T.self)", category: .network)
            return result
        } catch let decodingError as DecodingError {
            // Provide more detailed error information
            let errorDescription: String
            switch decodingError {
            case .dataCorrupted(let context):
                errorDescription = "Data corrupted: \(context.debugDescription)"
            case .keyNotFound(let key, let context):
                errorDescription = "Key '\(key.stringValue)' not found: \(context.debugDescription)"
            case .typeMismatch(let type, let context):
                errorDescription = "Type mismatch for type \(type): \(context.debugDescription)"
            case .valueNotFound(let type, let context):
                errorDescription = "Value not found for type \(type): \(context.debugDescription)"
            @unknown default:
                errorDescription = decodingError.localizedDescription
            }
            
            // Include raw response for debugging
            let rawResponse = String(data: data, encoding: .utf8) ?? "<non-UTF8 data>"
            throw APIError.decodingError("\(errorDescription). Raw response: \(rawResponse.prefix(500))")
        } catch {
            throw APIError.decodingError(error.localizedDescription)
        }
    }

    private func performStringRequest(_ request: URLRequest) async throws -> String {
        FVLog.request(
            method: request.httpMethod ?? "UNKNOWN",
            url: request.url?.absoluteString ?? "no URL"
        )

        #if DEBUG
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            FVLog.debug("Request body: \(bodyString)", category: .network)
        }
        #endif

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            FVLog.error("Invalid response - not an HTTPURLResponse", category: .network)
            throw APIError.invalidResponse
        }

        FVLog.response(
            statusCode: httpResponse.statusCode,
            url: request.url?.absoluteString ?? "",
            bytes: data.count
        )

        #if DEBUG
        if let responseString = String(data: data, encoding: .utf8) {
            FVLog.debug("Response body: \(responseString)", category: .network)
        }
        #endif

        do {
            try validateResponse(httpResponse, data: data)
        } catch {
            FVLog.error(error, message: "API request failed", category: .network)
            throw error
        }

        guard let string = String(data: data, encoding: .utf8) else {
            FVLog.error("Failed to decode response as UTF-8 string", category: .network)
            throw APIError.decodingError("Failed to decode response as string")
        }

        return string
    }

    private func validateResponse(_ response: HTTPURLResponse, data: Data) throws {
        guard (200...299).contains(response.statusCode) else {
            // Try to extract error message from response
            var errorMessage: String?
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = json["message"] as? String {
                errorMessage = message
            } else if let message = String(data: data, encoding: .utf8), !message.isEmpty {
                errorMessage = message
            }

            throw APIError.from(statusCode: response.statusCode, message: errorMessage)
        }
    }
}

// MARK: - Completion Handler Wrappers

extension APIClient {
    /// Make a GET request with completion handler
    @available(*, deprecated, message: "Use async/await version instead")
    public func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        Task {
            do {
                let result: T = try await request(endpoint)
                completion(.success(result))
            } catch let error as APIError {
                completion(.failure(error))
            } catch {
                completion(.failure(.unknown(error.localizedDescription)))
            }
        }
    }

    /// Make a POST request with JSON body using completion handler
    @available(*, deprecated, message: "Use async/await version instead")
    public func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        body: Encodable,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        Task {
            do {
                let result: T = try await request(endpoint, body: body)
                completion(.success(result))
            } catch let error as APIError {
                completion(.failure(error))
            } catch {
                completion(.failure(.unknown(error.localizedDescription)))
            }
        }
    }
}
