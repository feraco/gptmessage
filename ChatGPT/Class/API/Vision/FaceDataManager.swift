//
//  FaceDataManager.swift
//  ChatGPT
//
//  Created by GitHub Copilot on 2025/11/15.
//

import Foundation
#if os(iOS)
import UIKit

/// Manages storage and retrieval of facial recognition data with user consent
class FaceDataManager {
    
    static let shared = FaceDataManager()
    
    private let userDefaults = UserDefaults.standard
    private let faceDataKey = "com.chatgpt.faceData"
    private let consentKey = "com.chatgpt.faceRecognitionConsent"
    
    private init() {}
    
    // MARK: - Consent Management
    
    /// Checks if user has given consent for face recognition
    var hasUserConsent: Bool {
        get {
            userDefaults.bool(forKey: consentKey)
        }
        set {
            userDefaults.set(newValue, forKey: consentKey)
        }
    }
    
    // MARK: - Face Data Storage
    
    /// Saves face data associated with a name
    func saveFaceData(name: String, features: FaceFeatures, imageData: Data) throws {
        guard hasUserConsent else {
            throw FaceDataError.consentNotGiven
        }
        
        var allFaceData = loadAllFaceData()
        
        let faceEntry = FaceDataEntry(
            id: UUID(),
            name: name,
            features: features,
            imageData: imageData,
            dateCreated: Date()
        )
        
        // Check if this person already exists and update
        if let existingIndex = allFaceData.firstIndex(where: { $0.name.lowercased() == name.lowercased() }) {
            allFaceData[existingIndex] = faceEntry
        } else {
            allFaceData.append(faceEntry)
        }
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(allFaceData)
        userDefaults.set(data, forKey: faceDataKey)
    }
    
    /// Loads all saved face data
    func loadAllFaceData() -> [FaceDataEntry] {
        guard let data = userDefaults.data(forKey: faceDataKey) else {
            return []
        }
        
        let decoder = JSONDecoder()
        guard let faceData = try? decoder.decode([FaceDataEntry].self, from: data) else {
            return []
        }
        
        return faceData
    }
    
    /// Finds a matching face by comparing features
    func findMatchingFace(for features: FaceFeatures) -> FaceDataEntry? {
        guard hasUserConsent else {
            return nil
        }
        
        let allFaces = loadAllFaceData()
        
        // Simple matching based on bounding box similarity and orientation
        // In a production app, you'd use more sophisticated face recognition
        for face in allFaces {
            if areFacesSimilar(features, face.features) {
                return face
            }
        }
        
        return nil
    }
    
    /// Retrieves face data by name
    func getFaceData(forName name: String) -> FaceDataEntry? {
        let allFaces = loadAllFaceData()
        return allFaces.first { $0.name.lowercased() == name.lowercased() }
    }
    
    /// Deletes face data for a specific person
    func deleteFaceData(forName name: String) throws {
        var allFaceData = loadAllFaceData()
        allFaceData.removeAll { $0.name.lowercased() == name.lowercased() }
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(allFaceData)
        userDefaults.set(data, forKey: faceDataKey)
    }
    
    /// Deletes all face data
    func deleteAllFaceData() {
        userDefaults.removeObject(forKey: faceDataKey)
    }
    
    /// Gets count of saved faces
    var savedFaceCount: Int {
        loadAllFaceData().count
    }
    
    // MARK: - Private Helpers
    
    private func areFacesSimilar(_ face1: FaceFeatures, _ face2: FaceFeatures) -> Bool {
        // Compare bounding box sizes (within 20% tolerance)
        let sizeRatio = face1.boundingBox.size.width / face2.boundingBox.size.width
        let sizeSimilar = sizeRatio > 0.8 && sizeRatio < 1.2
        
        // Compare orientations if available
        var orientationSimilar = true
        if let yaw1 = face1.yaw, let yaw2 = face2.yaw {
            orientationSimilar = abs(yaw1 - yaw2) < 0.3 // Radians
        }
        
        // This is a very basic comparison. In production, you'd use:
        // - Face embeddings/descriptors from VNGenerateFaceObservationRequest
        // - Machine learning models trained on face recognition
        // - More sophisticated feature comparison
        
        return sizeSimilar && orientationSimilar
    }
}

// MARK: - Supporting Types

struct FaceDataEntry: Codable, Identifiable {
    let id: UUID
    let name: String
    let features: FaceFeatures
    let imageData: Data
    let dateCreated: Date
    
    var image: UIImage? {
        UIImage(data: imageData)
    }
}

enum FaceDataError: LocalizedError {
    case consentNotGiven
    case saveFailed
    case loadFailed
    
    var errorDescription: String? {
        switch self {
        case .consentNotGiven:
            return "User consent is required to save face recognition data."
        case .saveFailed:
            return "Failed to save face data."
        case .loadFailed:
            return "Failed to load face data."
        }
    }
}
#endif
