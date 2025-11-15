# GPTMessage
A SwiftUI app demonstrating how ChatGPT interacts with DALL·E and HuggingFace models for iOS and macOS.

This is what the app looks like on iOS:
<p float="left">
  <img src="screenshot.jpg" width="400" />
  <img src="screenshot1.jpg" width="400" /> 
</p>

And macOS:
<p float="left">
  <img src="screenshot_macOS.jpg" width="800"/>
</p>

## Feautures
### Chat Completion

Chat Completion is driven by OpenAI's chat language models, including gpt-3.5-turbo and gpt-3.5-turbo-0301.
### Image Generation

Image Generation uses OpenAI's image generation API(DALL·E) and HuggingFace's Inference API to create images.

To start drawing, simply send a message beginning with "Draw". For example, you could say `Draw a close-up, studio photographic portrait of a curious-looking blue British Shorthair cat`.

`Draw something` is a hardcoded prompt. However, when Smart Mode is enabled, ChatGPT will classify your prompt and select the most appropriate model to handle it. Therefore, you could ask, `Can you assist me in creating a close-up, studio photographic portrait of a curious-looking blue British Shorthair cat?`.

OpenAI's DALL·E is the preferred option since it's stable and fast(but expensive). You can easily switch to Hugging Face's Inference API(like [stable-diffusion-v1-5](https://huggingface.co/runwayml/stable-diffusion-v1-5) or [stabilityai/stable-diffusion-2-1](https://huggingface.co/stabilityai/stable-diffusion-2-1)) in the settings.

### Image Caption

By connecting ChatGPT with an Image Caption model such as [nlpconnect/vit-gpt2-image-captioning](https://huggingface.co/nlpconnect/vit-gpt2-image-captioning) from Hugging Face, we can easily integrate the image captioning task with the image generation task.

<p float="left">
  <img src="screenshot_macOS_image_caption.jpg" width="800"/>
</p>

<p float="left">
  <img src="screenshot_image_caption.jpg" width="400" />
  <img src="screenshot_image_caption1.jpg" width="400" />
</p>

## Prompts

Default prompts come from **[Awesome ChatGPT Prompts](https://github.com/f/awesome-chatgpt-prompts)**.

### iOS

Click the person icon or type '/' to show the prompts list.

### macOS

Type '/' to show the prompts list.

## Usage

Set your OpenAI API key in the `AppConfiguration`.

```swift
class AppConfiguration: ObservableObject {
        
    @AppStorage("configuration.key") var key = "OpenAI API Key"
    
}
```

Set your Hugging Face User Access Token in the `HuggingFaceConfiguration`.

```swift
class HuggingFaceConfiguration: ObservableObject {
        
    @AppStorage("huggingFace.key") var key: String = ""
    
}
```

## Audio Orchestrator

The app now includes a comprehensive audio orchestrator system for managing voice interactions. This system coordinates Automatic Speech Recognition (ASR) and Text-to-Speech (TTS) to enable smooth conversation flow without interference between listening and playback.

### Features

- **State Management**: Robust state machine with idle, listening, processing, and playing states
- **Thread-Safe**: Uses Swift actors for safe concurrent access
- **Real-Time**: Designed for low-latency voice interactions
- **Resource Efficient**: Automatically enters idle state to conserve resources
- **Easy Integration**: Simple API through `AudioManager.shared`

### Quick Start

```swift
import ChatGPT

// Request authorization
AudioManager.shared.requestAuthorization { authorized in
    if authorized {
        Task {
            // Start listening
            try await AudioManager.shared.startListening()
        }
    }
}

// Subscribe to recognized text
AudioManager.shared.recognizedTextPublisher
    .sink { text, isFinal in
        print("Recognized: \(text)")
    }
    .store(in: &cancellables)

// Speak a response
Task {
    try await AudioManager.shared.speak("Hello, how can I help you?")
}
```

For detailed documentation, see [AUDIO_ORCHESTRATOR.md](AUDIO_ORCHESTRATOR.md).
