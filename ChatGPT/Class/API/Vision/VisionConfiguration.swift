//
//  VisionConfiguration.swift
//  ChatGPT
//
//  Created by GitHub Copilot on 2025/11/15.
//

import Foundation
import SwiftUI

/// Configuration for Vision-based features
class VisionConfiguration: ObservableObject {
    
    static let shared = VisionConfiguration()
    
    @AppStorage("vision.isEnabled") var isVisionEnabled: Bool = false
    
    @AppStorage("vision.faceRecognitionEnabled") var isFaceRecognitionEnabled: Bool = false
    
    @AppStorage("vision.autoCapture") var isAutoCaptureEnabled: Bool = false
    
    @AppStorage("vision.sceneAnalysis") var isSceneAnalysisEnabled: Bool = true
    
    private init() {}
    
    /// Checks if user has given consent for face recognition
    var hasFaceRecognitionConsent: Bool {
        get {
            FaceDataManager.shared.hasUserConsent
        }
        set {
            FaceDataManager.shared.hasUserConsent = newValue
        }
    }
    
    /// Number of saved faces
    var savedFaceCount: Int {
        FaceDataManager.shared.savedFaceCount
    }
    
    /// Clears all saved face data
    func clearAllFaceData() {
        FaceDataManager.shared.deleteAllFaceData()
        FaceDataManager.shared.hasUserConsent = false
    }
}
