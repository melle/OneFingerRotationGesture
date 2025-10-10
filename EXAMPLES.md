# OneFingerRotationGesture Examples

This document provides additional usage examples for the OneFingerRotationGesture package.

## Table of Contents

- [Basic Examples](#basic-examples)
- [Advanced Examples](#advanced-examples)
- [Real-World Use Cases](#real-world-use-cases)

## Basic Examples

### Simple Rotating Image

```swift
import SwiftUI
import OneFingerRotationGesture

struct RotatingImageView: View {
    @State private var rotation: CGFloat = 0
    
    var body: some View {
        Image(systemName: "arrow.up.circle.fill")
            .resizable()
            .frame(width: 200, height: 200)
            .rotationEffect(.degrees(Double(rotation)))
            .oneFingerRotation { angle in
                rotation += angle
            }
    }
}
```

### Angle Display

```swift
struct AngleDisplayView: View {
    @State private var rotation: CGFloat = 0
    
    var normalizedAngle: CGFloat {
        rotation.truncatingRemainder(dividingBy: 360)
    }
    
    var body: some View {
        VStack {
            Circle()
                .fill(.blue)
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(Double(rotation)))
                .oneFingerRotation { angle in
                    rotation += angle
                }
            
            Text("Angle: \(normalizedAngle, specifier: "%.1f")°")
                .font(.title)
        }
    }
}
```

## Advanced Examples

### Volume Control with Constraints

```swift
struct VolumeControl: View {
    @State private var volume: Double = 0.5
    @State private var rotation: CGFloat = 180  // Start at middle
    
    var body: some View {
        VStack {
            ZStack {
                // Background arc showing range
                Circle()
                    .trim(from: 0.125, to: 0.875)  // 270° range
                    .stroke(.gray.opacity(0.3), lineWidth: 20)
                    .rotationEffect(.degrees(-135))
                
                // Active arc showing current volume
                Circle()
                    .trim(from: 0, to: CGFloat(volume) * 0.75)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.green, .yellow, .red]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(135))
                
                // Knob
                Circle()
                    .fill(.white)
                    .shadow(radius: 5)
                    .frame(width: 140, height: 140)
                
                // Indicator
                Circle()
                    .fill(.blue)
                    .frame(width: 20, height: 20)
                    .offset(y: -55)
                    .rotationEffect(.degrees(Double(rotation)))
            }
            .frame(width: 200, height: 200)
            .oneFingerRotation { angle in
                rotation += angle
                
                // Constrain rotation to 270° range (-135° to 135°)
                rotation = max(-135, min(135, rotation))
                
                // Map rotation to volume (0.0 - 1.0)
                volume = (rotation + 135) / 270
            }
            
            Text("\(Int(volume * 100))%")
                .font(.system(size: 48, weight: .bold, design: .rounded))
        }
    }
}
```

### Temperature Control

```swift
struct TemperatureControl: View {
    @State private var temperature: Double = 20
    @State private var rotation: CGFloat = 0
    
    private let minTemp: Double = 16
    private let maxTemp: Double = 30
    
    var temperatureColor: Color {
        let normalized = (temperature - minTemp) / (maxTemp - minTemp)
        return Color(
            red: normalized,
            green: 0.5,
            blue: 1 - normalized
        )
    }
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                // Thermometer background
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                temperatureColor.opacity(0.3),
                                temperatureColor.opacity(0.1)
                            ]),
                            center: .center,
                            startRadius: 50,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                
                // Temperature marks
                ForEach(0..<12) { index in
                    Rectangle()
                        .fill(.gray)
                        .frame(width: 2, height: 10)
                        .offset(y: -90)
                        .rotationEffect(.degrees(Double(index) * 30))
                }
                
                // Inner circle
                Circle()
                    .fill(temperatureColor)
                    .frame(width: 160, height: 160)
                
                // Temperature value
                VStack {
                    Text("\(Int(temperature))")
                        .font(.system(size: 48, weight: .bold))
                    Text("°C")
                        .font(.title2)
                }
                .foregroundColor(.white)
            }
            .oneFingerRotation { angle in
                // Adjust temperature by rotation
                let tempChange = angle / 10.0
                temperature += tempChange
                temperature = max(minTemp, min(maxTemp, temperature))
            }
            
            HStack {
                Text("\(Int(minTemp))°C")
                    .foregroundColor(.blue)
                Spacer()
                Text("\(Int(maxTemp))°C")
                    .foregroundColor(.red)
            }
            .padding(.horizontal, 40)
        }
    }
}
```

### Timer Dial

```swift
struct TimerDial: View {
    @State private var minutes: Int = 0
    @State private var rotation: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 40) {
            ZStack {
                // Clock face
                Circle()
                    .stroke(.gray.opacity(0.3), lineWidth: 4)
                    .frame(width: 250, height: 250)
                
                // Hour markers
                ForEach(0..<12) { hour in
                    VStack {
                        Rectangle()
                            .fill(.gray)
                            .frame(width: 3, height: 15)
                        Spacer()
                    }
                    .frame(height: 125)
                    .rotationEffect(.degrees(Double(hour) * 30))
                }
                
                // Dial
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.orange, .red]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .shadow(radius: 10)
                
                // Hand
                RoundedRectangle(cornerRadius: 4)
                    .fill(.white)
                    .frame(width: 6, height: 80)
                    .offset(y: -40)
                    .rotationEffect(.degrees(Double(rotation)))
                
                // Center dot
                Circle()
                    .fill(.white)
                    .frame(width: 20, height: 20)
            }
            .oneFingerRotation { angle in
                rotation += angle
                
                // Convert rotation to minutes (full rotation = 60 minutes)
                let totalRotation = rotation.truncatingRemainder(dividingBy: 360)
                minutes = Int((totalRotation / 360 * 60).rounded())
                if minutes < 0 { minutes += 60 }
            }
            
            VStack(spacing: 8) {
                Text("\(minutes) min")
                    .font(.system(size: 42, weight: .bold))
                
                Button("Start Timer") {
                    print("Timer started for \(minutes) minutes")
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
```

## Real-World Use Cases

### Color Picker Hue Wheel

```swift
struct HueWheelPicker: View {
    @State private var hue: Double = 0
    @State private var rotation: CGFloat = 0
    
    var currentColor: Color {
        Color(hue: hue, saturation: 1.0, brightness: 1.0)
    }
    
    var body: some View {
        VStack(spacing: 40) {
            ZStack {
                // Hue wheel
                AngularGradient(
                    gradient: Gradient(colors: [
                        .red, .yellow, .green, .cyan, .blue, .magenta, .red
                    ]),
                    center: .center
                )
                .frame(width: 250, height: 250)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(.white, lineWidth: 4)
                )
                
                // Inner circle to show selected color
                Circle()
                    .fill(currentColor)
                    .frame(width: 150, height: 150)
                    .shadow(radius: 10)
                
                // Pointer
                Circle()
                    .fill(.white)
                    .frame(width: 30, height: 30)
                    .shadow(radius: 5)
                    .offset(y: -110)
                    .rotationEffect(.degrees(Double(rotation)))
            }
            .oneFingerRotation { angle in
                rotation += angle
                
                // Convert rotation to hue (0.0 - 1.0)
                let normalizedRotation = rotation.truncatingRemainder(dividingBy: 360)
                hue = (normalizedRotation + 360).truncatingRemainder(dividingBy: 360) / 360
            }
            
            // Color info
            VStack(spacing: 8) {
                Text("Hue: \(Int(hue * 360))°")
                    .font(.headline)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(currentColor)
                    .frame(width: 200, height: 50)
            }
        }
    }
}
```

### Safe Lock Dial

```swift
struct SafeLockView: View {
    @State private var rotation: CGFloat = 0
    @State private var attempts: [Int] = []
    
    let combination = [23, 67, 41]  // The secret combination
    
    var currentNumber: Int {
        let normalized = Int(rotation.truncatingRemainder(dividingBy: 360))
        return (normalized + 360) % 360 / 360 * 100
    }
    
    var body: some View {
        VStack(spacing: 40) {
            ZStack {
                // Dial face
                Circle()
                    .fill(.gray)
                    .frame(width: 280, height: 280)
                    .shadow(radius: 10)
                
                // Numbers
                ForEach(0..<100, id: \.self) { number in
                    if number % 5 == 0 {
                        Text("\(number)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .offset(y: -120)
                            .rotationEffect(.degrees(Double(number) * 3.6))
                    }
                }
                
                // Inner dial
                Circle()
                    .fill(.black)
                    .frame(width: 240, height: 240)
                
                // Indicator line
                Rectangle()
                    .fill(.red)
                    .frame(width: 3, height: 60)
                    .offset(y: -90)
                    .rotationEffect(.degrees(Double(rotation)))
            }
            .oneFingerRotation { angle in
                rotation += angle
            }
            
            // Current number display
            Text("\(currentNumber)")
                .font(.system(size: 56, weight: .bold, design: .monospaced))
                .foregroundColor(.red)
            
            Button("Enter") {
                attempts.append(currentNumber)
                
                if attempts.count == 3 {
                    if attempts == combination {
                        print("Safe unlocked!")
                    } else {
                        print("Wrong combination")
                        attempts = []
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            
            Text("Entered: \(attempts.map(String.init).joined(separator: " - "))")
                .font(.caption)
        }
    }
}
```

## Tips for Best Results

1. **Choose appropriate radii**: Use `innerRadiusRatio: 0.3` to avoid center-touch issues
2. **Constrain values**: Use `max()` and `min()` to limit rotation ranges
3. **Normalize angles**: Use `truncatingRemainder(dividingBy: 360)` for clean angle values
4. **Add haptic feedback**: Combine with `UIImpactFeedbackGenerator` for tactile response
5. **Visual feedback**: Show touch areas or active zones to guide users
6. **Smooth animations**: Use `.animation()` modifier for smooth transitions

## Need More Help?

Check out the [main README](README.md) for installation instructions and basic usage, or explore the demo app included in this repository.

