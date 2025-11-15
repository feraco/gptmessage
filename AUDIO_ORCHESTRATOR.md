# Audio Orchestrator Documentation

## Overview

The Audio Orchestrator is a comprehensive system for managing state transitions between Automatic Speech Recognition (ASR) and Text-to-Speech (TTS) operations. It ensures that microphone listening and audio playback don't interfere with each other, providing smooth conversation flow in voice-enabled applications.

## Architecture

The system consists of four main components:

### 1. AudioOrchestrator
The core state machine that manages transitions between different audio states.

**States:**
- `idle`: No active audio processing (conserves resources)
- `listening`: Microphone is actively listening for speech input
- `processing`: Processing recognized speech or preparing response
- `playing`: Audio response is being played through speakers

**Key Features:**
- Thread-safe state management using Swift actors
- Lock mechanism to prevent concurrent state transitions
- Callback registration for state enter events
- Publisher for reactive state observation

### 2. ASRService
Wrapper around iOS Speech framework for speech recognition.

**Features:**
- Real-time speech recognition with partial results
- Microphone permission management
- Automatic audio session configuration
- Delegate-based event notification

### 3. TTSService
Wrapper around AVSpeechSynthesizer for text-to-speech.

**Features:**
- Configurable voice, rate, pitch, and volume
- Audio session management
- Delegate-based event notification
- Playback control (play, pause, stop, resume)

### 4. AudioManager
Integrated manager that coordinates ASR and TTS using the orchestrator.

**Features:**
- Singleton pattern for app-wide access
- Automatic state coordination
- Combine publishers for reactive programming
- Simple API for common operations

## Installation

The audio components are located in `ChatGPT/Class/Audio/`:
- `AudioOrchestrator.swift`
- `ASRService.swift`
- `TTSService.swift`
- `AudioManager.swift`

Ensure your app has the following permissions in `Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access for speech recognition</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>We need speech recognition for voice commands</string>
```

## Usage

### Basic Usage with AudioManager

The simplest way to use the system is through the `AudioManager` singleton:

```swift
import ChatGPT

// Request authorization first
AudioManager.shared.requestAuthorization { authorized in
    if authorized {
        print("Authorized to use speech recognition")
    }
}

// Start listening for speech
Task {
    do {
        try await AudioManager.shared.startListening()
    } catch {
        print("Error starting listening: \(error)")
    }
}

// Subscribe to recognized text
AudioManager.shared.recognizedTextPublisher
    .sink { text, isFinal in
        print("Recognized: \(text), Final: \(isFinal)")
    }
    .store(in: &cancellables)

// Speak a response
Task {
    do {
        try await AudioManager.shared.speak("Hello, how can I help you?")
    } catch {
        print("Error speaking: \(error)")
    }
}

// Stop listening
Task {
    await AudioManager.shared.stopListening()
}
```

### Advanced Usage with AudioOrchestrator

For more control, use the orchestrator directly:

```swift
let orchestrator = AudioOrchestrator()

// Register callbacks for state changes
await orchestrator.onStateEnter(.listening) {
    print("Started listening")
    // Start ASR here
}

await orchestrator.onStateEnter(.playing) {
    print("Started playing")
    // Start TTS here
}

await orchestrator.onStateEnter(.idle) {
    print("Returned to idle")
    // Clean up resources
}

// Request state transitions
let success = await orchestrator.requestListening()
if success {
    print("Now listening")
}

// Subscribe to state changes
orchestrator.statePublisher
    .sink { state in
        print("State changed to: \(state)")
    }
    .store(in: &cancellables)
```

### Using ASRService Directly

```swift
let asrService = ASRService()
asrService.delegate = self

// Request authorization
asrService.requestAuthorization { authorized in
    if authorized {
        // Start listening
        do {
            try asrService.startListening()
        } catch {
            print("Error: \(error)")
        }
    }
}

// Implement delegate methods
extension MyClass: ASRServiceDelegate {
    func asrService(_ service: ASRService, didRecognize text: String, isFinal: Bool) {
        print("Recognized: \(text)")
    }
    
    func asrService(_ service: ASRService, didEncounterError error: Error) {
        print("Error: \(error)")
    }
    
    func asrServiceDidStartListening(_ service: ASRService) {
        print("Started listening")
    }
    
    func asrServiceDidStopListening(_ service: ASRService) {
        print("Stopped listening")
    }
}
```

### Using TTSService Directly

```swift
let ttsService = TTSService()
ttsService.delegate = self

// Configure voice
ttsService.setVoice(languageCode: "en-US")
ttsService.rate = 0.5
ttsService.pitchMultiplier = 1.0
ttsService.volume = 1.0

// Speak
do {
    try ttsService.speak("Hello, world!")
} catch {
    print("Error: \(error)")
}

// Implement delegate methods
extension MyClass: TTSServiceDelegate {
    func ttsServiceDidStartSpeaking(_ service: TTSService) {
        print("Started speaking")
    }
    
    func ttsServiceDidFinishSpeaking(_ service: TTSService) {
        print("Finished speaking")
    }
    
    func ttsServiceDidPauseSpeaking(_ service: TTSService) {
        print("Paused speaking")
    }
    
    func ttsServiceDidCancelSpeaking(_ service: TTSService) {
        print("Cancelled speaking")
    }
}
```

## State Transitions

The orchestrator enforces the following valid state transitions:

```
idle → listening → processing → playing → idle
  ↑        ↓          ↓                    ↑
  └────────┴──────────┘────────────────────┘
```

**Valid Transitions:**
- `idle → listening`: Start listening for speech
- `listening → processing`: Begin processing recognized speech
- `listening → idle`: Cancel listening
- `processing → playing`: Start playing audio response
- `processing → listening`: Continue conversation without response
- `processing → idle`: End conversation
- `playing → idle`: Audio playback completed
- `playing → listening`: Ready for next input after playback

**Invalid Transitions:**
- `idle → playing`: Cannot play without processing first
- `listening → playing`: Must process before playing

## Real-Time Processing

The orchestrator is designed for real-time processing with minimal latency:

1. **Actor-based Concurrency**: Uses Swift actors to ensure thread-safe state management without blocking
2. **Async/Await**: Leverages modern Swift concurrency for responsive operations
3. **Non-blocking State Queries**: State queries are synchronous within the actor but don't block callers
4. **Immediate Transitions**: State transitions happen immediately when valid

## Resource Conservation

The `idle` state is designed to conserve resources:

- Audio sessions are deactivated
- Microphone is released
- Speech synthesizer is stopped
- No active audio processing

The orchestrator automatically transitions to `idle` when:
- Speech recognition completes
- TTS playback finishes
- An error occurs
- User explicitly requests idle state

## Error Handling

All services provide comprehensive error handling:

**ASRError:**
- `notAuthorized`: User hasn't granted microphone/speech recognition permission
- `audioEngineFailure`: Audio engine failed to start
- `recognitionUnavailable`: Speech recognition is unavailable
- `alreadyListening`: Already in listening state
- `notListening`: Not currently listening

**TTSError:**
- `noText`: No text provided to speak
- `alreadySpeaking`: Already speaking
- `synthesizerUnavailable`: Speech synthesizer unavailable

## Integration with ChatGPT Pipeline

To integrate with the existing ChatGPT conversation flow:

```swift
class ConversationManager {
    let audioManager = AudioManager.shared
    var cancellables = Set<AnyCancellable>()
    
    func setupAudioIntegration() {
        // Listen for recognized text
        audioManager.recognizedTextPublisher
            .sink { [weak self] text, isFinal in
                if isFinal {
                    self?.processUserInput(text)
                }
            }
            .store(in: &cancellables)
        
        // Monitor state changes
        audioManager.statePublisher
            .sink { state in
                print("Audio state: \(state)")
                // Update UI based on state
            }
            .store(in: &cancellables)
    }
    
    func processUserInput(_ text: String) {
        Task {
            // Send to ChatGPT API
            let response = await sendToChatGPT(text)
            
            // Speak the response
            try? await audioManager.speak(response)
        }
    }
    
    func startVoiceConversation() {
        Task {
            // Request authorization
            audioManager.requestAuthorization { [weak self] authorized in
                guard authorized else { return }
                
                // Start listening
                Task {
                    try? await self?.audioManager.startListening()
                }
            }
        }
    }
}
```

## Testing

The orchestrator includes comprehensive unit tests in `ChatGPTTests/AudioOrchestratorTests.swift`:

- Initial state tests
- State transition tests
- Invalid transition tests
- Callback execution tests
- Complete conversation flow tests

Run tests using:
```bash
xcodebuild test -scheme ChatGPT -destination 'platform=iOS Simulator,name=iPhone 14'
```

## Performance Considerations

1. **Latency**: State transitions are designed to be instantaneous (< 1ms)
2. **Memory**: Orchestrator uses minimal memory (~1KB for state and callbacks)
3. **Thread Safety**: All state access is thread-safe via Swift actors
4. **Real-time**: Suitable for real-time conversation applications

## Best Practices

1. **Always request authorization** before attempting to use ASR
2. **Handle errors gracefully** and provide user feedback
3. **Use AudioManager** for most use cases rather than individual services
4. **Subscribe to state changes** to update UI appropriately
5. **Test on real devices** as speech recognition may not work in simulators
6. **Respect privacy** by clearly communicating when listening is active

## Troubleshooting

**Speech recognition not working:**
- Check microphone permissions in Settings
- Verify device has internet connection (required for iOS < 13)
- Ensure locale is supported by SFSpeechRecognizer

**TTS not working:**
- Check audio session configuration
- Verify no other audio is playing
- Ensure volume is not muted

**State transitions failing:**
- Check current state before requesting transition
- Review state transition diagram for valid transitions
- Use `forceIdle()` to reset if stuck in invalid state

## Future Enhancements

Potential improvements for future versions:

1. Offline speech recognition support
2. Custom wake word detection
3. Voice activity detection (VAD)
4. Multi-language support
5. Speech emotion detection
6. Background listening support
7. Noise cancellation
8. Custom TTS voice training

## License

This component is part of the GPTMessage project and follows the same license.

## Support

For issues or questions, please file an issue on the GitHub repository.
