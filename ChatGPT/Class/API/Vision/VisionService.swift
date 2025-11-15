//
//  VisionService.swift
//  ChatGPT
//
//  Created by GitHub Copilot on 2025/11/15.
//

import Foundation
import Vision
import CoreImage
import UIKit

/// Service for performing Vision framework operations like face detection, object recognition, and scene analysis
class VisionService {
    
    static let shared = VisionService()
    
    private init() {}
    
    // MARK: - Face Detection
    
    /// Detects faces in an image and returns face observations
    func detectFaces(in image: UIImage) async throws -> [VNFaceObservation] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectFaceRectanglesRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNFaceObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                continuation.resume(returning: observations)
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    /// Detects face landmarks (eyes, nose, mouth, etc.) in an image
    func detectFaceLandmarks(in image: UIImage) async throws -> [VNFaceObservation] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectFaceLandmarksRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNFaceObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                continuation.resume(returning: observations)
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    // MARK: - Object and Scene Recognition
    
    /// Classifies the scene and objects in an image
    func classifyImage(_ image: UIImage) async throws -> [VNClassificationObservation] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                // Return top 5 classifications
                let topResults = Array(observations.prefix(5))
                continuation.resume(returning: topResults)
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    /// Detects objects in an image (for saliency analysis)
    func detectSaliency(in image: UIImage) async throws -> VNSaliencyImageObservation? {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNGenerateAttentionBasedSaliencyImageRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observation = request.results?.first as? VNSaliencyImageObservation else {
                    continuation.resume(returning: nil)
                    return
                }
                
                continuation.resume(returning: observation)
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    /// Detects text in an image
    func detectText(in image: UIImage) async throws -> [VNRecognizedTextObservation] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                continuation.resume(returning: observations)
            }
            
            request.recognitionLevel = .accurate
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    // MARK: - Edge Detection
    
    /// Detects edges in an image
    func detectEdges(in image: UIImage) async throws -> VNContoursObservation? {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectContoursRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observation = request.results?.first as? VNContoursObservation else {
                    continuation.resume(returning: nil)
                    return
                }
                
                continuation.resume(returning: observation)
            }
            
            request.contrastAdjustment = 1.5
            request.detectsDarkOnLight = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Generates a natural language description of what's in the image
    func generateImageDescription(_ image: UIImage) async throws -> String {
        // Perform multiple analyses
        async let faces = detectFaces(in: image)
        async let classifications = classifyImage(image)
        async let text = detectText(in: image)
        
        var description = ""
        
        // Analyze faces
        let faceObservations = try await faces
        if !faceObservations.isEmpty {
            description += "I can see \(faceObservations.count) "
            description += faceObservations.count == 1 ? "person" : "people"
            description += " in the image. "
        }
        
        // Analyze scene
        let sceneClassifications = try await classifications
        if let topClassification = sceneClassifications.first {
            if topClassification.confidence > 0.3 {
                description += "The scene appears to be \(topClassification.identifier) "
                description += "(confidence: \(Int(topClassification.confidence * 100))%). "
            }
        }
        
        // Add secondary classifications
        let secondaryClassifications = sceneClassifications.dropFirst().prefix(2)
        if !secondaryClassifications.isEmpty {
            let items = secondaryClassifications
                .filter { $0.confidence > 0.2 }
                .map { $0.identifier }
            if !items.isEmpty {
                description += "I also detect: \(items.joined(separator: ", ")). "
            }
        }
        
        // Analyze text
        let textObservations = try await text
        if !textObservations.isEmpty {
            description += "There is text visible in the image. "
        }
        
        if description.isEmpty {
            description = "I can see an image, but I'm unable to provide specific details about its contents."
        }
        
        return description.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Extracts face feature data that can be used for comparison
    func extractFaceFeatures(from observation: VNFaceObservation, image: UIImage) -> FaceFeatures? {
        guard let cgImage = image.cgImage else { return nil }
        
        let boundingBox = observation.boundingBox
        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)
        
        // Convert from normalized coordinates to pixel coordinates
        let x = boundingBox.origin.x * imageWidth
        let y = (1 - boundingBox.origin.y - boundingBox.height) * imageHeight
        let width = boundingBox.width * imageWidth
        let height = boundingBox.height * imageHeight
        
        let faceRect = CGRect(x: x, y: y, width: width, height: height)
        
        return FaceFeatures(
            boundingBox: boundingBox,
            faceRect: faceRect,
            confidence: observation.confidence,
            roll: observation.roll?.doubleValue,
            yaw: observation.yaw?.doubleValue,
            pitch: observation.pitch?.doubleValue
        )
    }
}

// MARK: - Supporting Types

enum VisionError: LocalizedError {
    case invalidImage
    case noFacesDetected
    case processingFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "The provided image is invalid or cannot be processed."
        case .noFacesDetected:
            return "No faces were detected in the image."
        case .processingFailed:
            return "Vision processing failed."
        }
    }
}

struct FaceFeatures: Codable {
    let boundingBox: CGRect
    let faceRect: CGRect
    let confidence: Float
    let roll: Double?
    let yaw: Double?
    let pitch: Double?
}

// Extension to make CGRect Codable
extension CGRect: Codable {
    enum CodingKeys: String, CodingKey {
        case x, y, width, height
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(origin.x, forKey: .x)
        try container.encode(origin.y, forKey: .y)
        try container.encode(size.width, forKey: .width)
        try container.encode(size.height, forKey: .height)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(CGFloat.self, forKey: .x)
        let y = try container.decode(CGFloat.self, forKey: .y)
        let width = try container.decode(CGFloat.self, forKey: .width)
        let height = try container.decode(CGFloat.self, forKey: .height)
        self.init(x: x, y: y, width: width, height: height)
    }
}
