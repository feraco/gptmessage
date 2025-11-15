//
//  VisionServicesTests.swift
//  ChatGPTTests
//
//  Created by GitHub Copilot on 2025/11/15.
//

import XCTest
@testable import ChatGPT

final class VisionServicesTests: XCTestCase {
    
    var faceDataManager: FaceDataManager!
    var visionConfig: VisionConfiguration!
    
    override func setUpWithError() throws {
        faceDataManager = FaceDataManager.shared
        visionConfig = VisionConfiguration.shared
        // Clean up before tests
        faceDataManager.deleteAllFaceData()
        faceDataManager.hasUserConsent = false
    }
    
    override func tearDownWithError() throws {
        // Clean up after tests
        faceDataManager.deleteAllFaceData()
        faceDataManager.hasUserConsent = false
    }
    
    // MARK: - FaceDataManager Tests
    
    func testFaceDataManagerConsent() throws {
        // Test initial state
        XCTAssertFalse(faceDataManager.hasUserConsent, "User consent should be false initially")
        
        // Test setting consent
        faceDataManager.hasUserConsent = true
        XCTAssertTrue(faceDataManager.hasUserConsent, "User consent should be true after setting")
        
        // Test revoking consent
        faceDataManager.hasUserConsent = false
        XCTAssertFalse(faceDataManager.hasUserConsent, "User consent should be false after revoking")
    }
    
    func testSaveFaceDataWithoutConsent() throws {
        // Attempt to save face data without consent should throw error
        let features = FaceFeatures(
            boundingBox: CGRect(x: 0, y: 0, width: 100, height: 100),
            faceRect: CGRect(x: 0, y: 0, width: 100, height: 100),
            confidence: 0.95,
            roll: nil,
            yaw: nil,
            pitch: nil
        )
        
        let testImageData = Data([0x00, 0x01, 0x02])
        
        XCTAssertThrowsError(try faceDataManager.saveFaceData(name: "Test", features: features, imageData: testImageData)) { error in
            XCTAssertTrue(error is FaceDataError, "Should throw FaceDataError")
        }
    }
    
    func testSaveFaceDataWithConsent() throws {
        // Grant consent
        faceDataManager.hasUserConsent = true
        
        let features = FaceFeatures(
            boundingBox: CGRect(x: 0, y: 0, width: 100, height: 100),
            faceRect: CGRect(x: 0, y: 0, width: 100, height: 100),
            confidence: 0.95,
            roll: nil,
            yaw: nil,
            pitch: nil
        )
        
        let testImageData = Data([0x00, 0x01, 0x02])
        
        // Should not throw error
        try faceDataManager.saveFaceData(name: "TestUser", features: features, imageData: testImageData)
        
        // Verify data was saved
        let savedFaces = faceDataManager.loadAllFaceData()
        XCTAssertEqual(savedFaces.count, 1, "Should have one saved face")
        XCTAssertEqual(savedFaces.first?.name, "TestUser", "Saved face should have correct name")
    }
    
    func testLoadAllFaceData() throws {
        // Grant consent and save multiple faces
        faceDataManager.hasUserConsent = true
        
        let features1 = FaceFeatures(
            boundingBox: CGRect(x: 0, y: 0, width: 100, height: 100),
            faceRect: CGRect(x: 0, y: 0, width: 100, height: 100),
            confidence: 0.95,
            roll: nil,
            yaw: nil,
            pitch: nil
        )
        
        let features2 = FaceFeatures(
            boundingBox: CGRect(x: 50, y: 50, width: 120, height: 120),
            faceRect: CGRect(x: 50, y: 50, width: 120, height: 120),
            confidence: 0.92,
            roll: nil,
            yaw: nil,
            pitch: nil
        )
        
        let testImageData = Data([0x00, 0x01, 0x02])
        
        try faceDataManager.saveFaceData(name: "Alice", features: features1, imageData: testImageData)
        try faceDataManager.saveFaceData(name: "Bob", features: features2, imageData: testImageData)
        
        let savedFaces = faceDataManager.loadAllFaceData()
        XCTAssertEqual(savedFaces.count, 2, "Should have two saved faces")
    }
    
    func testDeleteFaceData() throws {
        // Grant consent and save face data
        faceDataManager.hasUserConsent = true
        
        let features = FaceFeatures(
            boundingBox: CGRect(x: 0, y: 0, width: 100, height: 100),
            faceRect: CGRect(x: 0, y: 0, width: 100, height: 100),
            confidence: 0.95,
            roll: nil,
            yaw: nil,
            pitch: nil
        )
        
        let testImageData = Data([0x00, 0x01, 0x02])
        try faceDataManager.saveFaceData(name: "TestUser", features: features, imageData: testImageData)
        
        // Verify saved
        XCTAssertEqual(faceDataManager.savedFaceCount, 1)
        
        // Delete
        try faceDataManager.deleteFaceData(forName: "TestUser")
        
        // Verify deleted
        XCTAssertEqual(faceDataManager.savedFaceCount, 0)
    }
    
    func testDeleteAllFaceData() throws {
        // Grant consent and save multiple faces
        faceDataManager.hasUserConsent = true
        
        let features = FaceFeatures(
            boundingBox: CGRect(x: 0, y: 0, width: 100, height: 100),
            faceRect: CGRect(x: 0, y: 0, width: 100, height: 100),
            confidence: 0.95,
            roll: nil,
            yaw: nil,
            pitch: nil
        )
        
        let testImageData = Data([0x00, 0x01, 0x02])
        try faceDataManager.saveFaceData(name: "Alice", features: features, imageData: testImageData)
        try faceDataManager.saveFaceData(name: "Bob", features: features, imageData: testImageData)
        
        XCTAssertEqual(faceDataManager.savedFaceCount, 2)
        
        // Delete all
        faceDataManager.deleteAllFaceData()
        
        // Verify all deleted
        XCTAssertEqual(faceDataManager.savedFaceCount, 0)
    }
    
    // MARK: - VisionInteractionManager Tests
    
    func testShouldTriggerVision() throws {
        let visionManager = VisionInteractionManager.shared
        
        // Disable vision first
        visionConfig.isVisionEnabled = false
        XCTAssertFalse(visionManager.shouldTriggerVision(for: "who is in front of me"))
        
        // Enable vision
        visionConfig.isVisionEnabled = true
        
        // Test various vision keywords
        XCTAssertTrue(visionManager.shouldTriggerVision(for: "Who is in front of me?"))
        XCTAssertTrue(visionManager.shouldTriggerVision(for: "What do you see?"))
        XCTAssertTrue(visionManager.shouldTriggerVision(for: "Describe what you see"))
        XCTAssertTrue(visionManager.shouldTriggerVision(for: "Who am I?"))
        
        // Test non-vision keywords
        XCTAssertFalse(visionManager.shouldTriggerVision(for: "Hello, how are you?"))
        XCTAssertFalse(visionManager.shouldTriggerVision(for: "What is the weather today?"))
    }
    
    func testDetectsIntroduction() throws {
        let visionManager = VisionInteractionManager.shared
        
        // Test various introduction patterns
        XCTAssertEqual(visionManager.detectsIntroduction(in: "My name is John"), "John")
        XCTAssertEqual(visionManager.detectsIntroduction(in: "I am Sarah"), "Sarah")
        XCTAssertEqual(visionManager.detectsIntroduction(in: "I'm Alex"), "Alex")
        XCTAssertEqual(visionManager.detectsIntroduction(in: "Call me Mike"), "Mike")
        XCTAssertEqual(visionManager.detectsIntroduction(in: "This is Emily"), "Emily")
        
        // Test non-introduction text
        XCTAssertNil(visionManager.detectsIntroduction(in: "Hello, how are you?"))
        XCTAssertNil(visionManager.detectsIntroduction(in: "What's the weather?"))
    }
    
    // MARK: - VisionConfiguration Tests
    
    func testVisionConfigurationDefaults() throws {
        // Test default values
        XCTAssertFalse(visionConfig.isVisionEnabled, "Vision should be disabled by default")
        XCTAssertFalse(visionConfig.isFaceRecognitionEnabled, "Face recognition should be disabled by default")
        XCTAssertTrue(visionConfig.isSceneAnalysisEnabled, "Scene analysis should be enabled by default")
        XCTAssertFalse(visionConfig.isAutoCaptureEnabled, "Auto capture should be disabled by default")
    }
    
    func testClearAllFaceData() throws {
        // Set up face data
        faceDataManager.hasUserConsent = true
        let features = FaceFeatures(
            boundingBox: CGRect(x: 0, y: 0, width: 100, height: 100),
            faceRect: CGRect(x: 0, y: 0, width: 100, height: 100),
            confidence: 0.95,
            roll: nil,
            yaw: nil,
            pitch: nil
        )
        let testImageData = Data([0x00, 0x01, 0x02])
        try faceDataManager.saveFaceData(name: "TestUser", features: features, imageData: testImageData)
        
        XCTAssertTrue(visionConfig.hasFaceRecognitionConsent)
        XCTAssertEqual(visionConfig.savedFaceCount, 1)
        
        // Clear all data via configuration
        visionConfig.clearAllFaceData()
        
        XCTAssertFalse(visionConfig.hasFaceRecognitionConsent)
        XCTAssertEqual(visionConfig.savedFaceCount, 0)
    }
}
