import XCTest
@testable import OneFingerRotationGesture

/// Unit tests for OneFingerRotationGesture library
@MainActor
final class OneFingerRotationGestureTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testGestureRecognizerInitialization() {
        let midPoint = CGPoint(x: 100, y: 100)
        let innerRadius: CGFloat = 30
        let outerRadius: CGFloat = 100
        
        let recognizer = OneFingerRotationGestureRecognizer(
            midPoint: midPoint,
            innerRadius: innerRadius,
            outerRadius: outerRadius
        )
        
        XCTAssertEqual(recognizer.midPoint, midPoint)
        XCTAssertEqual(recognizer.innerRadius, innerRadius)
        XCTAssertEqual(recognizer.outerRadius, outerRadius)
        XCTAssertEqual(recognizer.cumulatedAngle, 0)
    }
    
    // MARK: - Reset Tests
    
    func testReset() {
        let recognizer = OneFingerRotationGestureRecognizer(
            midPoint: CGPoint(x: 100, y: 100),
            innerRadius: 30,
            outerRadius: 100
        )
        
        recognizer.reset()
        
        XCTAssertEqual(recognizer.cumulatedAngle, 0)
    }
    
    // MARK: - Callback Tests
    
    func testRotationCallback() {
        let recognizer = OneFingerRotationGestureRecognizer(
            midPoint: CGPoint(x: 100, y: 100),
            innerRadius: 30,
            outerRadius: 100
        )
        
        var rotationCallbackCalled = false
        var receivedAngle: CGFloat = 0
        
        recognizer.onRotation = { angle in
            rotationCallbackCalled = true
            receivedAngle = angle
        }
        
        // Note: This test validates the callback setup.
        // Actual touch simulation would require UIKit test infrastructure
        XCTAssertNotNil(recognizer.onRotation)
    }
    
    func testFinalAngleCallback() {
        let recognizer = OneFingerRotationGestureRecognizer(
            midPoint: CGPoint(x: 100, y: 100),
            innerRadius: 30,
            outerRadius: 100
        )
        
        var finalAngleCallbackCalled = false
        var receivedAngle: CGFloat = 0
        
        recognizer.onFinalAngle = { angle in
            finalAngleCallbackCalled = true
            receivedAngle = angle
        }
        
        XCTAssertNotNil(recognizer.onFinalAngle)
    }
    
    // MARK: - Property Tests
    
    func testMidPointCanBeUpdated() {
        let recognizer = OneFingerRotationGestureRecognizer(
            midPoint: CGPoint(x: 100, y: 100),
            innerRadius: 30,
            outerRadius: 100
        )
        
        let newMidPoint = CGPoint(x: 150, y: 150)
        recognizer.midPoint = newMidPoint
        
        XCTAssertEqual(recognizer.midPoint, newMidPoint)
    }
    
    func testInnerRadiusCanBeUpdated() {
        let recognizer = OneFingerRotationGestureRecognizer(
            midPoint: CGPoint(x: 100, y: 100),
            innerRadius: 30,
            outerRadius: 100
        )
        
        recognizer.innerRadius = 50
        
        XCTAssertEqual(recognizer.innerRadius, 50)
    }
    
    func testOuterRadiusCanBeUpdated() {
        let recognizer = OneFingerRotationGestureRecognizer(
            midPoint: CGPoint(x: 100, y: 100),
            innerRadius: 30,
            outerRadius: 100
        )
        
        recognizer.outerRadius = 120
        
        XCTAssertEqual(recognizer.outerRadius, 120)
    }
}

