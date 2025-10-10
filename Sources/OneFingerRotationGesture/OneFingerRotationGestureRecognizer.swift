import UIKit

/// A gesture recognizer that detects one-finger rotation gestures within a circular area.
///
/// This recognizer tracks touch movements within a defined annular region (ring-shaped area)
/// and calculates the rotation angle as the finger moves around a center point.
///
/// The gesture is useful for implementing controls like volume knobs, dials, or any
/// circular rotation interface where the user drags their finger in a circular motion.
@MainActor
public final class OneFingerRotationGestureRecognizer: UIGestureRecognizer {
    
    // MARK: - Public Properties
    
    /// The center point of the circular gesture area
    public var midPoint: CGPoint
    
    /// The minimum distance from the center point where touches are recognized
    public var innerRadius: CGFloat
    
    /// The maximum distance from the center point where touches are recognized
    public var outerRadius: CGFloat
    
    /// The cumulated rotation angle in degrees since the gesture began
    public private(set) var cumulatedAngle: CGFloat = 0
    
    // MARK: - Callbacks
    
    /// Called continuously as the rotation angle changes during the gesture
    public var onRotation: ((CGFloat) -> Void)?
    
    /// Called once when the gesture ends with the final cumulated angle
    public var onFinalAngle: ((CGFloat) -> Void)?
    
    // MARK: - Initialization
    
    /// Creates a new one-finger rotation gesture recognizer.
    ///
    /// - Parameters:
    ///   - midPoint: The center point of the circular gesture area
    ///   - innerRadius: The minimum distance from center where touches are recognized
    ///   - outerRadius: The maximum distance from center where touches are recognized
    public init(midPoint: CGPoint, innerRadius: CGFloat, outerRadius: CGFloat) {
        self.midPoint = midPoint
        self.innerRadius = innerRadius
        self.outerRadius = outerRadius
        super.init(target: nil, action: nil)
    }
    
    // MARK: - UIGestureRecognizer Overrides
    
    public override func reset() {
        super.reset()
        cumulatedAngle = 0
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        // Only single-touch gestures are supported
        if touches.count != 1 {
            state = .failed
            return
        }
        
        // Verify the initial touch is within the valid area
        guard let touch = touches.first, let view = view else {
            state = .failed
            return
        }
        
        let touchPoint = touch.location(in: view)
        let distance = distanceBetweenPoints(midPoint, touchPoint)
        
        if distance >= innerRadius && distance <= outerRadius {
            // Touch is in valid area, gesture can begin
            state = .began
        } else {
            // Touch outside valid area
            state = .failed
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        guard state != .failed && state != .cancelled,
              let touch = touches.first,
              let view = view else {
            return
        }
        
        let nowPoint = touch.location(in: view)
        let prevPoint = touch.previousLocation(in: view)
        
        // Verify the touch is within the valid annular region
        let distance = distanceBetweenPoints(midPoint, nowPoint)
        
        if distance >= innerRadius && distance <= outerRadius {
            // Update state to changed if gesture is active
            if state == .began || state == .changed {
                state = .changed
            }
            
            // Calculate the rotation angle between previous and current position
            var angle = angleBetweenLinesInDegrees(
                beginLineA: midPoint, endLineA: prevPoint,
                beginLineB: midPoint, endLineB: nowPoint
            )
            
            // Normalize angle when crossing the 12 o'clock position
            if angle > 180 {
                angle -= 360
            } else if angle < -180 {
                angle += 360
            }
            
            // Accumulate the angle change
            cumulatedAngle += angle
            
            // Notify observers of the rotation
            onRotation?(angle)
        } else {
            // Finger moved outside the valid area
            state = .failed
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        
        if state == .began || state == .changed {
            state = .ended
            onFinalAngle?(cumulatedAngle)
        } else {
            state = .failed
        }
        
        cumulatedAngle = 0
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        state = .cancelled
        cumulatedAngle = 0
    }
    
    // MARK: - Helper Functions
    
    /// Calculates the distance between two points.
    private func distanceBetweenPoints(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
        let dx = point1.x - point2.x
        let dy = point1.y - point2.y
        return sqrt(dx * dx + dy * dy)
    }
    
    /// Calculates the angle in degrees between two lines.
    ///
    /// Both lines share the same starting point (beginLineA and beginLineB should be the same).
    ///
    /// - Parameters:
    ///   - beginLineA: The starting point of the first line
    ///   - endLineA: The ending point of the first line
    ///   - beginLineB: The starting point of the second line
    ///   - endLineB: The ending point of the second line
    /// - Returns: The angle in degrees between the two lines
    private func angleBetweenLinesInDegrees(
        beginLineA: CGPoint,
        endLineA: CGPoint,
        beginLineB: CGPoint,
        endLineB: CGPoint
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
}

