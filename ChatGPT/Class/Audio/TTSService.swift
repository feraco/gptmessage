//
//  TTSService.swift
//  ChatGPT
//
//  Text-to-Speech service using AVSpeechSynthesizer
//

import Foundation
import AVFoundation

/// Errors that can occur during TTS operations
public enum TTSError: Error {
    case noText
    case alreadySpeaking
    case synthesizerUnavailable
}

/// Protocol for TTS service delegates
public protocol TTSServiceDelegate: AnyObject {
    /// Called when speech starts
    func ttsServiceDidStartSpeaking(_ service: TTSService)
    
    /// Called when speech finishes
    func ttsServiceDidFinishSpeaking(_ service: TTSService)
    
    /// Called when speech is paused
    func ttsServiceDidPauseSpeaking(_ service: TTSService)
    
    /// Called when speech is cancelled
    func ttsServiceDidCancelSpeaking(_ service: TTSService)
}

/// Service for managing text-to-speech synthesis
@available(iOS 13.0, macOS 10.15, *)
public class TTSService: NSObject {
    
    // MARK: - Properties
    
    /// Delegate for TTS events
    public weak var delegate: TTSServiceDelegate?
    
    /// Speech synthesizer
    private let synthesizer = AVSpeechSynthesizer()
    
    /// Flag indicating if currently speaking
    private(set) var isSpeaking: Bool = false
    
    /// Voice to use for synthesis (default: system default)
    public var voice: AVSpeechSynthesisVoice?
    
    /// Speech rate (0.0 - 1.0, default: 0.5)
    public var rate: Float = AVSpeechUtteranceDefaultSpeechRate
    
    /// Pitch multiplier (0.5 - 2.0, default: 1.0)
    public var pitchMultiplier: Float = 1.0
    
    /// Volume (0.0 - 1.0, default: 1.0)
    public var volume: Float = 1.0
    
    // MARK: - Initialization
    
    public override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    // MARK: - Speech Control
    
    /// Speak the given text
    /// - Parameters:
    ///   - text: Text to speak
    ///   - completion: Optional completion handler called when speech finishes
    /// - Throws: TTSError if unable to start speaking
    public func speak(_ text: String, completion: (() -> Void)? = nil) throws {
        // Check if already speaking
        guard !isSpeaking else {
            throw TTSError.alreadySpeaking
        }
        
        // Check if text is not empty
        guard !text.isEmpty else {
            throw TTSError.noText
        }
        
        // Configure audio session for playback
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .spokenAudio, options: .duckOthers)
        try audioSession.setActive(true)
        
        // Create utterance
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        utterance.rate = rate
        utterance.pitchMultiplier = pitchMultiplier
        utterance.volume = volume
        
        // Speak
        synthesizer.speak(utterance)
        isSpeaking = true
    }
    
    /// Stop speaking immediately
    public func stopSpeaking() {
        guard isSpeaking else { return }
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    /// Pause speaking
    public func pauseSpeaking() {
        guard isSpeaking else { return }
        synthesizer.pauseSpeaking(at: .immediate)
    }
    
    /// Resume speaking if paused
    public func resumeSpeaking() {
        synthesizer.continueSpeaking()
    }
    
    /// Check if speech is paused
    public var isPaused: Bool {
        return synthesizer.isPaused
    }
    
    // MARK: - Voice Selection
    
    /// Get all available voices
    public static var availableVoices: [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices()
    }
    
    /// Get voices for a specific language
    /// - Parameter languageCode: Language code (e.g., "en-US")
    /// - Returns: Array of voices for the language
    public static func voices(for languageCode: String) -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix(languageCode) }
    }
    
    /// Set voice by language code
    /// - Parameter languageCode: Language code (e.g., "en-US")
    public func setVoice(languageCode: String) {
        voice = AVSpeechSynthesisVoice(language: languageCode)
    }
    
    // MARK: - Cleanup
    
    deinit {
        if isSpeaking {
            stopSpeaking()
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate

@available(iOS 13.0, macOS 10.15, *)
extension TTSService: AVSpeechSynthesizerDelegate {
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        delegate?.ttsServiceDidStartSpeaking(self)
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
        
        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("[TTSService] Error deactivating audio session: \(error)")
        }
        
        delegate?.ttsServiceDidFinishSpeaking(self)
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        delegate?.ttsServiceDidPauseSpeaking(self)
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
        
        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("[TTSService] Error deactivating audio session: \(error)")
        }
        
        delegate?.ttsServiceDidCancelSpeaking(self)
    }
}
