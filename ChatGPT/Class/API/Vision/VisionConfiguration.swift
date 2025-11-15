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
#if os(iOS)
            FaceDataManager.shared.hasUserConsent
#else
            false
#endif
        }
        set {
#if os(iOS)
            FaceDataManager.shared.hasUserConsent = newValue
#endif
        }
    }
    
    /// Number of saved faces
    var savedFaceCount: Int {
#if os(iOS)
        FaceDataManager.shared.savedFaceCount
#else
        0
#endif
    }
    
    /// Clears all saved face data
    func clearAllFaceData() {
#if os(iOS)
        FaceDataManager.shared.deleteAllFaceData()
        FaceDataManager.shared.hasUserConsent = false
#endif
    }
}
