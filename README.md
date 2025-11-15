# GPTMessage
A SwiftUI app demonstrating how ChatGPT interacts with DALL·E and HuggingFace models for iOS and macOS.

**NEW:** Now with support for humanoid robot integration including ASR (Automated Speech Recognition), TTS (Text-to-Speech), and animated avatar display!

This is what the app looks like on iOS:
<p float="left">
  <img src="screenshot.jpg" width="400" />
  <img src="screenshot1.jpg" width="400" /> 
</p>

And macOS:
<p float="left">
  <img src="screenshot_macOS.jpg" width="800"/>
</p>

## Features
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

### 🤖 Humanoid Robot Integration (NEW!)

Transform your iPhone/iPad into a conversational humanoid robot interface with the following features:

#### Speech Recognition (ASR)
- **Multiple Providers**: Support for OpenAI Whisper, Google Speech-to-Text, and Microsoft Azure Speech
- **Real-time Transcription**: Convert spoken input to text instantly
- **Easy Integration**: Simple microphone button in the chat interface
- **High Accuracy**: Leverages industry-leading ASR engines

#### Text-to-Speech (TTS)
- **Multiple Voices**: Choose from System TTS, OpenAI TTS, Azure TTS, or Google Cloud TTS
- **Natural Speech**: High-quality, natural-sounding voice output
- **Auto-play Mode**: Automatically speak responses as they arrive
- **Customizable**: Adjust speech rate, pitch, and volume

#### Avatar Animation
- **Expressive Face**: Animated eyes and mouth that sync with speech
- **Emotion Detection**: Automatically detects emotions from response text
- **Real-time Animation**: Smooth animations synchronized with audio output
- **Customizable Appearance**: Choose eye color, face color, and animation speed
- **Full-screen Mode**: Display mode optimized for robot head mounting

#### Robotics Features
- **Display Control**: Full-screen avatar mode keeps screen on for continuous operation
- **Emotion Expressions**: Happy, sad, surprised, thinking, speaking, and listening states
- **Subtitle Display**: Optional text display synchronized with speech
- **Low Latency**: Optimized for real-time conversational interactions
- **Setup Guide**: Comprehensive documentation for robot assembly and integration

## Prompts

Default prompts come from **[Awesome ChatGPT Prompts](https://github.com/f/awesome-chatgpt-prompts)**.

### iOS

Click the person icon or type '/' to show the prompts list.

### macOS

Type '/' to show the prompts list.

## Usage

### Basic Setup

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

### Robotics Setup

To enable robotics features:

1. **Navigate to Settings** → Tap the settings icon in the app
2. **Open Robotics Settings** → Go to Settings > Robotics > ASR, TTS & Avatar
3. **Configure ASR** (Speech Recognition):
   - Enable "Speech Input"
   - Select your preferred ASR provider (Whisper, Google, or Azure)
   - Enter API keys if required
4. **Configure TTS** (Text-to-Speech):
   - Enable "Speech Output"
   - Select your preferred TTS provider
   - Adjust speech rate, volume, and voice settings
   - Enable "Auto-play responses" for automatic speech
5. **Configure Avatar**:
   - Enable "Avatar Display"
   - Enable "Auto-detect Emotion" for dynamic expressions
   - Customize eye color, face color, and animation speed
   - Test the full-screen avatar mode
6. **Test Components** → Use the test page to verify all systems work correctly

### Using Voice Input

Once ASR is enabled:
1. Start a conversation
2. Tap the microphone icon in the input area
3. Speak your message
4. Tap the stop icon when finished
5. The text will automatically appear in the input field

### Robot Assembly

For detailed robot assembly instructions:
1. Go to Settings > Robotics > Setup Guide
2. Follow the comprehensive step-by-step instructions
3. Includes hardware requirements, assembly steps, and troubleshooting

### Full-Screen Avatar Mode

For robotics use:
1. Start a conversation
2. Enable avatar in Settings > Robotics
3. Tap the robot icon in the toolbar
4. The avatar will display in full-screen mode
5. Mount your device as the robot's face
6. The screen will stay on during operation

## API Keys Required

- **OpenAI API Key**: Required for ChatGPT and Whisper ASR (get it from [OpenAI](https://platform.openai.com/api-keys))
- **Google Cloud API Key**: Optional, for Google Speech-to-Text and TTS (get it from [Google Cloud Console](https://console.cloud.google.com))
- **Azure API Key**: Optional, for Microsoft Azure Speech services (get it from [Azure Portal](https://portal.azure.com))
- **HuggingFace Token**: Optional, for HuggingFace models (get it from [HuggingFace](https://huggingface.co/settings/tokens))

## Requirements

- iOS 16.0+ or macOS 13.0+
- Swift 5.7+
- Xcode 14.0+
- Internet connection for API calls
- Microphone access (for ASR)
- Audio output capability (for TTS)

## License

See [LICENSE.md](LICENSE.md) for details.
