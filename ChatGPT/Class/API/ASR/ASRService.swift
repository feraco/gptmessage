//
//  ASRService.swift
//  ChatGPT
//
//  Automated Speech Recognition Service
//  Supports multiple ASR providers: Google, Whisper, Azure
//

import Foundation
import AVFoundation
import SwiftUI

/// ASR Provider types
enum ASRProvider: String, CaseIterable, Codable {
    case google = "Google Speech-to-Text"
    case whisper = "OpenAI Whisper"
    case azure = "Microsoft Azure Speech"
    
    var requiresAPIKey: Bool {
        switch self {
        case .google, .azure:
            return true
        case .whisper:
            return true // Uses OpenAI API key
        }
    }
}

/// ASR Service for converting speech to text
class ASRService: @unchecked Sendable {
    
    static let shared = ASRService()
    
    private var audioRecorder: AVAudioRecorder?
    private var audioEngine: AVAudioEngine?
    private let audioSession = AVAudioSession.sharedInstance()
    
    private init() {}
    
    /// Start recording audio
    func startRecording() async throws -> URL {
        // Request microphone permission
        try await requestMicrophonePermission()
        
        // Configure audio session
        try audioSession.setCategory(.record, mode: .measurement)
        try audioSession.setActive(true)
        
        // Create temporary file for recording
        let tempDir = FileManager.default.temporaryDirectory
        let audioFilename = tempDir.appendingPathComponent("recording_\(UUID().uuidString).m4a")
        
        // Configure recorder settings
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
        audioRecorder?.record()
        
        return audioFilename
    }
    
    /// Stop recording and return the audio file
    func stopRecording() -> URL? {
        guard let recorder = audioRecorder else { return nil }
        
        recorder.stop()
        let url = recorder.url
        audioRecorder = nil
        
        // Deactivate audio session
        try? audioSession.setActive(false)
        
        return url
    }
    
    /// Request microphone permission
    private func requestMicrophonePermission() async throws {
        let status = audioSession.recordPermission
        
        switch status {
        case .granted:
            return
        case .denied:
            throw ASRError.permissionDenied
        case .undetermined:
            let granted = await audioSession.requestRecordPermission()
            if !granted {
                throw ASRError.permissionDenied
            }
        @unknown default:
            throw ASRError.permissionDenied
        }
    }
    
    /// Transcribe audio file using the selected provider
    func transcribe(audioURL: URL, provider: ASRProvider, apiKey: String) async throws -> String {
        let audioData = try Data(contentsOf: audioURL)
        
        switch provider {
        case .whisper:
            return try await transcribeWithWhisper(audioData: audioData, apiKey: apiKey)
        case .google:
            return try await transcribeWithGoogle(audioData: audioData, apiKey: apiKey)
        case .azure:
            return try await transcribeWithAzure(audioData: audioData, apiKey: apiKey)
        }
    }
    
    // MARK: - Whisper Implementation
    
    private func transcribeWithWhisper(audioData: Data, apiKey: String) async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/audio/transcriptions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add model
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw ASRError.transcriptionFailed("Whisper API error")
        }
        
        let result = try JSONDecoder().decode(WhisperResponse.self, from: data)
        return result.text
    }
    
    // MARK: - Google Speech-to-Text Implementation
    
    private func transcribeWithGoogle(audioData: Data, apiKey: String) async throws -> String {
        let url = URL(string: "https://speech.googleapis.com/v1/speech:recognize?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let base64Audio = audioData.base64EncodedString()
        
        let requestBody: [String: Any] = [
            "config": [
                "encoding": "LINEAR16",
                "sampleRateHertz": 16000,
                "languageCode": "en-US",
                "enableAutomaticPunctuation": true
            ],
            "audio": [
                "content": base64Audio
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw ASRError.transcriptionFailed("Google API error")
        }
        
        let result = try JSONDecoder().decode(GoogleSpeechResponse.self, from: data)
        return result.results?.first?.alternatives?.first?.transcript ?? ""
    }
    
    // MARK: - Azure Speech Implementation
    
    private func transcribeWithAzure(audioData: Data, apiKey: String) async throws -> String {
        // Note: Requires region configuration
        let region = ASRConfiguration.shared.azureRegion.isEmpty ? "eastus" : ASRConfiguration.shared.azureRegion
        let url = URL(string: "https://\(region).stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=en-US")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.setValue("audio/wav; codec=audio/pcm; samplerate=16000", forHTTPHeaderField: "Content-Type")
        request.httpBody = audioData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw ASRError.transcriptionFailed("Azure API error")
        }
        
        let result = try JSONDecoder().decode(AzureSpeechResponse.self, from: data)
        return result.DisplayText ?? ""
    }
    
    /// Check if recording is in progress
    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }
}

// MARK: - Response Models

struct WhisperResponse: Codable {
    let text: String
}

struct GoogleSpeechResponse: Codable {
    let results: [GoogleSpeechResult]?
}

struct GoogleSpeechResult: Codable {
    let alternatives: [GoogleSpeechAlternative]?
}

struct GoogleSpeechAlternative: Codable {
    let transcript: String
    let confidence: Double?
}

struct AzureSpeechResponse: Codable {
    let RecognitionStatus: String
    let DisplayText: String?
}

// MARK: - Error Types

enum ASRError: LocalizedError {
    case permissionDenied
    case recordingFailed
    case transcriptionFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Microphone permission is required for voice input"
        case .recordingFailed:
            return "Failed to record audio"
        case .transcriptionFailed(let message):
            return "Transcription failed: \(message)"
        }
    }
}

// MARK: - Configuration

class ASRConfiguration: ObservableObject {
    static let shared = ASRConfiguration()
    
    @AppStorage("asr.provider") var provider: ASRProvider = .whisper
    @AppStorage("asr.googleAPIKey") var googleAPIKey: String = ""
    @AppStorage("asr.azureAPIKey") var azureAPIKey: String = ""
    @AppStorage("asr.azureRegion") var azureRegion: String = "eastus"
    @AppStorage("asr.isEnabled") var isEnabled: Bool = false
    
    private init() {}
}
