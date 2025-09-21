//
//  ExampleApp.swift
//  AnimatedWizard Example
//
//  This file shows how to integrate the AnimatedWizard package into your app
//

import SwiftUI
import AnimatedWizard

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var showDefaultWizard = false
    @State private var showMinimalWizard = false
    @State private var showCustomWizard = false
    @State private var completedPermissions: [PermissionRequest] = []
    @State private var showResults = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                HeaderView()
                
                Spacer()
                
                // Example buttons
                VStack(spacing: 16) {
                    Button("Show Default Wizard") {
                        showDefaultWizard = true
                    }
                    .wizardButton(style: .primary)
                    
                    Button("Show Minimal Wizard") {
                        showMinimalWizard = true
                    }
                    .wizardButton(style: .secondary)
                    
                    Button("Show Custom Wizard") {
                        showCustomWizard = true
                    }
                    .wizardButton(style: .ghost)
                }
                
                Spacer()
                
                if !completedPermissions.isEmpty {
                    ResultsView(permissions: completedPermissions)
                }
                
                Spacer()
            }
            .padding(24)
            .wizardBackground()
            .navigationTitle("AnimatedWizard Demo")
            .navigationBarTitleDisplayMode(.inline)
        }
        
        // Wizard presentations
        .sheet(isPresented: $showDefaultWizard) {
            AnimatedWizardView.withCommonPermissions { permissions in
                completedPermissions = permissions
                showDefaultWizard = false
                showResults = true
            }
        }
        
        .sheet(isPresented: $showMinimalWizard) {
            AnimatedWizardView.minimal { permissions in
                completedPermissions = permissions
                showMinimalWizard = false
                showResults = true
            }
        }
        
        .sheet(isPresented: $showCustomWizard) {
            AnimatedWizardView(
                configuration: createCustomConfiguration()
            ) { permissions in
                completedPermissions = permissions
                showCustomWizard = false
                showResults = true
            }
        }
        
        .alert("Wizard Completed!", isPresented: $showResults) {
            Button("OK") {}
        } message: {
            Text("Check the results below to see which permissions were granted.")
        }
    }
    
    private func createCustomConfiguration() -> WizardConfiguration {
        return WizardConfiguration(
            steps: [
                .welcome(
                    title: "Welcome to InventoryPro!",
                    subtitle: "Let's set up your inventory management experience"
                ),
                .permission(PermissionRequest(
                    type: .camera,
                    customTitle: "Camera for Scanning",
                    customDescription: "We'll use your camera to scan barcodes and take photos of inventory items for easy identification."
                )),
                .permission(PermissionRequest(
                    type: .location,
                    customTitle: "Location for Organization",
                    customDescription: "Location services help us organize your inventory by location and suggest nearby suppliers."
                )),
                .permission(PermissionRequest(
                    type: .notifications,
                    customTitle: "Stock Alerts",
                    customDescription: "Get notified when inventory is running low or when items need attention."
                )),
                .custom(
                    id: "features",
                    title: "Powerful Features",
                    content: "InventoryPro includes barcode scanning, photo management, location tracking, and smart alerts to keep your inventory organized."
                ),
                .summary,
                .thankyou(
                    title: "You're All Set!",
                    subtitle: "Start adding your first inventory items and experience the power of smart organization."
                )
            ],
            allowSkipping: true,
            showProgressIndicator: true,
            mascotEnabled: true,
            animationsEnabled: true
        )
    }
}

struct HeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            // App icon placeholder
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 80, height: 80)
                .overlay {
                    Image(systemName: "sparkles")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white)
                }
            
            VStack(spacing: 8) {
                Text("AnimatedWizard")
                    .font(.title.bold())
                
                Text("Modern SwiftUI onboarding flows")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct ResultsView: View {
    let permissions: [PermissionRequest]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last Wizard Results")
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(permissions) { permission in
                    HStack {
                        AnimatedPermissionIcon(
                            permission: permission.type,
                            state: permission.state,
                            size: 24
                        )
                        
                        Text(permission.type.title)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text(permission.state == .approved ? "✅" : "❌")
                    }
                }
                
                if permissions.isEmpty {
                    Text("No permissions requested")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }
        }
        .wizardCard(padding: 16)
    }
}

// MARK: - Preview

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif