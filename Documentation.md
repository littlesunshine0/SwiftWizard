# SwiftWizard Documentation

## Table of Contents

1. [Overview](#overview)
2. [Installation](#installation)
3. [Quick Start](#quick-start)
4. [Components](#components)
5. [Customization](#customization)
6. [Examples](#examples)
7. [API Reference](#api-reference)
8. [Best Practices](#best-practices)

## Overview

SwiftWizard is a modern, highly customizable onboarding wizard package for SwiftUI. It features animated mascot characters, permission request flows, and smooth transitions that create delightful user experiences.

### Key Features

- ✅ **Animated Mascot Character** with different emotional states
- ✅ **Permission Request Icons** with state-based animations
- ✅ **Smooth Transitions** between wizard steps
- ✅ **Customizable Flows** - create any sequence of steps
- ✅ **Multi-platform Support** - iOS, macOS, watchOS, tvOS
- ✅ **Modern SwiftUI Design** with materials and gradients
- ✅ **Comprehensive Previews** for development

## Installation

### Swift Package Manager (Recommended)

Add SwiftWizard to your project using Xcode:

1. Open your project in Xcode
2. Go to **File → Add Package Dependencies**
3. Enter the repository URL: `https://github.com/littlesunshine0/SwiftWizard`
4. Select the version requirements
5. Click **Add Package**

### Manual Integration

1. Download the source files
2. Add them to your Xcode project
3. Import `SwiftWizard` in your Swift files

## Quick Start

### Basic Implementation

```swift
import SwiftUI
import SwiftWizard

struct ContentView: View {
    @State private var showWizard = true
    
    var body: some View {
        VStack {
            Text("Your App Content")
        }
        .sheet(isPresented: $showWizard) {
            AnimatedWizardView { permissions in
                // Handle completion
                print("Wizard completed with permissions: \\(permissions)")
                showWizard = false
            }
        }
    }
}
```

### Pre-built Configurations

```swift
// Default wizard with common permissions
AnimatedWizardView.withCommonPermissions { permissions in
    // Handle completion
}

// Minimal wizard with just welcome/thank you
AnimatedWizardView.minimal { permissions in
    // Handle completion  
}
```

## Components

### 1. WizardMascot

An animated character that responds to different emotional states.

```swift
WizardMascot(
    emotion: .happy,
    speechText: "Welcome! Let's get started!",
    size: 120,
    colors: [.blue, .purple]
)
```

**Available Emotions:**
- `.happy` - Cheerful with waving animation
- `.excited` - Very animated, bouncy
- `.thinking` - Contemplative, slower animations
- `.celebrating` - Maximum bounce with confetti
- `.sad` - Downturned expression
- `.neutral` - Balanced emotional state

### 2. AnimatedPermissionIcon

Animated icons for permission requests with state transitions.

```swift
AnimatedPermissionIcon(
    permission: .camera,
    state: .requesting,
    size: 80,
    showBadge: true
)
```

**Available Permission Types:**
- `.camera` - Camera access
- `.location` - Location services  
- `.notifications` - Push notifications
- `.microphone` - Microphone access
- `.photos` - Photo library access
- `.contacts` - Contacts access
- `.calendar` - Calendar access
- `.reminders` - Reminders access
- `.faceID` / `.touchID` - Biometric authentication

**Permission States:**
- `.requesting` - Animated, waiting for user decision
- `.approved` - Success animation with checkmark
- `.denied` - Shake animation with X mark

### 3. WizardStep Types

Define the flow of your wizard:

```swift
enum WizardStep {
    case welcome(title: String?, subtitle: String?)
    case permission(PermissionRequest)
    case summary
    case thankyou(title: String?, subtitle: String?)
    case denied(message: String?)
    case custom(id: String, title: String, content: String)
}
```

## Customization

### Custom Configuration

```swift
let customConfig = WizardConfiguration(
    steps: [
        .welcome(title: "Welcome!", subtitle: "Let's set up your app"),
        .permission(PermissionRequest(type: .camera)),
        .permission(PermissionRequest(type: .location)),
        .summary,
        .thankyou(title: "All Done!", subtitle: "You're ready to go")
    ],
    allowSkipping: true,
    showProgressIndicator: true,
    mascotEnabled: true,
    animationsEnabled: true
)

AnimatedWizardView(configuration: customConfig) { permissions in
    // Handle completion
}
```

### Custom Permission Descriptions

```swift
let cameraPermission = PermissionRequest(
    type: .camera,
    customTitle: "Camera for Scanning", 
    customDescription: "We'll use your camera to scan barcodes and take photos of inventory items."
)
```

### Custom Mascot Colors

```swift
WizardMascot(
    emotion: .happy,
    size: 120,
    colors: [.green.opacity(0.8), .mint.opacity(0.6)]
)
```

## Examples

### Inventory App Wizard

```swift
func createInventoryWizard() -> WizardConfiguration {
    return WizardConfiguration(
        steps: [
            .welcome(
                title: "Welcome to InventoryPro!",
                subtitle: "Let's set up your inventory management experience"
            ),
            .permission(PermissionRequest(
                type: .camera,
                customTitle: "Camera for Scanning",
                customDescription: "Scan barcodes and take photos of items"
            )),
            .permission(PermissionRequest(
                type: .location,
                customTitle: "Location for Organization", 
                customDescription: "Organize inventory by location"
            )),
            .custom(
                id: "features",
                title: "Powerful Features",
                content: "Barcode scanning, photo management, and smart alerts"
            ),
            .summary,
            .thankyou(
                title: "You're All Set!",
                subtitle: "Start adding your first inventory items"
            )
        ]
    )
}
```

### Social App Wizard

```swift
func createSocialWizard() -> WizardConfiguration {
    return WizardConfiguration(
        steps: [
            .welcome(
                title: "Welcome to SocialConnect!",
                subtitle: "Connect with friends and share moments"
            ),
            .permission(PermissionRequest(
                type: .contacts,
                customDescription: "Find friends who are already using the app"
            )),
            .permission(PermissionRequest(
                type: .notifications,
                customDescription: "Stay updated with likes, comments, and messages"
            )),
            .permission(PermissionRequest(
                type: .photos,
                customDescription: "Share photos and memories with friends"
            )),
            .summary,
            .thankyou(
                title: "Ready to Connect!",
                subtitle: "Start sharing and connecting with friends"
            )
        ]
    )
}
```

## API Reference

### AnimatedWizardView

Main wizard container view.

```swift
public struct AnimatedWizardView: View {
    public init(
        configuration: WizardConfiguration = .default(),
        onCompletion: @escaping ([PermissionRequest]) -> Void,
        onDismiss: (() -> Void)? = nil
    )
}
```

### WizardConfiguration

Configuration for wizard behavior and appearance.

```swift
public struct WizardConfiguration {
    public let steps: [WizardStep]
    public let allowSkipping: Bool
    public let showProgressIndicator: Bool  
    public let mascotEnabled: Bool
    public let animationsEnabled: Bool
    
    public static func default() -> WizardConfiguration
    public static func minimal() -> WizardConfiguration
}
```

### PermissionRequest

Represents a permission request with optional customization.

```swift
public struct PermissionRequest: Identifiable, Equatable {
    public let type: PermissionType
    public var state: PermissionState
    public let customTitle: String?
    public let customDescription: String?
    
    public init(
        type: PermissionType,
        state: PermissionState = .requesting,
        customTitle: String? = nil,
        customDescription: String? = nil
    )
}
```

### View Extensions

Convenient styling extensions for wizard components.

```swift
extension View {
    func wizardBackground() -> some View
    func wizardButton(style: WizardButtonStyle, isEnabled: Bool) -> some View
    func wizardCard(padding: CGFloat) -> some View
    func pulseAnimation(isActive: Bool) -> some View
    func shake(trigger: Bool) -> some View
}
```

## Best Practices

### 1. Keep It Simple

- Limit to 3-5 permission requests maximum
- Use clear, benefit-focused descriptions
- Don't overwhelm users with too many steps

### 2. Provide Value Context

```swift
// ❌ Generic description
"We need camera access"

// ✅ Value-focused description  
"Camera access lets you quickly scan barcodes and take photos of inventory items"
```

### 3. Handle Denials Gracefully

```swift
WizardConfiguration(
    steps: [...],
    allowSkipping: true  // Let users skip non-essential permissions
)
```

### 4. Test on Different Devices

The package automatically adapts to different screen sizes, but test your custom content:

```swift
#if DEBUG
struct MyWizard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MyWizardView()
                .previewDevice("iPhone 15")
            
            MyWizardView()
                .previewDevice("iPad Pro (12.9-inch)")
        }
    }
}
#endif
```

### 5. Use Appropriate Emotions

Match mascot emotions to the step context:

```swift
.welcome -> .happy
.permission -> .thinking  
.summary -> .excited
.thankyou -> .celebrating
.denied -> .sad
```

### 6. Customize for Your Brand

```swift
WizardMascot(
    emotion: .happy,
    colors: [.brandPrimary, .brandSecondary] // Use your brand colors
)
```

---

## Support

For issues, feature requests, or questions:

1. Check the [examples](ExampleApp.swift) in the repository
2. Review the [API documentation](#api-reference) above
3. Open an issue on GitHub with a minimal reproduction case

## License

MIT License - see LICENSE file for full details.
