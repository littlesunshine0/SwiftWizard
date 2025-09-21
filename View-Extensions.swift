//
//  View+Extensions.swift
//  AnimatedWizard
//
//  Created by AnimatedWizard Package
//

import SwiftUI

// MARK: - View Extensions

public extension View {
    /// Applies a wizard-style background gradient
    func wizardBackground() -> some View {
        self.background(
            LinearGradient(
                colors: [
                    .blue.opacity(0.1),
                    .purple.opacity(0.05),
                    .clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    /// Applies wizard-style button styling
    func wizardButton(
        style: WizardButtonStyle = .primary,
        isEnabled: Bool = true
    ) -> some View {
        self
            .font(.headline)
            .foregroundColor(style.foregroundColor(isEnabled: isEnabled))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                style.backgroundColor(isEnabled: isEnabled),
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .scaleEffect(isEnabled ? 1.0 : 0.95)
            .opacity(isEnabled ? 1.0 : 0.6)
            .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
    
    /// Applies wizard-style card styling
    func wizardCard(padding: CGFloat = 20) -> some View {
        self
            .padding(padding)
            .background(
                .regularMaterial,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    /// Applies a subtle pulse animation
    func pulseAnimation(isActive: Bool = true) -> some View {
        self.scaleEffect(isActive ? 1.05 : 1.0)
            .animation(
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true),
                value: isActive
            )
    }
    
    /// Adds a subtle shake animation
    func shake(trigger: Bool) -> some View {
        self.offset(x: trigger ? -5 : 0)
            .animation(
                .easeInOut(duration: 0.1)
                .repeatCount(3, autoreverses: true),
                value: trigger
            )
    }
}

// MARK: - Wizard Button Styles

public enum WizardButtonStyle {
    case primary
    case secondary
    case destructive
    case ghost
    
    func backgroundColor(isEnabled: Bool) -> some ShapeStyle {
        guard isEnabled else {
            return AnyShapeStyle(.gray.opacity(0.2))
        }
        
        switch self {
        case .primary:
            return AnyShapeStyle(.blue)
        case .secondary:
            return AnyShapeStyle(.gray.opacity(0.2))
        case .destructive:
            return AnyShapeStyle(.red)
        case .ghost:
            return AnyShapeStyle(.clear)
        }
    }
    
    func foregroundColor(isEnabled: Bool) -> Color {
        guard isEnabled else {
            return .gray
        }
        
        switch self {
        case .primary, .destructive:
            return .white
        case .secondary:
            return .primary
        case .ghost:
            return .blue
        }
    }
}

// MARK: - Progress Indicator

public struct WizardProgressIndicator: View {
    public let currentStep: Int
    public let totalSteps: Int
    public let accentColor: Color
    
    /// Creates a progress indicator for the wizard
    /// - Parameters:
    ///   - currentStep: The current step index (0-based)
    ///   - totalSteps: Total number of steps
    ///   - accentColor: Color for active steps (default: blue)
    public init(
        currentStep: Int,
        totalSteps: Int,
        accentColor: Color = .blue
    ) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.accentColor = accentColor
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? accentColor : accentColor.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(step == currentStep ? 1.2 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: currentStep)
                
                if step < totalSteps - 1 {
                    Rectangle()
                        .fill(step < currentStep ? accentColor : accentColor.opacity(0.3))
                        .frame(width: 16, height: 2)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
        }
    }
}

// MARK: - Confetti Animation

public struct ConfettiView: View {
    @State private var animate = false
    
    public let colors: [Color]
    public let particleCount: Int
    
    /// Creates a confetti animation
    /// - Parameters:
    ///   - colors: Colors for confetti pieces (default: rainbow)
    ///   - particleCount: Number of confetti pieces (default: 12)
    public init(
        colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink],
        particleCount: Int = 12
    ) {
        self.colors = colors
        self.particleCount = particleCount
    }
    
    public var body: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { i in
                ConfettiPiece(
                    color: colors.randomElement() ?? .blue,
                    delay: Double(i) * 0.1
                )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

private struct ConfettiPiece: View {
    let color: Color
    let delay: Double
    
    @State private var animate = false
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .offset(
                x: animate ? CGFloat.random(in: -150...150) : 0,
                y: animate ? CGFloat.random(in: -100...100) : 0
            )
            .opacity(animate ? 0 : 1)
            .scaleEffect(animate ? 0.1 : 1)
            .rotationEffect(.degrees(animate ? 360 : 0))
            .animation(
                .easeOut(duration: 2.0).delay(delay),
                value: animate
            )
            .onAppear {
                animate = true
            }
    }
}

// MARK: - Previews

#if DEBUG
struct ViewExtensions_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Button styles
            VStack(spacing: 16) {
                Button("Primary Button") {}
                    .wizardButton(style: .primary)
                
                Button("Secondary Button") {}
                    .wizardButton(style: .secondary)
                
                Button("Destructive Button") {}
                    .wizardButton(style: .destructive)
                
                Button("Ghost Button") {}
                    .wizardButton(style: .ghost)
                
                Button("Disabled Button") {}
                    .wizardButton(style: .primary, isEnabled: false)
            }
            .padding()
            .wizardBackground()
            .previewDisplayName("Button Styles")
            
            // Progress indicator
            VStack(spacing: 20) {
                WizardProgressIndicator(currentStep: 0, totalSteps: 5)
                WizardProgressIndicator(currentStep: 2, totalSteps: 5)
                WizardProgressIndicator(currentStep: 4, totalSteps: 5)
            }
            .padding()
            .previewDisplayName("Progress Indicator")
            
            // Confetti
            ConfettiView()
                .frame(width: 300, height: 200)
                .background(.black.opacity(0.1))
                .previewDisplayName("Confetti Animation")
            
            // Card styling
            Text("This is a wizard card")
                .wizardCard()
                .padding()
                .wizardBackground()
                .previewDisplayName("Card Style")
        }
    }
}
#endif