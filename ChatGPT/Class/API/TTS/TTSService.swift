//
//  TTSService.swift
//  ChatGPT
//
//  Text-to-Speech Service
//  Supports multiple TTS providers and native system TTS
//

import Foundation
import AVFoundation

/// TTS Provider types
enum TTSProvider: String, CaseIterable, Codable {
    case system = "System TTS"
    case openAI = "OpenAI TTS"
    case azure = "Microsoft Azure TTS"
    case google = "Google Cloud TTS"
    
    var requiresAPIKey: Bool {
        switch self {
        case .system:
            return false
        case .openAI, .azure, .google:
            return true
        }
    }
}

/// TTS Voice options for OpenAI
enum OpenAIVoice: String, CaseIterable, Codable {
    case alloy, echo, fable, onyx, nova, shimmer
}

/// TTS Service for converting text to speech
class TTSService: NSObject, @unchecked Sendable {
    
    static let shared = TTSService()
    
    private var synthesizer: AVSpeechSynthesizer?
    private var audioPlayer: AVAudioPlayer?
    private let audioSession = AVAudioSession.sharedInstance()
    
    private override init() {
        super.init()
        synthesizer = AVSpeechSynthesizer()
        synthesizer?.delegate = self
    }
    
    /// Generate speech from text using the selected provider
    func speak(text: String, provider: TTSProvider, apiKey: String = "") async throws -> URL? {
        switch provider {
        case .system:
            return try await speakWithSystemTTS(text: text)
        case .openAI:
            return try await speakWithOpenAI(text: text, apiKey: apiKey)
        case .azure:
            return try await speakWithAzure(text: text, apiKey: apiKey)
        case .google:
            return try await speakWithGoogle(text: text, apiKey: apiKey)
        }
    }
    
    /// Stop any ongoing speech
    func stopSpeaking() {
        synthesizer?.stopSpeaking(at: .immediate)
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    /// Check if currently speaking
    var isSpeaking: Bool {
        return synthesizer?.isSpeaking ?? false || audioPlayer?.isPlaying ?? false
    }
    
    // MARK: - System TTS Implementation
    
    private func speakWithSystemTTS(text: String) async throws -> URL? {
        return try await withCheckedThrowingContinuation { continuation in
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: TTSConfiguration.shared.language)
            utterance.rate = Float(TTSConfiguration.shared.speechRate)
            utterance.pitchMultiplier = Float(TTSConfiguration.shared.pitch)
            utterance.volume = Float(TTSConfiguration.shared.volume)
            
            // Write to file
            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("tts_\(UUID().uuidString).caf")
            
            do {
                try audioSession.setCategory(.playback, mode: .default)
                try audioSession.setActive(true)
                
                synthesizer?.write(utterance) { [weak self] buffer in
                    guard let buffer = buffer else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    // Save audio buffer to file
                    do {
                        let audioFile = try AVAudioFile(
                            forWriting: outputURL,
                            settings: buffer.format.settings
                        )
                        try audioFile.write(from: buffer)
                        continuation.resume(returning: outputURL)
                    } catch {
                        continuation.resume(throwing: TTSError.generationFailed("Failed to write audio file"))
                    }
                }
            } catch {
                continuation.resume(throwing: TTSError.generationFailed("Failed to initialize audio session"))
            }
        }
    }
    
    // MARK: - OpenAI TTS Implementation
    
    private func speakWithOpenAI(text: String, apiKey: String) async throws -> URL? {
        let url = URL(string: "https://api.openai.com/v1/audio/speech")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "tts-1",
            "input": text,
            "voice": TTSConfiguration.shared.openAIVoice.rawValue,
            "speed": TTSConfiguration.shared.speechRate
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw TTSError.generationFailed("OpenAI TTS API error")
        }
        
        // Save audio data to file
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("tts_\(UUID().uuidString).mp3")
        try data.write(to: outputURL)
        
        // Play audio
        try await playAudio(url: outputURL)
        
        return outputURL
    }
    
    // MARK: - Azure TTS Implementation
    
    private func speakWithAzure(text: String, apiKey: String) async throws -> URL? {
        let region = TTSConfiguration.shared.azureRegion.isEmpty ? "eastus" : TTSConfiguration.shared.azureRegion
        let url = URL(string: "https://\(region).tts.speech.microsoft.com/cognitiveservices/v1")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.setValue("application/ssml+xml", forHTTPHeaderField: "Content-Type")
        request.setValue("riff-24khz-16bit-mono-pcm", forHTTPHeaderField: "X-Microsoft-OutputFormat")
        
        let ssml = """
        <speak version='1.0' xml:lang='en-US'>
            <voice xml:lang='en-US' name='en-US-JennyNeural'>
                \(text)
            </voice>
        </speak>
        """
        
        request.httpBody = ssml.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw TTSError.generationFailed("Azure TTS API error")
        }
        
        // Save audio data to file
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("tts_\(UUID().uuidString).wav")
        try data.write(to: outputURL)
        
        // Play audio
        try await playAudio(url: outputURL)
        
        return outputURL
    }
    
    // MARK: - Google Cloud TTS Implementation
    
    private func speakWithGoogle(text: String, apiKey: String) async throws -> URL? {
        let url = URL(string: "https://texttospeech.googleapis.com/v1/text:synthesize?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "input": ["text": text],
            "voice": [
                "languageCode": "en-US",
                "name": "en-US-Neural2-C"
            ],
            "audioConfig": [
                "audioEncoding": "MP3",
                "speakingRate": TTSConfiguration.shared.speechRate,
                "pitch": TTSConfiguration.shared.pitch
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw TTSError.generationFailed("Google TTS API error")
        }
        
        let result = try JSONDecoder().decode(GoogleTTSResponse.self, from: data)
        guard let audioData = Data(base64Encoded: result.audioContent) else {
            throw TTSError.generationFailed("Failed to decode audio data")
        }
        
        // Save audio data to file
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("tts_\(UUID().uuidString).mp3")
        try audioData.write(to: outputURL)
        
        // Play audio
        try await playAudio(url: outputURL)
        
        return outputURL
    }
    
    // MARK: - Audio Playback
    
    private func playAudio(url: URL) async throws {
        try audioSession.setCategory(.playback, mode: .default)
        try audioSession.setActive(true)
        
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
        
        // Wait for playback to complete
        while audioPlayer?.isPlaying == true {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension TTSService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("Speech finished")
    }
}

// MARK: - Response Models

struct GoogleTTSResponse: Codable {
    let audioContent: String
}

// MARK: - Error Types

enum TTSError: LocalizedError {
    case generationFailed(String)
    case playbackFailed
    
    var errorDescription: String? {
        switch self {
        case .generationFailed(let message):
            return "Speech generation failed: \(message)"
        case .playbackFailed:
            return "Failed to play audio"
        }
    }
}

// MARK: - Configuration

class TTSConfiguration: ObservableObject {
    static let shared = TTSConfiguration()
    
    @Published var provider: TTSProvider = .system
    @Published var isEnabled: Bool = false
    @Published var autoPlay: Bool = true
    @Published var speechRate: Double = 0.5
    @Published var pitch: Double = 1.0
    @Published var volume: Double = 1.0
    @Published var language: String = "en-US"
    @Published var openAIVoice: OpenAIVoice = .alloy
    @Published var azureRegion: String = "eastus"
    
    private init() {}
}
