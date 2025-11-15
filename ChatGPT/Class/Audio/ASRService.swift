//
//  ASRService.swift
//  ChatGPT
//
//  Automatic Speech Recognition service using iOS Speech framework
//

import Foundation
import Speech
import AVFoundation

/// Errors that can occur during ASR operations
public enum ASRError: Error {
    case notAuthorized
    case audioEngineFailure
    case recognitionUnavailable
    case alreadyListening
    case notListening
}

/// Protocol for ASR service delegates
@available(iOS 13.0, macOS 10.15, *)
public protocol ASRServiceDelegate: AnyObject {
    /// Called when speech recognition produces a result
    func asrService(_ service: ASRService, didRecognize text: String, isFinal: Bool)
    
    /// Called when an error occurs
    func asrService(_ service: ASRService, didEncounterError error: Error)
    
    /// Called when listening starts
    func asrServiceDidStartListening(_ service: ASRService)
    
    /// Called when listening stops
    func asrServiceDidStopListening(_ service: ASRService)
}

/// Service for managing speech recognition
@available(iOS 13.0, macOS 10.15, *)
public class ASRService: NSObject {
    
    // MARK: - Properties
    
    /// Delegate for ASR events
    public weak var delegate: ASRServiceDelegate?
    
    /// Speech recognizer
    private let speechRecognizer: SFSpeechRecognizer?
    
    /// Audio engine for capturing microphone input
    private let audioEngine = AVAudioEngine()
    
    /// Current recognition request
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    /// Current recognition task
    private var recognitionTask: SFSpeechRecognitionTask?
    
    /// Flag indicating if currently listening
    private(set) var isListening: Bool = false
    
    /// Preferred locale for speech recognition (default: device locale)
    private let locale: Locale
    
    // MARK: - Initialization
    
    /// Initialize ASR service with optional locale
    /// - Parameter locale: Locale for speech recognition (default: current device locale)
    public init(locale: Locale = .current) {
        self.locale = locale
        self.speechRecognizer = SFSpeechRecognizer(locale: locale)
        super.init()
        
        // Set delegate to monitor availability
        speechRecognizer?.delegate = self
    }
    
    // MARK: - Authorization
    
    /// Request authorization for speech recognition and microphone access
    /// - Parameter completion: Called with authorization status
    public func requestAuthorization(completion: @escaping (Bool) -> Void) {
        // Request speech recognition authorization
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    // Also need microphone permission
                    AVAudioSession.sharedInstance().requestRecordPermission { granted in
                        DispatchQueue.main.async {
                            completion(granted)
                        }
                    }
                default:
                    completion(false)
                }
            }
        }
    }
    
    /// Check if speech recognition is authorized
    public var isAuthorized: Bool {
        return SFSpeechRecognizer.authorizationStatus() == .authorized
    }
    
    /// Check if speech recognition is available
    public var isAvailable: Bool {
        return speechRecognizer?.isAvailable ?? false
    }
    
    // MARK: - Listening Control
    
    /// Start listening for speech
    /// - Throws: ASRError if unable to start listening
    public func startListening() throws {
        // Check if already listening
        guard !isListening else {
            throw ASRError.alreadyListening
        }
        
        // Check authorization
        guard isAuthorized else {
            throw ASRError.notAuthorized
        }
        
        // Check availability
        guard isAvailable else {
            throw ASRError.recognitionUnavailable
        }
        
        // Cancel any existing task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw ASRError.audioEngineFailure
        }
        
        // Configure request for real-time recognition
        recognitionRequest.shouldReportPartialResults = true
        
        // Get audio input node
        let inputNode = audioEngine.inputNode
        
        // Start recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.asrService(self, didEncounterError: error)
                self.stopListeningInternal()
                return
            }
            
            if let result = result {
                let transcription = result.bestTranscription.formattedString
                let isFinal = result.isFinal
                
                self.delegate?.asrService(self, didRecognize: transcription, isFinal: isFinal)
                
                if isFinal {
                    self.stopListeningInternal()
                }
            }
        }
        
        // Configure audio tap on input node
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        try audioEngine.start()
        
        isListening = true
        delegate?.asrServiceDidStartListening(self)
    }
    
    /// Stop listening for speech
    public func stopListening() {
        stopListeningInternal()
    }
    
    /// Internal method to stop listening
    private func stopListeningInternal() {
        guard isListening else { return }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask = nil
        
        isListening = false
        delegate?.asrServiceDidStopListening(self)
    }
    
    // MARK: - Cleanup
    
    deinit {
        if isListening {
            stopListeningInternal()
        }
    }
}

// MARK: - SFSpeechRecognizerDelegate

@available(iOS 13.0, macOS 10.15, *)
extension ASRService: SFSpeechRecognizerDelegate {
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if !available && isListening {
            stopListeningInternal()
            delegate?.asrService(self, didEncounterError: ASRError.recognitionUnavailable)
        }
    }
}
