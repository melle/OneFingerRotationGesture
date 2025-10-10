# OneFingerRotationGesture

A modern Swift 6.2 package that provides a one-finger rotation gesture recognizer for iOS and macOS, with native SwiftUI integration.

This gesture recognizer detects circular rotation gestures, making it perfect for implementing knob-style controls, volume dials, or any circular rotation interface.

> **Note:** Looking for the original Objective-C implementation? Switch to the [`objc` branch](../../tree/objc) for the legacy UIKit version.

## Features

- ✨ **Modern Swift 6.2** with full concurrency support
- 🎨 **Native SwiftUI Integration** via view modifiers
- 📱 **iOS 17+** and **macOS 14+** support
- 🎯 **Precise angle tracking** with customizable sensitivity zones
- 🔄 **Continuous rotation detection** with delta angle callbacks
- 📦 **Easy to integrate** via Swift Package Manager

## How It Works

The gesture recognizer tracks finger movements within a defined annular region (ring-shaped area) around a center point. As the user drags their finger in a circular motion, the recognizer:

1. Validates that the touch is within the defined **inner and outer radius** boundaries
2. Calculates the **rotation angle** between consecutive touch positions
3. Normalizes angles when crossing the 12 o'clock position
4. Provides continuous callbacks with angle deltas during the gesture
5. Reports the final cumulative angle when the gesture ends

The math behind it uses the arc tangent function (`atan2`) to calculate angles between two lines that share the same starting point (the center of rotation). The distance validation ensures touches are within the valid annular region:

```
innerRadius ≤ distance ≤ outerRadius
```

## Installation

### Swift Package Manager

Add this package to your project using Xcode:

1. File → Add Package Dependencies...
2. Enter the repository URL: `https://github.com/melle/OneFingerRotationGestureDemo`
3. Select the version you want to use

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/melle/OneFingerRotationGestureDemo", from: "1.0.0")
]
```

Then import it in your Swift files:

```swift
import OneFingerRotationGesture
```

## Usage

### SwiftUI (Recommended)

The easiest way to use the gesture is with the `.oneFingerRotation()` view modifier:

```swift
import SwiftUI
import OneFingerRotationGesture

struct ContentView: View {
    @State private var rotation: CGFloat = 0
    
    var body: some View {
        Circle()
            .fill(.blue)
            .frame(width: 200, height: 200)
            .rotationEffect(.degrees(Double(rotation)))
            .oneFingerRotation(
                innerRadiusRatio: 0.3,  // Inner 30% is inactive
                outerRadiusRatio: 1.0    // Full view width
            ) { angle in
                // Called during rotation with angle delta
                rotation += angle
            } onEnd: { totalAngle in
                // Called when gesture ends
                print("Total rotation: \(totalAngle)°")
            }
    }
}
```

### Parameters

- **`innerRadiusRatio`** (default: 0.3): The ratio (0.0-1.0) of the inner radius to the view's radius. Set this to a value greater than 0 to avoid erratic behavior when touching near the center point.

- **`outerRadiusRatio`** (default: 1.0): The ratio (0.0-1.0) of the outer radius to the view's radius. Typically set to 1.0 to use the full view size.

- **`onRotation`**: Callback that receives the angle delta in degrees each time the touch moves. Use this to update your UI in real-time.

- **`onEnd`** (optional): Callback that receives the total cumulated rotation angle when the gesture completes.

### Example: Volume Knob

Here's a complete example of a volume knob control:

```swift
struct VolumeKnob: View {
    @State private var volume: Double = 0.5
    @State private var rotation: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Knob background
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .blue.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(radius: 10)
            
            // Indicator line
            Rectangle()
                .fill(.white)
                .frame(width: 4, height: 40)
                .offset(y: -30)
        }
        .frame(width: 200, height: 200)
        .rotationEffect(.degrees(Double(rotation)))
        .oneFingerRotation(innerRadiusRatio: 0.3) { angle in
            rotation += angle
            
            // Convert rotation to volume (0.0 - 1.0)
            let normalizedAngle = rotation.truncatingRemainder(dividingBy: 360)
            volume = (normalizedAngle + 180) / 360
            volume = max(0, min(1, volume))
        }
        
        Text("Volume: \(Int(volume * 100))%")
            .padding(.top, 220)
    }
}
```

### UIKit Integration

For UIKit projects, you can use the gesture recognizer directly:

```swift
import UIKit
import OneFingerRotationGesture

class ViewController: UIViewController {
    var imageView: UIImageView!
    var rotation: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureRecognizer()
    }
    
    func setupGestureRecognizer() {
        // Calculate the center and radius based on the view
        let midPoint = CGPoint(
            x: imageView.frame.origin.x + imageView.frame.size.width / 2,
            y: imageView.frame.origin.y + imageView.frame.size.height / 2
        )
        let outerRadius = imageView.frame.size.width / 2
        let innerRadius = outerRadius / 3  // Avoid center touch issues
        
        // Create the gesture recognizer
        let recognizer = OneFingerRotationGestureRecognizer(
            midPoint: midPoint,
            innerRadius: innerRadius,
            outerRadius: outerRadius
        )
        
        // Set up callbacks
        recognizer.onRotation = { [weak self] angle in
            self?.handleRotation(angle: angle)
        }
        
        recognizer.onFinalAngle = { totalAngle in
            print("Gesture ended with total rotation: \(totalAngle)°")
        }
        
        // Add to view
        view.addGestureRecognizer(recognizer)
    }
    
    func handleRotation(angle: CGFloat) {
        rotation += angle
        
        // Normalize angle
        if rotation > 360 {
            rotation -= 360
        } else if rotation < -360 {
            rotation += 360
        }
        
        // Apply rotation transform
        imageView.transform = CGAffineTransformMakeRotation(rotation * .pi / 180)
    }
}
```

## Demo App

The package includes a fully functional demo app showcasing the gesture recognizer. To run it:

1. Clone this repository
2. Open `DemoApp/DemoApp.xcodeproj` in Xcode
3. Build and run on the iOS simulator or device

The demo features a beautiful circular knob with:
- Visual touch area indicators
- Real-time angle display
- Smooth rotation animations
- Modern iOS design

## How It's Built

### The Math

The core of the gesture recognizer uses these mathematical concepts:

**Distance Calculation:**
```swift
func distanceBetweenPoints(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
    let dx = point1.x - point2.x
    let dy = point1.y - point2.y
    return sqrt(dx * dx + dy * dy)
}
```

**Angle Calculation:**
```swift
func angleBetweenLines(
    beginLineA: CGPoint, endLineA: CGPoint,
    beginLineB: CGPoint, endLineB: CGPoint
) -> CGFloat {
    let a = endLineA.x - beginLineA.x
    let b = endLineA.y - beginLineA.y
    let c = endLineB.x - beginLineB.x
    let d = endLineB.y - beginLineB.y
    
    let atanA = atan2(a, b)
    let atanB = atan2(c, d)
    
    // Convert radians to degrees
    return (atanA - atanB) * 180 / .pi
}
```

### Architecture

The package consists of three main components:

1. **`OneFingerRotationGestureRecognizer`**: A UIGestureRecognizer subclass that handles the low-level touch events and angle calculations.

2. **`OneFingerRotationModifier`**: A SwiftUI ViewModifier that wraps the gesture recognizer for easy integration.

3. **`GestureRecognizerView`**: A UIViewRepresentable that bridges UIKit and SwiftUI.

## Requirements

- iOS 17.0+ / macOS 14.0+
- Swift 6.0+
- Xcode 16.0+

## Tips

- **Inner Radius**: Always use an inner radius greater than 0 (recommended: 30% of the outer radius) to avoid erratic behavior when touching near the center point.

- **Angle Normalization**: The gesture provides raw angle deltas. You may want to normalize the cumulative angle to stay within 0-360° or -180° to 180° range.

- **Performance**: The gesture recognizer is highly optimized and has minimal performance impact, making it suitable for real-time UI updates.

- **Multiple Gestures**: You can add multiple gesture recognizers to different views, each with their own configuration.

## License

This project is available under the MIT License. See the LICENSE file for more information.

## Credits

Based on the original concept by Harm Mellenthin. 

Read more about the implementation details: [An one finger rotation gesture recognizer](https://blog.mellenthin.de/archives/2012/02/13/an-one-finger-rotation-gesture-recognizer/)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
