//
//  AudioManager.swift
//  ChatGPT
//
//  Integrated audio manager using orchestrator to coordinate ASR and TTS
//

import Foundation
import Combine

/// Integrated manager for coordinating ASR and TTS with the orchestrator
@available(iOS 13.0, macOS 10.15, *)
public class AudioManager: NSObject {
    
    // MARK: - Properties
    
    /// Shared singleton instance
    public static let shared = AudioManager()
    
    /// Audio orchestrator for state management
    private let orchestrator = AudioOrchestrator()
    
    /// ASR service for speech recognition
    private let asrService: ASRService
    
    /// TTS service for speech synthesis
    private let ttsService: TTSService
    
    /// Publisher for recognized text
    private let recognizedTextSubject = PassthroughSubject<(text: String, isFinal: Bool), Never>()
    
    /// Recognized text publisher
    public var recognizedTextPublisher: AnyPublisher<(text: String, isFinal: Bool), Never> {
        recognizedTextSubject.eraseToAnyPublisher()
    }
    
    /// Publisher for audio state changes
    public var statePublisher: AnyPublisher<AudioState, Never> {
        orchestrator.statePublisher
    }
    
    /// Cancellables for managing subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    private override init() {
        self.asrService = ASRService()
        self.ttsService = TTSService()
        super.init()
        
        // Set up delegates
        asrService.delegate = self
        ttsService.delegate = self
        
        // Register callbacks with orchestrator
        setupOrchestratorCallbacks()
    }
    
    // MARK: - Setup
    
    private func setupOrchestratorCallbacks() {
        Task {
            // Callback for entering listening state
            await orchestrator.onStateEnter(.listening) { [weak self] in
                guard let self = self else { return }
                do {
                    try self.asrService.startListening()
                } catch {
                    print("[AudioManager] Error starting ASR: \(error)")
                    await self.orchestrator.requestIdle()
                }
            }
            
            // Callback for entering idle state
            await orchestrator.onStateEnter(.idle) { [weak self] in
                guard let self = self else { return }
                if self.asrService.isListening {
                    self.asrService.stopListening()
                }
                if self.ttsService.isSpeaking {
                    self.ttsService.stopSpeaking()
                }
            }
        }
    }
    
    // MARK: - Authorization
    
    /// Request authorization for speech recognition and microphone access
    /// - Parameter completion: Called with authorization status
    public func requestAuthorization(completion: @escaping (Bool) -> Void) {
        asrService.requestAuthorization(completion: completion)
    }
    
    /// Check if authorized to use speech recognition
    public var isAuthorized: Bool {
        return asrService.isAuthorized
    }
    
    // MARK: - Public Methods
    
    /// Start listening for speech
    /// Will automatically stop any ongoing TTS playback
    public func startListening() async throws {
        // Request listening state from orchestrator
        let success = await orchestrator.requestListening()
        
        if !success {
            throw NSError(
                domain: "AudioManager",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Unable to transition to listening state"]
            )
        }
    }
    
    /// Stop listening for speech
    public func stopListening() async {
        await orchestrator.requestIdle()
    }
    
    /// Speak the given text
    /// Will automatically stop any ongoing speech recognition
    /// - Parameter text: Text to speak
    public func speak(_ text: String) async throws {
        // Request playing state from orchestrator
        let success = await orchestrator.requestPlaying()
        
        if !success {
            throw NSError(
                domain: "AudioManager",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Unable to transition to playing state"]
            )
        }
        
        // Start speaking
        try ttsService.speak(text)
    }
    
    /// Stop speaking
    public func stopSpeaking() async {
        ttsService.stopSpeaking()
        await orchestrator.requestIdle()
    }
    
    /// Get current audio state
    public func getCurrentState() async -> AudioState {
        return await orchestrator.getState()
    }
    
    /// Check if currently listening
    public func isListening() async -> Bool {
        return await orchestrator.isListening()
    }
    
    /// Check if currently playing
    public func isPlaying() async -> Bool {
        return await orchestrator.isPlaying()
    }
    
    /// Force idle state (emergency stop)
    public func forceIdle() async {
        await orchestrator.forceIdle()
    }
    
    // MARK: - Configuration
    
    /// Configure TTS voice
    /// - Parameter languageCode: Language code (e.g., "en-US")
    public func configureTTSVoice(languageCode: String) {
        ttsService.setVoice(languageCode: languageCode)
    }
    
    /// Configure TTS speech rate
    /// - Parameter rate: Speech rate (0.0 - 1.0)
    public func configureTTSRate(_ rate: Float) {
        ttsService.rate = rate
    }
    
    /// Configure TTS pitch
    /// - Parameter pitch: Pitch multiplier (0.5 - 2.0)
    public func configureTTSPitch(_ pitch: Float) {
        ttsService.pitchMultiplier = pitch
    }
    
    /// Configure TTS volume
    /// - Parameter volume: Volume (0.0 - 1.0)
    public func configureTTSVolume(_ volume: Float) {
        ttsService.volume = volume
    }
}

// MARK: - ASRServiceDelegate

@available(iOS 13.0, macOS 10.15, *)
extension AudioManager: ASRServiceDelegate {
    
    public func asrService(_ service: ASRService, didRecognize text: String, isFinal: Bool) {
        recognizedTextSubject.send((text, isFinal))
        
        if isFinal {
            Task {
                await orchestrator.requestIdle()
            }
        }
    }
    
    public func asrService(_ service: ASRService, didEncounterError error: Error) {
        print("[AudioManager] ASR Error: \(error)")
        Task {
            await orchestrator.requestIdle()
        }
    }
    
    public func asrServiceDidStartListening(_ service: ASRService) {
        print("[AudioManager] Started listening")
    }
    
    public func asrServiceDidStopListening(_ service: ASRService) {
        print("[AudioManager] Stopped listening")
    }
}

// MARK: - TTSServiceDelegate

@available(iOS 13.0, macOS 10.15, *)
extension AudioManager: TTSServiceDelegate {
    
    public func ttsServiceDidStartSpeaking(_ service: TTSService) {
        print("[AudioManager] Started speaking")
    }
    
    public func ttsServiceDidFinishSpeaking(_ service: TTSService) {
        print("[AudioManager] Finished speaking")
        Task {
            // Automatically transition back to idle after speaking
            await orchestrator.requestIdle()
        }
    }
    
    public func ttsServiceDidPauseSpeaking(_ service: TTSService) {
        print("[AudioManager] Paused speaking")
    }
    
    public func ttsServiceDidCancelSpeaking(_ service: TTSService) {
        print("[AudioManager] Cancelled speaking")
        Task {
            await orchestrator.requestIdle()
        }
    }
}
