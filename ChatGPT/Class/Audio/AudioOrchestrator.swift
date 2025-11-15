//
//  AudioOrchestrator.swift
//  ChatGPT
//
//  Audio orchestrator for managing state transitions between ASR and TTS
//

import Foundation
import Combine

/// Represents the current state of the audio system
@available(iOS 13.0, macOS 10.15, *)
public enum AudioState: String, CaseIterable {
    case idle           // No active audio processing
    case listening      // Microphone is actively listening
    case processing     // Processing speech or preparing response
    case playing        // Audio response is being played
}

/// Orchestrator for managing audio state transitions between ASR and TTS
/// Ensures microphone listening and audio playback don't interfere with each other
@available(iOS 13.0, macOS 10.15, *)
public actor AudioOrchestrator {
    
    // MARK: - Properties
    
    /// Current state of the audio system
    private(set) var currentState: AudioState = .idle
    
    /// Publisher for state changes
    private let stateSubject = PassthroughSubject<AudioState, Never>()
    
    /// State change publisher for external observers
    public nonisolated var statePublisher: AnyPublisher<AudioState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    /// Callbacks for state transitions
    private var stateChangeCallbacks: [AudioState: [() async -> Void]] = [:]
    
    /// Flag to track if orchestrator is currently transitioning
    private var isTransitioning: Bool = false
    
    /// Cancellables for managing subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init() {
        // Initialize with idle state
        currentState = .idle
    }
    
    // MARK: - Public State Transition Methods
    
    /// Request transition to listening state
    /// - Returns: true if transition was successful, false otherwise
    @discardableResult
    public func requestListening() async -> Bool {
        guard await canTransitionTo(.listening) else {
            return false
        }
        await transitionTo(.listening)
        return true
    }
    
    /// Request transition to processing state
    /// - Returns: true if transition was successful, false otherwise
    @discardableResult
    public func requestProcessing() async -> Bool {
        guard await canTransitionTo(.processing) else {
            return false
        }
        await transitionTo(.processing)
        return true
    }
    
    /// Request transition to playing state
    /// - Returns: true if transition was successful, false otherwise
    @discardableResult
    public func requestPlaying() async -> Bool {
        guard await canTransitionTo(.playing) else {
            return false
        }
        await transitionTo(.playing)
        return true
    }
    
    /// Request transition to idle state
    /// - Returns: true if transition was successful, false otherwise
    @discardableResult
    public func requestIdle() async -> Bool {
        guard await canTransitionTo(.idle) else {
            return false
        }
        await transitionTo(.idle)
        return true
    }
    
    /// Force transition to idle state (emergency stop)
    public func forceIdle() async {
        isTransitioning = false
        await transitionTo(.idle)
    }
    
    // MARK: - State Query Methods
    
    /// Check if currently in listening state
    public func isListening() -> Bool {
        return currentState == .listening
    }
    
    /// Check if currently in playing state
    public func isPlaying() -> Bool {
        return currentState == .playing
    }
    
    /// Check if currently in idle state
    public func isIdle() -> Bool {
        return currentState == .idle
    }
    
    /// Check if currently in processing state
    public func isProcessing() -> Bool {
        return currentState == .processing
    }
    
    /// Get current state
    public func getState() -> AudioState {
        return currentState
    }
    
    // MARK: - Callback Registration
    
    /// Register a callback to be executed when entering a specific state
    /// - Parameters:
    ///   - state: The state to monitor
    ///   - callback: The async closure to execute when entering the state
    public func onStateEnter(_ state: AudioState, perform callback: @escaping () async -> Void) {
        if stateChangeCallbacks[state] == nil {
            stateChangeCallbacks[state] = []
        }
        stateChangeCallbacks[state]?.append(callback)
    }
    
    // MARK: - Private Helper Methods
    
    /// Check if transition to a given state is valid
    private func canTransitionTo(_ newState: AudioState) -> Bool {
        // Prevent transitions while already transitioning
        guard !isTransitioning else {
            return false
        }
        
        // Define valid state transitions
        switch currentState {
        case .idle:
            return newState == .listening || newState == .idle
        case .listening:
            return newState == .processing || newState == .idle
        case .processing:
            return newState == .playing || newState == .listening || newState == .idle
        case .playing:
            return newState == .idle || newState == .listening
        }
    }
    
    /// Perform state transition
    private func transitionTo(_ newState: AudioState) async {
        // Set transitioning flag
        isTransitioning = true
        
        let oldState = currentState
        currentState = newState
        
        // Publish state change on main thread
        await MainActor.run {
            stateSubject.send(newState)
        }
        
        // Execute registered callbacks for this state
        if let callbacks = stateChangeCallbacks[newState] {
            for callback in callbacks {
                await callback()
            }
        }
        
        // Clear transitioning flag
        isTransitioning = false
        
        // Log state transition for debugging
        #if DEBUG
        print("[AudioOrchestrator] State transition: \(oldState.rawValue) -> \(newState.rawValue)")
        #endif
    }
    
    // MARK: - Lifecycle Management
    
    /// Clean up resources and reset to idle state
    public func cleanup() async {
        isTransitioning = false
        stateChangeCallbacks.removeAll()
        await transitionTo(.idle)
    }
}
