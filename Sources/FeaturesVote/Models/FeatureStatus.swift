import Foundation
import SwiftUI

/// Status of a feature request
public enum FeatureStatus: String, Codable, CaseIterable, Identifiable {
    case pending = "Pending"
    case approved = "Approved"
    case inProgress = "In Progress"
    case done = "Done"
    case rejected = "Rejected"

    public var id: String { rawValue }

    /// Display name for the status
    public var displayName: String {
        rawValue
    }

    /// Icon name for the status
    public var iconName: String {
        switch self {
        case .pending:
            return "clock"
        case .approved:
            return "checkmark.circle"
        case .inProgress:
            return "hammer"
        case .done:
            return "checkmark.circle.fill"
        case .rejected:
            return "xmark.circle"
        }
    }
}

extension FeatureStatus {
    /// Initialize from API string (handles typo "in_progres")
    init?(apiValue: String) {
        switch apiValue {
        case "Pending":
            self = .pending
        case "Approved":
            self = .approved
        case "In Progress", "in_progres": // Handle API typo
            self = .inProgress
        case "Done":
            self = .done
        case "Rejected":
            self = .rejected
        default:
            return nil
        }
    }

    /// Whether this status represents an open (non-completed) feature
    public var isOpen: Bool {
        self != .done && self != .rejected
    }
}
