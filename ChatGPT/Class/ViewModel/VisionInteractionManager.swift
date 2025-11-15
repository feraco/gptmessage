//
//  VisionInteractionManager.swift
//  ChatGPT
//
//  Created by GitHub Copilot on 2025/11/15.
//

import Foundation
import UIKit

/// Manages vision-based interactions and integrates with conversation flow
class VisionInteractionManager: ObservableObject {
    
    static let shared = VisionInteractionManager()
    
    private let visionService = VisionService.shared
    private let faceDataManager = FaceDataManager.shared
    private let visionConfig = VisionConfiguration.shared
    
    @Published var isProcessingVision = false
    @Published var lastCapturedImage: UIImage?
    
    private init() {}
    
    // MARK: - Vision Command Detection
    
    /// Keywords that trigger vision-based responses
    private let visionKeywords = [
        "who is in front of me",
        "who am i",
        "what do you see",
        "describe what you see",
        "analyze this scene",
        "what's in this image",
        "recognize me",
        "who is this",
        "tell me what you see"
    ]
    
    /// Checks if a message contains vision-related keywords
    func shouldTriggerVision(for message: String) -> Bool {
        guard visionConfig.isVisionEnabled else { return false }
        
        let lowercased = message.lowercased()
        return visionKeywords.contains { lowercased.contains($0) }
    }
    
    // MARK: - Vision Processing
    
    /// Processes an image and generates a conversational response
    func processImage(_ image: UIImage, withPrompt prompt: String) async throws -> String {
        isProcessingVision = true
        defer { isProcessingVision = false }
        
        lastCapturedImage = image
        
        // Check what kind of analysis is requested
        let lowercased = prompt.lowercased()
        
        if lowercased.contains("who") && visionConfig.isFaceRecognitionEnabled {
            return try await processFaceRecognition(image, prompt: prompt)
        } else if visionConfig.isSceneAnalysisEnabled {
            return try await visionService.generateImageDescription(image)
        } else {
            return "Vision features are currently disabled. Please enable them in settings."
        }
    }
    
    /// Processes face recognition and responds accordingly
    private func processFaceRecognition(_ image: UIImage, prompt: String) async throws -> String {
        guard faceDataManager.hasUserConsent else {
            return "I can detect faces, but face recognition is not enabled. Would you like to enable it in settings?"
        }
        
        let faces = try await visionService.detectFaces(in: image)
        
        guard !faces.isEmpty else {
            return "I don't see any faces in front of you right now."
        }
        
        var response = ""
        
        // Check if we recognize any faces
        var recognizedCount = 0
        var unrecognizedCount = 0
        var names: [String] = []
        
        for (index, faceObservation) in faces.enumerated() {
            if let features = visionService.extractFaceFeatures(from: faceObservation, image: image) {
                if let matchingFace = faceDataManager.findMatchingFace(for: features) {
                    recognizedCount += 1
                    names.append(matchingFace.name)
                } else {
                    unrecognizedCount += 1
                }
            }
        }
        
        // Generate response based on what we found
        if recognizedCount > 0 {
            if recognizedCount == 1 {
                response = "I can see \(names[0])! "
            } else {
                let allNames = names.joined(separator: ", ")
                response = "I can see \(allNames)! "
            }
        }
        
        if unrecognizedCount > 0 {
            if recognizedCount == 0 {
                response += "I can see \(unrecognizedCount == 1 ? "a person" : "\(unrecognizedCount) people"), but I don't recognize \(unrecognizedCount == 1 ? "them" : "them") yet. "
                response += "Would you like to introduce \(unrecognizedCount == 1 ? "yourself" : "yourselves")?"
            } else {
                response += "I also see \(unrecognizedCount == 1 ? "someone" : "\(unrecognizedCount) others") I don't recognize yet."
            }
        }
        
        return response
    }
    
    /// Associates a face with a name based on the last captured image
    func associateFaceWithName(_ name: String) async throws -> String {
        guard let image = lastCapturedImage else {
            throw VisionError.invalidImage
        }
        
        guard faceDataManager.hasUserConsent else {
            throw FaceDataError.consentNotGiven
        }
        
        let faces = try await visionService.detectFaces(in: image)
        
        guard let firstFace = faces.first else {
            throw VisionError.noFacesDetected
        }
        
        guard let features = visionService.extractFaceFeatures(from: firstFace, image: image) else {
            throw VisionError.processingFailed
        }
        
        // Save face data with image thumbnail
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw VisionError.processingFailed
        }
        
        try faceDataManager.saveFaceData(name: name, features: features, imageData: imageData)
        
        return "Nice to meet you, \(name)! I'll remember you for next time."
    }
    
    /// Detects if user is trying to introduce themselves
    func detectsIntroduction(in message: String) -> String? {
        let lowercased = message.lowercased()
        
        // Patterns for self-introduction
        let patterns = [
            "my name is ",
            "i am ",
            "i'm ",
            "call me ",
            "this is "
        ]
        
        for pattern in patterns {
            if let range = lowercased.range(of: pattern) {
                let nameStart = lowercased.index(range.upperBound, offsetBy: 0)
                let restOfString = String(message[nameStart...])
                
                // Extract name (first word after pattern)
                let components = restOfString.components(separatedBy: CharacterSet.letters.inverted)
                if let name = components.first(where: { !$0.isEmpty }) {
                    return name.capitalized
                }
            }
        }
        
        return nil
    }
}
