//
//  MascotEmotion.swift
//  AnimatedWizard
//
//  Created by AnimatedWizard Package
//

import SwiftUI

/// Represents different emotional states for the wizard mascot
public enum MascotEmotion: CaseIterable, Identifiable {
    case happy
    case excited
    case thinking
    case celebrating
    case sad
    case neutral
    
    public var id: String { "\(self)" }
    
    /// The eye shape for this emotion
    var eyeShape: String {
        switch self {
        case .happy, .excited, .celebrating, .neutral:
            return "circle.fill"
        case .thinking:
            return "circle"
        case .sad:
            return "oval"
        }
    }
    
    /// The mouth curve amount for this emotion
    var mouthCurve: CGFloat {
        switch self {
        case .happy, .excited:
            return 20
        case .celebrating:
            return 30
        case .thinking, .neutral:
            return 0
        case .sad:
            return -15
        }
    }
    
    /// Whether this emotion should show a waving animation
    var shouldWave: Bool {
        switch self {
        case .happy, .excited, .celebrating:
            return true
        default:
            return false
        }
    }
    
    /// The bounce intensity for this emotion
    var bounceIntensity: CGFloat {
        switch self {
        case .celebrating:
            return -12
        case .excited:
            return -8
        case .happy:
            return -5
        default:
            return -3
        }
    }
    
    /// Speech text for the mascot in this emotional state
    public func speechText(for context: String = "") -> String {
        switch self {
        case .happy:
            return context.isEmpty ? "Welcome! Let's set up your app together!" : "Great! \(context)"
        case .excited:
            return context.isEmpty ? "Awesome! You're doing great!" : "Perfect! \(context)"
        case .thinking:
            return context.isEmpty ? "Hmm... let me think about this..." : "Let's see... \(context)"
        case .celebrating:
            return context.isEmpty ? "Fantastic! All set up!" : "Amazing! \(context)"
        case .sad:
            return context.isEmpty ? "Oh no! Let's try that again..." : "Oops! \(context)"
        case .neutral:
            return context.isEmpty ? "Hello there!" : context
        }
    }
}