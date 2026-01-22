import Foundation
import os.log

/// Internal logging utility for the FeaturesVote SDK.
///
/// Uses Apple's unified logging system (os.log) for efficient, privacy-aware logging
/// that integrates with Console.app and Instruments.
///
/// Logs are only emitted in DEBUG builds by default. In release builds, only errors
/// are logged to avoid performance impact and information leakage.
internal enum FVLog {

    // MARK: - Log Categories

    /// Subsystem identifier for all FeaturesVote logs
    private static let subsystem = "com.featuresvote.sdk"

    /// Logger for network operations
    private static let networkLogger = Logger(subsystem: subsystem, category: "network")

    /// Logger for UI operations
    private static let uiLogger = Logger(subsystem: subsystem, category: "ui")

    /// Logger for data/model operations
    private static let dataLogger = Logger(subsystem: subsystem, category: "data")

    /// Logger for general SDK operations
    private static let generalLogger = Logger(subsystem: subsystem, category: "general")

    // MARK: - Log Levels

    /// Log level for controlling output verbosity
    internal enum Level: Int, Comparable {
        case debug = 0
        case info = 1
        case warning = 2
        case error = 3
        case none = 4

        static func < (lhs: Level, rhs: Level) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    /// Current log level. Set to `.none` in release builds.
    #if DEBUG
    internal static var logLevel: Level = .debug
    #else
    internal static var logLevel: Level = .error
    #endif

    // MARK: - Category Types

    /// Log categories for different SDK components
    internal enum Category {
        case network
        case ui
        case data
        case general

        fileprivate var logger: Logger {
            switch self {
            case .network: return networkLogger
            case .ui: return uiLogger
            case .data: return dataLogger
            case .general: return generalLogger
            }
        }
    }

    // MARK: - Logging Methods

    /// Log a debug message (verbose, for development only)
    /// - Parameters:
    ///   - message: The message to log
    ///   - category: The log category
    ///   - file: Source file (auto-populated)
    ///   - function: Function name (auto-populated)
    ///   - line: Line number (auto-populated)
    internal static func debug(
        _ message: @autoclosure () -> String,
        category: Category = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard logLevel <= .debug else { return }
        let msg = message()
        let context = formatContext(file: file, function: function, line: line)
        category.logger.debug("[\(context)] \(msg)")
    }

    /// Log an info message (general information)
    /// - Parameters:
    ///   - message: The message to log
    ///   - category: The log category
    ///   - file: Source file (auto-populated)
    ///   - function: Function name (auto-populated)
    ///   - line: Line number (auto-populated)
    internal static func info(
        _ message: @autoclosure () -> String,
        category: Category = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard logLevel <= .info else { return }
        let msg = message()
        let context = formatContext(file: file, function: function, line: line)
        category.logger.info("[\(context)] \(msg)")
    }

    /// Log a warning message (potential issues)
    /// - Parameters:
    ///   - message: The message to log
    ///   - category: The log category
    ///   - file: Source file (auto-populated)
    ///   - function: Function name (auto-populated)
    ///   - line: Line number (auto-populated)
    internal static func warning(
        _ message: @autoclosure () -> String,
        category: Category = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard logLevel <= .warning else { return }
        let msg = message()
        let context = formatContext(file: file, function: function, line: line)
        category.logger.warning("[\(context)] \(msg)")
    }

    /// Log an error message (failures and errors)
    /// - Parameters:
    ///   - message: The message to log
    ///   - category: The log category
    ///   - file: Source file (auto-populated)
    ///   - function: Function name (auto-populated)
    ///   - line: Line number (auto-populated)
    internal static func error(
        _ message: @autoclosure () -> String,
        category: Category = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard logLevel <= .error else { return }
        let msg = message()
        let context = formatContext(file: file, function: function, line: line)
        category.logger.error("[\(context)] \(msg)")
    }

    /// Log an error with an Error object
    /// - Parameters:
    ///   - error: The error object
    ///   - message: Additional context message
    ///   - category: The log category
    ///   - file: Source file (auto-populated)
    ///   - function: Function name (auto-populated)
    ///   - line: Line number (auto-populated)
    internal static func error(
        _ error: Error,
        message: String? = nil,
        category: Category = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard logLevel <= .error else { return }
        let context = formatContext(file: file, function: function, line: line)
        let errorMessage = message.map { "\($0): " } ?? ""
        category.logger.error("[\(context)] \(errorMessage)\(error.localizedDescription)")
    }

    // MARK: - Convenience Methods for Network Logging

    /// Log an API request
    internal static func request(
        method: String,
        url: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        debug("Request: \(method) \(url)", category: .network, file: file, function: function, line: line)
    }

    /// Log an API response
    internal static func response(
        statusCode: Int,
        url: String,
        bytes: Int,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        debug("Response: \(statusCode) \(url) (\(bytes) bytes)", category: .network, file: file, function: function, line: line)
    }

    // MARK: - Private Helpers

    private static func formatContext(file: String, function: String, line: Int) -> String {
        let fileName = URL(fileURLWithPath: file).deletingPathExtension().lastPathComponent
        return "\(fileName).\(function):\(line)"
    }
}

// MARK: - Public Configuration

extension FeaturesVote {
    /// Log level for controlling SDK logging verbosity
    public enum LogLevel: Int {
        /// Log all messages including debug information
        case debug = 0
        /// Log informational messages and above
        case info = 1
        /// Log warnings and errors only
        case warning = 2
        /// Log errors only
        case error = 3
        /// Disable all logging
        case none = 4

        internal var toInternal: FVLog.Level {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .warning
            case .error: return .error
            case .none: return .none
            }
        }
    }

    /// Enable or disable SDK debug logging.
    ///
    /// By default, logging is enabled in DEBUG builds and disabled in release builds.
    /// Call this method to override the default behavior.
    ///
    /// - Parameter enabled: Whether to enable debug logging
    ///
    /// Example:
    /// ```swift
    /// // Enable verbose logging for debugging
    /// FeaturesVote.setLoggingEnabled(true)
    ///
    /// // Disable all logging
    /// FeaturesVote.setLoggingEnabled(false)
    /// ```
    public static func setLoggingEnabled(_ enabled: Bool) {
        FVLog.logLevel = enabled ? .debug : .none
    }

    /// Set the minimum log level for SDK logging.
    ///
    /// - Parameter level: The minimum level to log (debug, info, warning, error, none)
    ///
    /// Example:
    /// ```swift
    /// // Only log warnings and errors
    /// FeaturesVote.setLogLevel(.warning)
    /// ```
    public static func setLogLevel(_ level: LogLevel) {
        FVLog.logLevel = level.toInternal
    }
}
