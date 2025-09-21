//
//  AnimatedWizard.swift
//  AnimatedWizard
//
//  Created by AnimatedWizard Package
//

import SwiftUI

/// The main animated wizard view
public struct AnimatedWizardView: View {
    @State private var currentStepIndex: Int = 0
    @State private var permissionRequests: [PermissionRequest] = []
    @State private var isTransitioning = false
    
    public let configuration: WizardConfiguration
    public let onCompletion: ([PermissionRequest]) -> Void
    public let onDismiss: (() -> Void)?
    
    /// Creates a new animated wizard
    /// - Parameters:
    ///   - configuration: Wizard configuration (default: .default())
    ///   - onCompletion: Called when wizard completes with granted permissions
    ///   - onDismiss: Called when wizard is dismissed (optional)
    public init(
        configuration: WizardConfiguration = .default(),
        onCompletion: @escaping ([PermissionRequest]) -> Void,
        onDismiss: (() -> Void)? = nil
    ) {
        self.configuration = configuration
        self.onCompletion = onCompletion
        self.onDismiss = onDismiss
    }
    
    private var currentStep: WizardStep {
        guard currentStepIndex < configuration.steps.count else {
            return .thankyou(title: nil, subtitle: nil)
        }
        return configuration.steps[currentStepIndex]
    }
    
    public var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Progress indicator (if enabled)
                if configuration.showProgressIndicator && !currentStep.isTerminal {
                    WizardProgressIndicator(
                        currentStep: currentStepIndex,
                        totalSteps: configuration.steps.count - 1 // Exclude thank you step
                    )
                    .padding(.top, 20)
                    .padding(.horizontal, 40)
                }
                
                // Main content
                ScrollView {
                    VStack(spacing: 40) {
                        // Mascot (if enabled)
                        if configuration.mascotEnabled {
                            WizardMascot(emotion: currentStep.mascotEmotion)
                                .transition(mascotTransition)
                        }
                        
                        Spacer().frame(height: 20)
                        
                        // Step content
                        stepContent
                            .transition(contentTransition)
                        
                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, 24)
                    .frame(minHeight: geometry.size.height - 100)
                }
            }
            .wizardBackground()
            .animation(.easeInOut(duration: 0.6), value: currentStepIndex)
            .disabled(isTransitioning)
        }
        .onAppear {
            initializePermissions()
        }
    }
    
    // MARK: - Step Content
    
    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case .welcome(let title, let subtitle):
            welcomeContent(title: title, subtitle: subtitle)
            
        case .permission(let request):
            if let index = permissionRequests.firstIndex(where: { $0.id == request.id }) {
                permissionContent(permissionRequests[index])
            }
            
        case .summary:
            summaryContent
            
        case .thankyou(let title, let subtitle):
            thankyouContent(title: title, subtitle: subtitle)
            
        case .denied(let message):
            deniedContent(message: message)
            
        case .custom(_, let title, let content):
            customContent(title: title, content: content)
        }
    }
    
    // MARK: - Welcome Content
    
    private func welcomeContent(title: String?, subtitle: String?) -> some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text(title ?? "Welcome!")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                
                Text(subtitle ?? "Let's quickly set up a few things to get the best experience.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                nextStep()
            } label: {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Get Started")
                }
            }
            .wizardButton(style: .primary)
            .pulseAnimation()
        }
        .wizardCard()
    }
    
    // MARK: - Permission Content
    
    private func permissionContent(_ request: PermissionRequest) -> some View {
        VStack(spacing: 32) {
            AnimatedPermissionIcon(
                permission: request.type,
                state: request.state,
                size: 100
            )
            
            VStack(spacing: 16) {
                Text(request.displayTitle)
                    .font(.title2.bold())
                
                Text(request.displayDescription)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Action buttons
            if request.state == .requesting {
                VStack(spacing: 12) {
                    Button {
                        approvePermission(request)
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Allow")
                        }
                    }
                    .wizardButton(style: .primary)
                    
                    if configuration.allowSkipping {
                        Button {
                            denyPermission(request)
                        } label: {
                            Text("Not Now")
                        }
                        .wizardButton(style: .secondary)
                    }
                }
            } else {
                // Show next button after decision
                Button {
                    nextStep()
                } label: {
                    Text("Continue")
                }
                .wizardButton(style: .primary)
            }
        }
        .wizardCard()
    }
    
    // MARK: - Summary Content
    
    private var summaryContent: some View {
        VStack(spacing: 24) {
            Text("Setup Summary")
                .font(.title2.bold())
            
            VStack(spacing: 16) {
                ForEach(permissionRequests) { request in
                    HStack(spacing: 16) {
                        AnimatedPermissionIcon(
                            permission: request.type,
                            state: request.state,
                            size: 44,
                            showBadge: false
                        )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(request.type.title)
                                .font(.headline)
                            Text(request.state == .approved ? "Enabled" : "Disabled")
                                .font(.caption)
                                .foregroundStyle(request.state == .approved ? .green : .secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: request.state == .approved ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(request.state == .approved ? .green : .red)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            
            Button {
                nextStep()
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Complete Setup")
                }
            }
            .wizardButton(style: .primary)
        }
        .wizardCard()
    }
    
    // MARK: - Thank You Content
    
    private func thankyouContent(title: String?, subtitle: String?) -> some View {
        VStack(spacing: 32) {
            // Confetti animation
            ConfettiView()
                .frame(height: 100)
            
            VStack(spacing: 16) {
                Text(title ?? "All Set!")
                    .font(.largeTitle.bold())
                
                Text(subtitle ?? "Your app is ready to use. Enjoy!")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                completeWizard()
            } label: {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Get Started")
                }
            }
            .wizardButton(style: .primary)
        }
        .wizardCard()
    }
    
    // MARK: - Denied Content
    
    private func deniedContent(message: String?) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            VStack(spacing: 12) {
                Text("Setup Incomplete")
                    .font(.title2.bold())
                
                Text(message ?? "Some features require these permissions to work properly. You can enable them later in Settings.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                Button {
                    resetWizard()
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise.circle.fill")
                        Text("Try Again")
                    }
                }
                .wizardButton(style: .primary)
                
                Button {
                    completeWizard()
                } label: {
                    Text("Continue Anyway")
                }
                .wizardButton(style: .secondary)
            }
        }
        .wizardCard()
    }
    
    // MARK: - Custom Content
    
    private func customContent(title: String, content: String) -> some View {
        VStack(spacing: 24) {
            Text(title)
                .font(.title2.bold())
            
            Text(content)
                .font(.body)
                .multilineTextAlignment(.center)
            
            Button {
                nextStep()
            } label: {
                Text("Continue")
            }
            .wizardButton(style: .primary)
        }
        .wizardCard()
    }
    
    // MARK: - Actions
    
    private func nextStep() {
        guard !isTransitioning else { return }
        
        withAnimation(.easeInOut(duration: 0.4)) {
            isTransitioning = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            currentStepIndex += 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    isTransitioning = false
                }
            }
        }
    }
    
    private func approvePermission(_ request: PermissionRequest) {
        guard let index = permissionRequests.firstIndex(where: { $0.id == request.id }) else { return }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            permissionRequests[index].state = .approved
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            nextStep()
        }
    }
    
    private func denyPermission(_ request: PermissionRequest) {
        guard let index = permissionRequests.firstIndex(where: { $0.id == request.id }) else { return }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            permissionRequests[index].state = .denied
        }
        
        // Check if we should show denied screen
        if shouldShowDeniedScreen() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                goToDeniedStep()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                nextStep()
            }
        }
    }
    
    private func shouldShowDeniedScreen() -> Bool {
        // Show denied screen if all permissions were denied
        let permissionStepRequests = permissionRequests.filter { request in
            configuration.steps.contains { step in
                if case .permission(let stepRequest) = step {
                    return stepRequest.type == request.type
                }
                return false
            }
        }
        
        return permissionStepRequests.allSatisfy { $0.state == .denied }
    }
    
    private func goToDeniedStep() {
        // Find or create denied step
        if let deniedIndex = configuration.steps.firstIndex(where: { step in
            if case .denied = step { return true }
            return false
        }) {
            currentStepIndex = deniedIndex
        }
    }
    
    private func resetWizard() {
        withAnimation(.easeInOut(duration: 0.6)) {
            currentStepIndex = 0
            // Reset permission states
            for index in permissionRequests.indices {
                permissionRequests[index].state = .requesting
            }
        }
    }
    
    private func completeWizard() {
        onCompletion(permissionRequests)
    }
    
    private func initializePermissions() {
        permissionRequests = configuration.steps.compactMap { step in
            if case .permission(let request) = step {
                return request
            }
            return nil
        }
    }
    
    // MARK: - Transitions
    
    private var mascotTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        )
    }
    
    private var contentTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}

// MARK: - Convenience Initializers

public extension AnimatedWizardView {
    /// Creates a wizard with common permissions
    static func withCommonPermissions(
        onCompletion: @escaping ([PermissionRequest]) -> Void
    ) -> AnimatedWizardView {
        return AnimatedWizardView(
            configuration: .default(),
            onCompletion: onCompletion
        )
    }
    
    /// Creates a minimal wizard with just welcome and thank you
    static func minimal(
        onCompletion: @escaping ([PermissionRequest]) -> Void
    ) -> AnimatedWizardView {
        return AnimatedWizardView(
            configuration: .minimal(),
            onCompletion: onCompletion
        )
    }
}

// MARK: - Previews

#if DEBUG
struct AnimatedWizardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Default wizard
            AnimatedWizardView { permissions in
                print("Completed with permissions: \(permissions)")
            }
            .previewDisplayName("Default Wizard")
            
            // Minimal wizard
            AnimatedWizardView.minimal { permissions in
                print("Minimal wizard completed: \(permissions)")
            }
            .previewDisplayName("Minimal Wizard")
            
            // Custom configuration
            AnimatedWizardView(
                configuration: WizardConfiguration(
                    steps: [
                        .welcome(title: "Welcome to MyApp", subtitle: "Let's set things up"),
                        .permission(PermissionRequest(type: .camera, customDescription: "Camera access is needed for taking photos of your items")),
                        .custom(id: "features", title: "Amazing Features", content: "Here are some great features you'll love!"),
                        .thankyou(title: "You're Ready!", subtitle: "Start exploring the app")
                    ],
                    mascotEnabled: true,
                    animationsEnabled: true
                )
            ) { permissions in
                print("Custom wizard completed: \(permissions)")
            }
            .previewDisplayName("Custom Wizard")
        }
    }
}
#endif