//
//  WizardMascot.swift
//  AnimatedWizard
//
//  Created by AnimatedWizard Package
//

import SwiftUI

/// An animated mascot character for the wizard
public struct WizardMascot: View {
    @State private var isWaving = false
    @State private var isBlinking = false
    @State private var bounceOffset: CGFloat = 0
    @State private var speechBubbleVisible = false
    
    public let emotion: MascotEmotion
    public let speechText: String?
    public let size: CGFloat
    public let colors: [Color]
    
    /// Creates a new wizard mascot
    /// - Parameters:
    ///   - emotion: The emotional state of the mascot
    ///   - speechText: Optional custom speech text (uses emotion default if nil)
    ///   - size: The size of the mascot (default: 120)
    ///   - colors: Gradient colors for the mascot body (default: blue to purple)
    public init(
        emotion: MascotEmotion,
        speechText: String? = nil,
        size: CGFloat = 120,
        colors: [Color] = [.blue.opacity(0.8), .purple.opacity(0.6)]
    ) {
        self.emotion = emotion
        self.speechText = speechText
        self.size = size
        self.colors = colors
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            // Main mascot body
            ZStack {
                // Body circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    .offset(y: bounceOffset)
                
                // Face elements
                VStack(spacing: size * 0.1) {
                    // Eyes
                    HStack(spacing: size * 0.16) {
                        ForEach(0..<2, id: \.self) { _ in
                            Image(systemName: emotion.eyeShape)
                                .font(.system(size: size * 0.2, weight: .semibold))
                                .foregroundColor(.white)
                                .scaleEffect(isBlinking ? 0.1 : 1.0)
                                .animation(.easeInOut(duration: 0.15), value: isBlinking)
                        }
                    }
                    
                    // Mouth
                    Path { path in
                        let width: CGFloat = size * 0.33
                        let center = CGPoint(x: width / 2, y: 0)
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addQuadCurve(
                            to: CGPoint(x: width, y: 0),
                            control: CGPoint(x: center.x, y: emotion.mouthCurve)
                        )
                    }
                    .stroke(.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                }
                .offset(y: bounceOffset)
                
                // Waving arm
                if emotion.shouldWave {
                    Image(systemName: "hand.wave.fill")
                        .font(.system(size: size * 0.25, weight: .semibold))
                        .foregroundColor(.yellow)
                        .rotationEffect(.degrees(isWaving ? -20 : 20))
                        .offset(x: size * 0.5, y: -size * 0.16)
                        .offset(y: bounceOffset)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isWaving)
                }
            }
            
            // Speech bubble
            if let text = displayText, speechBubbleVisible {
                speechBubble(text: text)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .onAppear {
            startAnimations()
            
            // Show speech bubble after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    speechBubbleVisible = true
                }
            }
        }
        .onChange(of: emotion) { _, _ in
            // Update animations when emotion changes
            startAnimations()
        }
    }
    
    private var displayText: String? {
        return speechText ?? (speechText == "" ? nil : emotion.speechText())
    }
    
    private func speechBubble(text: String) -> some View {
        Text(text)
            .font(.system(size: size * 0.12, weight: .medium, design: .rounded))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                .thinMaterial,
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .overlay(alignment: .top) {
                // Speech bubble tail
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 6, y: -8))
                    path.addLine(to: CGPoint(x: 12, y: 0))
                }
                .fill(.thinMaterial)
                .offset(y: -1)
            }
            .frame(maxWidth: size * 2)
    }
    
    private func startAnimations() {
        // Bouncing animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            bounceOffset = emotion.bounceIntensity
        }
        
        // Waving animation
        if emotion.shouldWave {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                isWaving = true
            }
        } else {
            isWaving = false
        }
        
        // Blinking animation
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.15)) {
                isBlinking = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isBlinking = false
                }
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
struct WizardMascot_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // All emotions
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 20) {
                ForEach(MascotEmotion.allCases) { emotion in
                    VStack {
                        WizardMascot(emotion: emotion, size: 100)
                        Text("\(emotion)".capitalized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
            .previewDisplayName("All Emotions")
            
            // Individual emotion examples
            WizardMascot(emotion: .happy)
                .padding()
                .previewDisplayName("Happy")
            
            WizardMascot(
                emotion: .celebrating,
                speechText: "Awesome! Setup complete!",
                size: 140,
                colors: [.green.opacity(0.8), .mint.opacity(0.6)]
            )
            .padding()
            .previewDisplayName("Celebrating (Custom)")
            
            WizardMascot(emotion: .thinking, speechText: "")
                .padding()
                .previewDisplayName("Thinking (No Speech)")
        }
    }
}
#endif