import SwiftUI

/// A SwiftUI view modifier that adds one-finger rotation gesture recognition to a view.
///
/// This modifier enables circular rotation gestures on any SwiftUI view, making it easy
/// to implement knob-style controls, dials, or any interface that requires rotation input.
///
/// Example usage:
/// ```swift
/// Circle()
///     .frame(width: 200, height: 200)
///     .oneFingerRotation(innerRadiusRatio: 0.3) { angle in
///         print("Rotated by \(angle) degrees")
///     }
/// ```
@MainActor
public struct OneFingerRotationModifier: ViewModifier {
    let innerRadiusRatio: CGFloat
    let outerRadiusRatio: CGFloat
    let onRotation: (CGFloat) -> Void
    let onEnd: ((CGFloat) -> Void)?
    
    @State private var viewSize: CGSize = .zero
    
    public func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            viewSize = geometry.size
                        }
                        .onChange(of: geometry.size) { _, newSize in
                            viewSize = newSize
                        }
                }
            )
            .overlay(
                GestureRecognizerView(
                    viewSize: viewSize,
                    innerRadiusRatio: innerRadiusRatio,
                    outerRadiusRatio: outerRadiusRatio,
                    onRotation: onRotation,
                    onEnd: onEnd
                )
            )
    }
}

/// Internal UIViewRepresentable that wraps the UIGestureRecognizer for SwiftUI
@MainActor
private struct GestureRecognizerView: UIViewRepresentable {
    let viewSize: CGSize
    let innerRadiusRatio: CGFloat
    let outerRadiusRatio: CGFloat
    let onRotation: (CGFloat) -> Void
    let onEnd: ((CGFloat) -> Void)?
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Only add gesture if view has valid size
        guard viewSize.width > 0, viewSize.height > 0 else { return }
        
        // Calculate the circular gesture area based on view size
        let midPoint = CGPoint(x: viewSize.width / 2, y: viewSize.height / 2)
        let maxRadius = min(viewSize.width, viewSize.height) / 2
        let innerRadius = maxRadius * innerRadiusRatio
        let outerRadius = maxRadius * outerRadiusRatio
        
        // Find existing gesture recognizer or create new one
        let recognizer: OneFingerRotationGestureRecognizer
        if let existing = uiView.gestureRecognizers?.first(where: { $0 is OneFingerRotationGestureRecognizer }) as? OneFingerRotationGestureRecognizer {
            // Update existing recognizer properties
            recognizer = existing
            recognizer.midPoint = midPoint
            recognizer.innerRadius = innerRadius
            recognizer.outerRadius = outerRadius
        } else {
            // Create and add new gesture recognizer
            recognizer = OneFingerRotationGestureRecognizer(
                midPoint: midPoint,
                innerRadius: innerRadius,
                outerRadius: outerRadius
            )
            uiView.addGestureRecognizer(recognizer)
        }
        
        // Always update callbacks (these are closures that may capture new state)
        recognizer.onRotation = onRotation
        recognizer.onFinalAngle = onEnd
    }
}

// MARK: - View Extension

extension View {
    /// Adds a one-finger rotation gesture recognizer to the view.
    ///
    /// The gesture recognizes circular dragging motions within an annular region
    /// (ring-shaped area) of the view. The region is defined by inner and outer
    /// radius ratios relative to the view's size.
    ///
    /// - Parameters:
    ///   - innerRadiusRatio: The ratio (0.0-1.0) of the inner radius to the view's radius.
    ///                       Default is 0.3. Use values > 0 to avoid erratic behavior
    ///                       when touching near the center.
    ///   - outerRadiusRatio: The ratio (0.0-1.0) of the outer radius to the view's radius.
    ///                       Default is 1.0 (full view size).
    ///   - onRotation: Called continuously with the angle delta in degrees as the user rotates.
    ///   - onEnd: Optional callback with the cumulated angle when the gesture ends.
    /// - Returns: A view with the rotation gesture recognizer attached.
    ///
    /// Example:
    /// ```swift
    /// Circle()
    ///     .fill(.blue)
    ///     .frame(width: 200, height: 200)
    ///     .oneFingerRotation(innerRadiusRatio: 0.3) { angle in
    ///         print("Rotation delta: \(angle)°")
    ///     } onEnd: { totalAngle in
    ///         print("Total rotation: \(totalAngle)°")
    ///     }
    /// ```
    @MainActor
    public func oneFingerRotation(
        innerRadiusRatio: CGFloat = 0.3,
        outerRadiusRatio: CGFloat = 1.0,
        onRotation: @escaping (CGFloat) -> Void,
        onEnd: ((CGFloat) -> Void)? = nil
    ) -> some View {
        modifier(
            OneFingerRotationModifier(
                innerRadiusRatio: innerRadiusRatio,
                outerRadiusRatio: outerRadiusRatio,
                onRotation: onRotation,
                onEnd: onEnd
            )
        )
    }
}

