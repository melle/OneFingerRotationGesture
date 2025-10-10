import SwiftUI
import OneFingerRotationGesture

struct ContentView: View {
    @State private var rotation: CGFloat = 0
    @State private var displayAngle: CGFloat = 0

    // Constants
    private let touchAreaDiameter: CGFloat = 320         // Touch detection area size
    private let visibleKnobImageDiameter: CGFloat = 260  // Visible button image size
    private let innerRadiusRatio: CGFloat = 0.25         // Inner dead zone
    private let outerRadiusRatio: CGFloat = 1.0          // Outer boundary (320pt diameter)
    
    var body: some View {
        let _ = Self._printChanges()
        VStack(spacing: 20) {
            
            Text("One Finger Rotation Gesture")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                

            Text("Drag your finger in a circular motion around the knob")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            // Rotatable Knob
            ZStack {
                
                // Button Image Knob
                Image("Button")
                    .resizable()
                    .scaledToFit()
                    .frame(width: visibleKnobImageDiameter, height: visibleKnobImageDiameter)
                    .rotationEffect(.degrees(Double(rotation)))
                    .animation(nil, value: rotation) // Disable animation for gesture-driven rotation
                    .drawingGroup() // Optimize rendering

                // Outer radius indicator - shows maximum touch detection boundary
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 15]))
                    .foregroundColor(.red.opacity(0.6))
                    .frame(width: touchAreaDiameter, height: touchAreaDiameter)
                    .allowsHitTesting(false)
                
                // Inner radius indicator - shows minimum touch detection boundary (center dead zone)
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 15]))
                    .foregroundColor(.red.opacity(0.6))
                    .frame(
                        width: touchAreaDiameter * innerRadiusRatio,
                        height: touchAreaDiameter * innerRadiusRatio
                    )
                    .allowsHitTesting(false)
            }
            .frame(width: touchAreaDiameter, height: touchAreaDiameter)
            .oneFingerRotation(
                innerRadiusRatio: innerRadiusRatio,
                outerRadiusRatio: outerRadiusRatio
            ) { angle in
                // Called during rotation with angle delta
                rotation += angle
                displayAngle = rotation.truncatingRemainder(dividingBy: 360)
            } onEnd: { totalAngle in
                // Called when gesture ends
                print("Gesture ended with total rotation: \(totalAngle)°")
            }
            
            Spacer()
            
            // Angle display
            VStack(spacing: 8) {
                Text("Current Angle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("α = \(displayAngle, specifier: "%.2f")°")
                    .font(.system(size: 32, weight: .medium, design: .monospaced))
                    .foregroundStyle(.primary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
            
            Spacer()
        }
        .safeAreaPadding()
        .padding([.horizontal, .bottom])
    }
}

#Preview {
    ContentView()
}
