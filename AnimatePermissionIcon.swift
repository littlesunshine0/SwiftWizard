//
//  AnimatedPermissionIcon.swift
//  AnimatedWizard
//
//  Created by AnimatedWizard Package
//

import SwiftUI

/// An animated icon representing a permission request
public struct AnimatedPermissionIcon: View {
    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var rotationAngle: Double = 0
    
    public let permission: PermissionType
    public let state: PermissionState
    public let size: CGFloat
    public let showBadge: Bool
    
    /// Creates a new animated permission icon
    /// - Parameters:
    ///   - permission: The type of permission this icon represents
    ///   - state: The current state of the permission request
    ///   - size: The size of the icon (default: 80)
    ///   - showBadge: Whether to show approval/denial badge (default: true)
    public init(
        permission: PermissionType,
        state: PermissionState,
        size: CGFloat = 80,
        showBadge: Bool = true
    ) {
        self.permission = permission
        self.state = state
        self.size = size
        self.showBadge = showBadge
    }
    
    public var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(permission.color.opacity(backgroundOpacity))
                .frame(width: size, height: size)
                .scaleEffect(pulseScale)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseScale)
            
            // Icon
            Image(systemName: permission.systemImage)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundColor(permission.color)
                .rotationEffect(.degrees(rotationAngle))
                .scaleEffect(state == .approved ? 1.1 : 1.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: state)
            
            // State badge
            if showBadge && (state == .approved || state == .denied) {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        stateBadge
                    }
                }
                .frame(width: size, height: size)
            }
        }
        .onAppear {
            startAnimations()
        }
        .onChange(of: state) { _, newState in
            updateAnimationsForState(newState)
        }
    }
    
    private var iconSize: CGFloat {
        size * 0.4
    }
    
    private var backgroundOpacity: Double {
        switch state {
        case .requesting:
            return 0.2
        case .approved:
            return 0.3
        case .denied:
            return 0.15
        }
    }
    
    private var stateBadge: some View {
        Group {
            if state == .approved {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: size * 0.25, weight: .semibold))
                    .foregroundColor(.green)
                    .background(
                        Circle()
                            .fill(.white)
                            .frame(width: size * 0.22, height: size * 0.22)
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
            } else if state == .denied {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: size * 0.25, weight: .semibold))
                    .foregroundColor(.red)
                    .background(
                        Circle()
                            .fill(.white)
                            .frame(width: size * 0.22, height: size * 0.22)
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
    }
    
    private func startAnimations() {
        updateAnimationsForState(state)
    }
    
    private func updateAnimationsForState(_ newState: PermissionState) {
        switch newState {
        case .requesting:
            // Pulse animation
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.1
            }
            
            // Gentle rotation
            withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            
        case .approved:
            // Stop pulsing, show success animation
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                pulseScale = 1.0
                rotationAngle = 0
            }
            
            // Brief success pulse
            withAnimation(.easeInOut(duration: 0.3)) {
                pulseScale = 1.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    pulseScale = 1.0
                }
            }
            
        case .denied:
            // Stop animations, show subtle shake
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                pulseScale = 1.0
                rotationAngle = 0
            }
            
            // Shake animation
            withAnimation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)) {
                rotationAngle = 5
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    rotationAngle = 0
                }
            }
        }
    }
}

/// A row of animated permission icons
public struct PermissionIconRow: View {
    public let permissions: [PermissionRequest]
    public let iconSize: CGFloat
    public let spacing: CGFloat
    
    /// Creates a row of permission icons
    /// - Parameters:
    ///   - permissions: Array of permission requests to display
    ///   - iconSize: Size of each icon (default: 60)
    ///   - spacing: Spacing between icons (default: 16)
    public init(
        permissions: [PermissionRequest],
        iconSize: CGFloat = 60,
        spacing: CGFloat = 16
    ) {
        self.permissions = permissions
        self.iconSize = iconSize
        self.spacing = spacing
    }
    
    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(permissions) { permission in
                VStack(spacing: 4) {
                    AnimatedPermissionIcon(
                        permission: permission.type,
                        state: permission.state,
                        size: iconSize
                    )
                    
                    Text(permission.type.title)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
struct AnimatedPermissionIcon_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // All permission types in requesting state
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 20) {
                ForEach(PermissionType.allCases) { permission in
                    VStack {
                        AnimatedPermissionIcon(
                            permission: permission,
                            state: .requesting,
                            size: 80
                        )
                        Text(permission.title)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
            .previewDisplayName("All Permission Types")
            
            // Different states
            HStack(spacing: 30) {
                VStack {
                    AnimatedPermissionIcon(
                        permission: .camera,
                        state: .requesting
                    )
                    Text("Requesting")
                        .font(.caption)
                }
                
                VStack {
                    AnimatedPermissionIcon(
                        permission: .camera,
                        state: .approved
                    )
                    Text("Approved")
                        .font(.caption)
                }
                
                VStack {
                    AnimatedPermissionIcon(
                        permission: .camera,
                        state: .denied
                    )
                    Text("Denied")
                        .font(.caption)
                }
            }
            .padding()
            .previewDisplayName("Permission States")
            
            // Permission row
            PermissionIconRow(
                permissions: [
                    PermissionRequest(type: .camera, state: .approved),
                    PermissionRequest(type: .location, state: .requesting),
                    PermissionRequest(type: .notifications, state: .denied)
                ]
            )
            .padding()
            .previewDisplayName("Permission Row")
        }
    }
}
#endif