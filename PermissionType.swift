//
//  PermissionType.swift
//  AnimatedWizard
//
//  Created by AnimatedWizard Package
//

import SwiftUI

/// Represents different types of permissions that can be requested
public enum PermissionType: String, CaseIterable, Identifiable {
    case camera = "camera"
    case location = "location"
    case notifications = "notifications"
    case microphone = "microphone"
    case photos = "photos"
    case contacts = "contacts"
    case calendar = "calendar"
    case reminders = "reminders"
    case faceID = "faceid"
    case touchID = "touchid"
    
    public var id: String { rawValue }
    
    /// SF Symbol name for this permission type
    public var systemImage: String {
        switch self {
        case .camera:
            return "camera.fill"
        case .location:
            return "location.fill"
        case .notifications:
            return "bell.fill"
        case .microphone:
            return "mic.fill"
        case .photos:
            return "photo.fill"
        case .contacts:
            return "person.fill"
        case .calendar:
            return "calendar"
        case .reminders:
            return "checklist"
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        }
    }
    
    /// Display color for this permission type
    public var color: Color {
        switch self {
        case .camera:
            return .blue
        case .location:
            return .green
        case .notifications:
            return .orange
        case .microphone:
            return .red
        case .photos:
            return .purple
        case .contacts:
            return .teal
        case .calendar:
            return .indigo
        case .reminders:
            return .pink
        case .faceID, .touchID:
            return .mint
        }
    }
    
    /// Human-readable title for this permission
    public var title: String {
        switch self {
        case .camera:
            return "Camera Access"
        case .location:
            return "Location Services"
        case .notifications:
            return "Notifications"
        case .microphone:
            return "Microphone Access"
        case .photos:
            return "Photos Access"
        case .contacts:
            return "Contacts Access"
        case .calendar:
            return "Calendar Access"
        case .reminders:
            return "Reminders Access"
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        }
    }
    
    /// Default description text for this permission
    public var defaultDescription: String {
        switch self {
        case .camera:
            return "We need camera access to take photos and scan documents."
        case .location:
            return "Location helps us provide location-based features and suggestions."
        case .notifications:
            return "Stay up-to-date with important updates and reminders."
        case .microphone:
            return "Microphone access enables voice features and audio recording."
        case .photos:
            return "Access your photo library to select and save images."
        case .contacts:
            return "Contacts access helps you share and collaborate with others."
        case .calendar:
            return "Calendar integration helps you schedule and manage events."
        case .reminders:
            return "Reminders integration helps you stay organized and on track."
        case .faceID:
            return "Use Face ID for secure and convenient authentication."
        case .touchID:
            return "Use Touch ID for secure and convenient authentication."
        }
    }
}

/// Represents the current state of a permission request
public enum PermissionState: String, CaseIterable {
    case requesting = "requesting"
    case approved = "approved" 
    case denied = "denied"
    
    /// Whether this state represents a granted permission
    public var isGranted: Bool {
        return self == .approved
    }
}

/// A permission request combining type and state
public struct PermissionRequest: Identifiable, Equatable {
    public let id = UUID()
    public let type: PermissionType
    public var state: PermissionState
    public let customTitle: String?
    public let customDescription: String?
    
    public init(
        type: PermissionType,
        state: PermissionState = .requesting,
        customTitle: String? = nil,
        customDescription: String? = nil
    ) {
        self.type = type
        self.state = state
        self.customTitle = customTitle
        self.customDescription = customDescription
    }
    
    /// The display title for this permission request
    public var displayTitle: String {
        return customTitle ?? type.title
    }
    
    /// The display description for this permission request
    public var displayDescription: String {
        return customDescription ?? type.defaultDescription
    }
}