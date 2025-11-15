//
//  AvatarAnimationService.swift
//  ChatGPT
//
//  Avatar Animation Service for humanoid robot facial expressions
//

import Foundation
import SwiftUI

/// Emotion types for avatar expressions
enum AvatarEmotion: String, CaseIterable, Codable {
    case neutral
    case happy
    case sad
    case surprised
    case thinking
    case speaking
    case listening
    
    var description: String {
        switch self {
        case .neutral: return "Neutral expression"
        case .happy: return "Happy/Smiling"
        case .sad: return "Sad/Concerned"
        case .surprised: return "Surprised/Excited"
        case .thinking: return "Thinking/Processing"
        case .speaking: return "Speaking/Talking"
        case .listening: return "Listening/Attentive"
        }
    }
}

/// Eye state for avatar
enum EyeState: String, CaseIterable {
    case open
    case closed
    case blinking
    case halfOpen
}

/// Mouth state for avatar
enum MouthState: String, CaseIterable {
    case closed
    case open
    case smile
    case talking
    case frown
}

/// Avatar Animation State
struct AvatarState: Equatable {
    var emotion: AvatarEmotion
    var eyeState: EyeState
    var mouthState: MouthState
    var isAnimating: Bool
    var currentText: String
    
    static var idle: AvatarState {
        AvatarState(
            emotion: .neutral,
            eyeState: .open,
            mouthState: .closed,
            isAnimating: false,
            currentText: ""
        )
    }
}

/// Avatar Animation Service
class AvatarAnimationService: ObservableObject {
    
    static let shared = AvatarAnimationService()
    
    @Published var currentState: AvatarState = .idle
    @Published var isActive: Bool = false
    
    private var animationTimer: Timer?
    private var blinkTimer: Timer?
    
    private init() {
        startBlinkingAnimation()
    }
    
    deinit {
        stopAllAnimations()
    }
    
    // MARK: - Animation Control
    
    /// Start automatic blinking animation
    private func startBlinkingAnimation() {
        blinkTimer?.invalidate()
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.performBlink()
        }
    }
    
    /// Stop all animations
    func stopAllAnimations() {
        animationTimer?.invalidate()
        blinkTimer?.invalidate()
        animationTimer = nil
        blinkTimer = nil
    }
    
    /// Perform a blink animation
    private func performBlink() {
        guard currentState.eyeState == .open else { return }
        
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.1)) {
                self.currentState.eyeState = .blinking
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeInOut(duration: 0.1)) {
                self.currentState.eyeState = .open
            }
        }
    }
    
    // MARK: - Emotion Control
    
    /// Set avatar emotion
    func setEmotion(_ emotion: AvatarEmotion, animated: Bool = true) {
        if animated {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentState.emotion = emotion
                updateStateForEmotion(emotion)
            }
        } else {
            currentState.emotion = emotion
            updateStateForEmotion(emotion)
        }
    }
    
    private func updateStateForEmotion(_ emotion: AvatarEmotion) {
        switch emotion {
        case .neutral:
            currentState.eyeState = .open
            currentState.mouthState = .closed
        case .happy:
            currentState.eyeState = .open
            currentState.mouthState = .smile
        case .sad:
            currentState.eyeState = .halfOpen
            currentState.mouthState = .frown
        case .surprised:
            currentState.eyeState = .open
            currentState.mouthState = .open
        case .thinking:
            currentState.eyeState = .halfOpen
            currentState.mouthState = .closed
        case .speaking:
            currentState.eyeState = .open
            currentState.mouthState = .talking
        case .listening:
            currentState.eyeState = .open
            currentState.mouthState = .closed
        }
    }
    
    // MARK: - Speaking Animation
    
    /// Start speaking animation synchronized with text
    func startSpeakingAnimation(text: String) {
        currentState.currentText = text
        currentState.isAnimating = true
        setEmotion(.speaking)
        
        // Animate mouth movement
        animationTimer?.invalidate()
        var isOpen = false
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.15)) {
                    self.currentState.mouthState = isOpen ? .talking : .open
                    isOpen.toggle()
                }
            }
        }
    }
    
    /// Stop speaking animation
    func stopSpeakingAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentState.isAnimating = false
            currentState.currentText = ""
            setEmotion(.neutral, animated: false)
        }
    }
    
    // MARK: - Listening Animation
    
    /// Start listening animation
    func startListeningAnimation() {
        setEmotion(.listening)
        currentState.isAnimating = true
    }
    
    /// Stop listening animation
    func stopListeningAnimation() {
        currentState.isAnimating = false
        setEmotion(.neutral)
    }
    
    // MARK: - Emotion Detection from Text
    
    /// Detect emotion from response text (simple keyword-based)
    func detectEmotionFromText(_ text: String) -> AvatarEmotion {
        let lowerText = text.lowercased()
        
        // Happy keywords
        if lowerText.contains("happy") || lowerText.contains("great") || 
           lowerText.contains("wonderful") || lowerText.contains("excellent") ||
           lowerText.contains("😊") || lowerText.contains("😄") {
            return .happy
        }
        
        // Sad keywords
        if lowerText.contains("sorry") || lowerText.contains("unfortunately") ||
           lowerText.contains("sad") || lowerText.contains("😢") {
            return .sad
        }
        
        // Surprised keywords
        if lowerText.contains("wow") || lowerText.contains("amazing") ||
           lowerText.contains("incredible") || lowerText.contains("😮") {
            return .surprised
        }
        
        // Thinking keywords
        if lowerText.contains("thinking") || lowerText.contains("let me") ||
           lowerText.contains("consider") || lowerText.contains("analyzing") {
            return .thinking
        }
        
        return .neutral
    }
}

// MARK: - Configuration

class AvatarConfiguration: ObservableObject {
    static let shared = AvatarConfiguration()
    
    @Published var isEnabled: Bool = false
    @Published var autoDetectEmotion: Bool = true
    @Published var showSubtitles: Bool = true
    @Published var animationSpeed: Double = 1.0
    @Published var eyeColor: Color = .blue
    @Published var faceColor: Color = .white
    @Published var displayMode: AvatarDisplayMode = .fullFace
    
    private init() {}
}

/// Display mode for avatar
enum AvatarDisplayMode: String, CaseIterable, Codable {
    case fullFace = "Full Face"
    case eyesOnly = "Eyes Only"
    case minimal = "Minimal"
}
