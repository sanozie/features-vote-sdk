import Foundation

/// Errors that can occur during API requests
public enum APIError: Error, LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case serverError(statusCode: Int, message: String?)
    case decodingError(String)
    case networkError(String)
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Authentication required. Please check your API key or user credentials."
        case .forbidden:
            return "You don't have permission to perform this action."
        case .notFound:
            return "The requested resource was not found."
        case .serverError(let statusCode, let message):
            return message ?? "Server error (status code: \(statusCode))"
        case .decodingError(let details):
            return "Failed to decode response: \(details)"
        case .networkError(let details):
            return "Network error: \(details)"
        case .unknown(let details):
            return "An unexpected error occurred: \(details)"
        }
    }

    /// Whether this error indicates a network connectivity issue
    public var isNetworkError: Bool {
        if case .networkError = self {
            return true
        }
        return false
    }

    /// Whether this error indicates an authentication issue
    public var isAuthenticationError: Bool {
        switch self {
        case .unauthorized, .forbidden:
            return true
        default:
            return false
        }
    }

    public static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.unauthorized, .unauthorized),
             (.forbidden, .forbidden),
             (.notFound, .notFound):
            return true
        case (.serverError(let lCode, let lMsg), .serverError(let rCode, let rMsg)):
            return lCode == rCode && lMsg == rMsg
        case (.decodingError(let lDetails), .decodingError(let rDetails)):
            return lDetails == rDetails
        case (.networkError(let lDetails), .networkError(let rDetails)):
            return lDetails == rDetails
        case (.unknown(let lDetails), .unknown(let rDetails)):
            return lDetails == rDetails
        default:
            return false
        }
    }
}

extension APIError {
    /// Create an APIError from HTTP status code
    static func from(statusCode: Int, message: String? = nil) -> APIError {
        switch statusCode {
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 400...499:
            return .serverError(statusCode: statusCode, message: message ?? "Client error")
        case 500...599:
            return .serverError(statusCode: statusCode, message: message ?? "Server error")
        default:
            return .unknown("HTTP status code: \(statusCode)")
        }
    }

    /// Create an APIError from URLError
    static func from(_ urlError: URLError) -> APIError {
        switch urlError.code {
        case .notConnectedToInternet,
             .networkConnectionLost,
             .timedOut:
            return .networkError(urlError.localizedDescription)
        default:
            return .networkError(urlError.localizedDescription)
        }
    }
}
