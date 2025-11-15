# Audio Orchestrator State Machine Diagram

## State Transition Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                     Audio Orchestrator States                     │
└──────────────────────────────────────────────────────────────────┘

                         ┌─────────────┐
                    ┌───▶│    IDLE     │◀───┐
                    │    └─────────────┘    │
                    │           │           │
                    │           │ request   │
                    │           │ Listening │
                    │           ▼           │
                    │    ┌─────────────┐   │
                    │    │  LISTENING  │   │
                    │    └─────────────┘   │
                    │           │           │
                    │           │ request   │
        request     │           │Processing │ request
        Idle        │           ▼           │ Idle
                    │    ┌─────────────┐   │
                    │    │ PROCESSING  │───┘
                    │    └─────────────┘
                    │           │
                    │           │ request
                    │           │ Playing
                    │           ▼
                    │    ┌─────────────┐
                    └────│   PLAYING   │
                         └─────────────┘
```

## State Descriptions

### IDLE State
- **Purpose**: Resource conservation, no active audio processing
- **Activities**: 
  - Audio sessions deactivated
  - Microphone released
  - Speech synthesizer stopped
- **Valid Transitions**: 
  - `idle → listening` (Start voice input)
  - `idle → idle` (Stay idle)

### LISTENING State
- **Purpose**: Active microphone listening for speech input
- **Activities**:
  - Microphone capturing audio
  - Real-time speech recognition active
  - Audio engine running
- **Valid Transitions**:
  - `listening → processing` (Speech recognized)
  - `listening → idle` (Cancel listening)

### PROCESSING State
- **Purpose**: Processing recognized speech and preparing response
- **Activities**:
  - Analyzing transcribed text
  - Preparing TTS response
  - No active audio I/O
- **Valid Transitions**:
  - `processing → playing` (Ready to speak response)
  - `processing → listening` (Continue conversation)
  - `processing → idle` (End conversation)

### PLAYING State
- **Purpose**: Audio response playback via TTS
- **Activities**:
  - Text-to-speech synthesis
  - Audio output active
  - Microphone disabled (prevents interference)
- **Valid Transitions**:
  - `playing → idle` (Playback complete)
  - `playing → listening` (Ready for next input)

## Transition Lock Mechanism

The orchestrator uses a transition lock to prevent concurrent state changes:

```
┌─────────────────────────────────────────────────────────────┐
│              Transition Lock Mechanism                       │
└─────────────────────────────────────────────────────────────┘

Request State Change
        │
        ▼
  ┌──────────┐
  │ Check    │──── NO ───▶ Reject Transition
  │ Lock     │            Return false
  └──────────┘
        │
       YES
        │
        ▼
  ┌──────────┐
  │ Validate │──── INVALID ───▶ Reject Transition
  │ Transition│                 Return false
  └──────────┘
        │
       VALID
        │
        ▼
  ┌──────────┐
  │ Set Lock │
  │ Flag     │
  └──────────┘
        │
        ▼
  ┌──────────┐
  │ Change   │
  │ State    │
  └──────────┘
        │
        ▼
  ┌──────────┐
  │ Execute  │
  │ Callbacks│
  └──────────┘
        │
        ▼
  ┌──────────┐
  │ Clear    │
  │ Lock     │
  └──────────┘
        │
        ▼
  Return true
```

## Concurrency Model

The orchestrator uses Swift actors for thread-safe state management:

```
┌─────────────────────────────────────────────────────────────┐
│                 Actor-Based Concurrency                      │
└─────────────────────────────────────────────────────────────┘

Thread A                    AudioOrchestrator (Actor)         Thread B
   │                               │                             │
   │─── requestListening() ───────▶│                             │
   │                               │◀─── requestPlaying() ───────│
   │                               │                             │
   │                          ┌────┴────┐                        │
   │                          │ Process │                        │
   │                          │ Request │                        │
   │                          │  One    │                        │
   │                          │   at    │                        │
   │                          │  Time   │                        │
   │                          └────┬────┘                        │
   │                               │                             │
   │◀──── success = true ──────────│                             │
   │                               │                             │
   │                               │─────── success = false ────▶│
   │                               │                             │
```

## Resource Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Resource Lifecycle                        │
└─────────────────────────────────────────────────────────────┘

IDLE State
│
│ Request Listening
▼
┌──────────────────────┐
│ Acquire Resources    │
│ - Audio Session      │
│ - Microphone Access  │
│ - Audio Engine       │
└──────────────────────┘
│
▼
LISTENING State
│
│ Request Processing
▼
┌──────────────────────┐
│ Release Input        │
│ - Stop Microphone    │
│ - Stop Audio Engine  │
└──────────────────────┘
│
▼
PROCESSING State
│
│ Request Playing
▼
┌──────────────────────┐
│ Acquire Output       │
│ - Audio Session      │
│ - Speech Synthesizer │
└──────────────────────┘
│
▼
PLAYING State
│
│ Playback Complete
▼
┌──────────────────────┐
│ Release All          │
│ - Audio Session      │
│ - All Resources      │
└──────────────────────┘
│
▼
IDLE State
```

## Complete Conversation Flow Example

```
┌─────────────────────────────────────────────────────────────┐
│            Complete Voice Conversation Flow                  │
└─────────────────────────────────────────────────────────────┘

1. User opens app
   State: IDLE
   
2. User taps microphone button
   Action: requestListening()
   State: IDLE → LISTENING
   Resources: Microphone active
   
3. User speaks: "What's the weather today?"
   State: LISTENING
   ASR: Real-time transcription
   
4. Speech recognition completes
   Action: requestProcessing()
   State: LISTENING → PROCESSING
   Resources: Microphone released
   
5. App sends to ChatGPT API
   State: PROCESSING
   Resources: None active
   
6. Response received: "It's sunny and 72 degrees"
   Action: requestPlaying()
   State: PROCESSING → PLAYING
   Resources: Speaker active
   
7. TTS speaks response
   State: PLAYING
   Resources: Audio output active
   
8. Playback completes
   Action: requestIdle() (automatic)
   State: PLAYING → IDLE
   Resources: All released
   
9. Ready for next interaction
   State: IDLE
```

## Error Handling Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Error Recovery Flow                       │
└─────────────────────────────────────────────────────────────┘

Any State
    │
    │ Error Detected
    │ (Permission denied, API failure, etc.)
    ▼
┌──────────┐
│ Log      │
│ Error    │
└──────────┘
    │
    ▼
┌──────────┐
│ Notify   │
│ Delegate │
└──────────┘
    │
    ▼
┌──────────┐
│ Force    │
│ Idle     │
└──────────┘
    │
    ▼
IDLE State
(Safe state)
```

## Real-Time Performance

```
┌─────────────────────────────────────────────────────────────┐
│              Timing Characteristics                          │
└─────────────────────────────────────────────────────────────┘

State Transition Time:           < 1 ms
Actor Queue Processing:           < 1 ms
Callback Execution:               Depends on callback
Audio Session Configuration:      10-50 ms
Microphone Start Latency:         50-100 ms
Speech Recognition Start:         100-200 ms
TTS Synthesis Start:              50-100 ms

Total End-to-End Latency:
User speaks → ASR ready:          150-300 ms
Response ready → TTS starts:      50-100 ms
TTS complete → Ready to listen:   < 50 ms
```
