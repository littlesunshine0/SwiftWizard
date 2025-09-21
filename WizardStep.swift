//
//  WizardStep.swift
//  AnimatedWizard
//
//  Created by AnimatedWizard Package
//

import Foundation

/// Represents a step in the onboarding wizard flow
public enum WizardStep: Identifiable, Equatable {
    case welcome(title: String?, subtitle: String?)
    case permission(PermissionRequest)
    case summary
    case thankyou(title: String?, subtitle: String?)
    case denied(message: String?)
    case custom(id: String, title: String, content: String)
    
    public var id: String {
        switch self {
        case .welcome:
            return "welcome"
        case .permission(let request):
            return "permission_\(request.type.rawValue)"
        case .summary:
            return "summary"
        case .thankyou:
            return "thankyou"
        case .denied:
            return "denied"
        case .custom(let id, _, _):
            return "custom_\(id)"
        }
    }
    
    /// The mascot emotion for this wizard step
    public var mascotEmotion: MascotEmotion {
        switch self {
        case .welcome:
            return .happy
        case .permission:
            return .thinking
        case .summary:
            return .excited
        case .thankyou:
            return .celebrating
        case .denied:
            return .sad
        case .custom:
            return .neutral
        }
    }
    
    /// Whether this step can be skipped
    public var isSkippable: Bool {
        switch self {
        case .permission:
            return true
        case .custom:
            return true
        default:
            return false
        }
    }
    
    /// Whether this step represents a completion state
    public var isTerminal: Bool {
        switch self {
        case .thankyou, .denied:
            return true
        default:
            return false
        }
    }
}

/// Configuration for the wizard flow
public struct WizardConfiguration {
    public let steps: [WizardStep]
    public let allowSkipping: Bool
    public let showProgressIndicator: Bool
    public let mascotEnabled: Bool
    public let animationsEnabled: Bool
    
    public init(
        steps: [WizardStep],
        allowSkipping: Bool = true,
        showProgressIndicator: Bool = true,
        mascotEnabled: Bool = true,
        animationsEnabled: Bool = true
    ) {
        self.steps = steps
        self.allowSkipping = allowSkipping
        self.showProgressIndicator = showProgressIndicator
        self.mascotEnabled = mascotEnabled
        self.animationsEnabled = animationsEnabled
    }
    
    /// Creates a default configuration with common permissions
    public static func `default`() -> WizardConfiguration {
        let permissions: [PermissionType] = [.camera, .location, .notifications]
        let steps: [WizardStep] = [
            .welcome(title: nil, subtitle: nil)
        ] + permissions.map { .permission(PermissionRequest(type: $0)) } + [
            .summary,
            .thankyou(title: nil, subtitle: nil)
        ]
        
        return WizardConfiguration(steps: steps)
    }
    
    /// Creates a minimal configuration with just welcome and thank you
    public static func minimal() -> WizardConfiguration {
        return WizardConfiguration(
            steps: [
                .welcome(title: "Welcome!", subtitle: "Let's get started"),
                .thankyou(title: "All Set!", subtitle: "You're ready to go")
            ]
        )
    }
}