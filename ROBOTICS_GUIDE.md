# Humanoid Robot Integration Guide

This guide provides comprehensive instructions for integrating the GPTMessage app with a humanoid robot.

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Hardware Requirements](#hardware-requirements)
4. [Software Configuration](#software-configuration)
5. [Assembly Instructions](#assembly-instructions)
6. [Usage](#usage)
7. [Advanced Configuration](#advanced-configuration)
8. [Troubleshooting](#troubleshooting)
9. [Best Practices](#best-practices)

## Overview

GPTMessage can transform your iPhone or iPad into the conversational interface for a humanoid robot. The app provides:

- **Speech Recognition (ASR)**: Captures voice input and converts it to text
- **Natural Language Processing**: Processes input through ChatGPT for intelligent responses
- **Text-to-Speech (TTS)**: Converts text responses to natural-sounding speech
- **Avatar Animation**: Displays expressive facial animations synchronized with speech
- **Emotion Detection**: Automatically detects and displays appropriate emotions

## Architecture

```
User Voice → ASR Service → Text Input
                              ↓
                         ChatGPT API
                              ↓
                        Text Response
                              ↓
            ┌─────────────────┴─────────────────┐
            ↓                                   ↓
      TTS Service                     Avatar Animation
            ↓                                   ↓
      Audio Output                     Visual Display
```

### Components

1. **ASR Service** (`ASRService.swift`)
   - Handles audio recording
   - Manages microphone permissions
   - Integrates with multiple ASR providers

2. **TTS Service** (`TTSService.swift`)
   - Generates speech from text
   - Supports multiple TTS providers
   - Manages audio playback

3. **Avatar Animation Service** (`AvatarAnimationService.swift`)
   - Controls facial expressions
   - Synchronizes animations with speech
   - Detects emotions from text

4. **Configuration Classes**
   - `ASRConfiguration`: ASR settings
   - `TTSConfiguration`: TTS settings
   - `AvatarConfiguration`: Avatar appearance and behavior

## Hardware Requirements

### Minimum Requirements

- **Device**: iPhone 8 or later, iPad (6th generation) or later
- **OS**: iOS 16.0 or later
- **Microphone**: Built-in microphone (working condition)
- **Speakers**: Built-in or external speakers
- **Internet**: Stable WiFi or cellular connection

### Recommended Setup

- **Device**: iPhone 12 or later, iPad Pro
- **Mount**: Secure mounting system for robot head
- **Power**: Continuous power supply (USB-C/Lightning cable)
- **Speakers**: External Bluetooth speakers (for better audio quality)
- **Network**: 5GHz WiFi for lower latency

### Optional Hardware

- **External Microphone**: For better voice recognition in noisy environments
- **Battery Pack**: High-capacity battery for portable operation
- **Cooling Fan**: For extended use to prevent overheating

## Software Configuration

### 1. Initial Setup

1. Install the app on your device
2. Open the app and grant necessary permissions:
   - Microphone access (for ASR)
   - Network access (for API calls)

### 2. API Keys Configuration

#### OpenAI API Key (Required)
1. Go to Settings > OpenAI
2. Enter your OpenAI API key
3. This key is used for:
   - ChatGPT conversations
   - Whisper ASR (if selected)
   - OpenAI TTS (if selected)

#### Google Cloud API Key (Optional)
For Google Speech-to-Text and TTS:
1. Create a project in [Google Cloud Console](https://console.cloud.google.com)
2. Enable Cloud Speech-to-Text API and Cloud Text-to-Speech API
3. Create an API key
4. Enter it in Settings > Robotics > ASR Settings

#### Azure API Key (Optional)
For Microsoft Azure Speech services:
1. Create a Speech resource in [Azure Portal](https://portal.azure.com)
2. Get your subscription key and region
3. Enter them in Settings > Robotics > ASR/TTS Settings

### 3. ASR Configuration

1. Navigate to Settings > Robotics > ASR Settings
2. Enable "Speech Input"
3. Select ASR Provider:
   - **Whisper** (Recommended): Uses OpenAI's Whisper model, high accuracy
   - **Google**: Fast and accurate, requires Google API key
   - **Azure**: Enterprise-grade, requires Azure subscription
4. Test the microphone using the Component Tests page

### 4. TTS Configuration

1. Navigate to Settings > Robotics > TTS Settings
2. Enable "Speech Output"
3. Enable "Auto-play responses" for automatic speech
4. Select TTS Provider:
   - **System**: Uses iOS native TTS, no API key required
   - **OpenAI** (Recommended): Natural-sounding voices
   - **Azure**: Multiple voice options
   - **Google**: High-quality voices
5. Adjust settings:
   - **Speech Rate**: 0.5x to 2.0x (default: 1.0x)
   - **Volume**: 0% to 100% (default: 100%)
   - **Voice**: Select from available voices (provider-dependent)

### 5. Avatar Configuration

1. Navigate to Settings > Robotics > Avatar Settings
2. Enable "Avatar Display"
3. Configure options:
   - **Auto-detect Emotion**: Automatically detects emotions from text
   - **Show Subtitles**: Display text during speech
   - **Display Mode**: Full Face, Eyes Only, or Minimal
   - **Animation Speed**: 0.5x to 2.0x (default: 1.0x)
4. Customize appearance:
   - **Eye Color**: Choose your preferred color
   - **Face Color**: Customize the face background
5. Test using the full-screen avatar button

## Assembly Instructions

### Step 1: Prepare the Robot Frame

Your robot should have:
- A stable head structure
- A secure mounting point for the device
- Adequate ventilation around the device
- Cable routing for power

**Tips:**
- Use shock-absorbing materials to protect the device
- Ensure the mount can support the device weight
- Position mounting brackets away from heat sources

### Step 2: Mount the Device

1. Position the iPhone/iPad at the robot's head location
2. Ensure the screen faces forward (where the robot "looks")
3. The device should be at an appropriate "eye level" for your robot
4. Secure the device firmly but allow for easy removal

**Mounting Options:**
- Custom 3D-printed mount
- Adjustable phone holder with clamps
- Magnetic mounting system (be careful with device sensors)

### Step 3: Power Connection

1. Connect a USB-C or Lightning cable to the device
2. Route the cable through the robot's body
3. Connect to a continuous power source:
   - Wall adapter (for stationary use)
   - Large battery pack (for mobile use)
   - Robot's internal power system (with proper voltage regulation)

**Important:**
- Use a high-quality cable to prevent disconnections
- Ensure stable power supply (minimum 2A for charging while in use)
- Consider wireless charging if your device supports it

### Step 4: Audio Setup

**Using Built-in Speakers:**
- No additional setup needed
- Limited volume and quality

**Using External Speakers:**
1. Pair Bluetooth speakers with the device
2. Position speakers near the robot's head
3. Adjust volume appropriately
4. Test audio output

### Step 5: Testing

1. Open the app
2. Go to Settings > Robotics > Test Components
3. Test each component:
   - **ASR Test**: Record and transcribe speech
   - **TTS Test**: Play sample text
   - **Avatar Test**: Verify animations
4. Make adjustments as needed

## Usage

### Basic Operation

1. **Start a Conversation**
   - Open the app
   - Create a new chat session or select an existing one

2. **Enable Full-Screen Avatar Mode**
   - Tap the robot icon in the toolbar
   - The avatar will display in full-screen
   - The screen will stay on automatically

3. **Voice Interaction**
   - Tap the microphone button
   - Speak your question or command
   - Tap stop when finished
   - The text will appear automatically

4. **Robot Response**
   - ChatGPT processes your input
   - The response is displayed as text
   - TTS automatically speaks the response (if enabled)
   - Avatar animates with appropriate expressions

### Voice Commands Best Practices

- **Speak clearly** at a moderate pace
- **Wait for silence** before speaking
- **Reduce background noise** for better recognition
- **Position yourself** 1-3 feet from the device
- **Speak in complete sentences** for better context

### Avatar Interaction

The avatar automatically displays emotions:
- **Neutral**: Default state
- **Happy**: Positive responses, greetings
- **Sad**: Apologies, sympathetic responses
- **Surprised**: Exciting information, unexpected results
- **Thinking**: Processing, considering options
- **Speaking**: During audio output
- **Listening**: During voice input

### Conversation Flow

```
1. User speaks → ASR captures voice
2. ASR transcribes to text
3. Text sent to ChatGPT
4. ChatGPT generates response
5. Response triggers TTS
6. Avatar animates (emotion + mouth movement)
7. TTS plays audio output
8. Avatar returns to neutral state
```

## Advanced Configuration

### Optimizing Latency

To minimize response time:

1. **Use Fast ASR Provider**
   - Whisper: ~2-5 seconds
   - Google/Azure: ~1-2 seconds

2. **Optimize ChatGPT Settings**
   - Use GPT-3.5-turbo for faster responses
   - Reduce temperature for more consistent output
   - Keep conversation history shorter

3. **Network Optimization**
   - Use 5GHz WiFi when possible
   - Position router close to robot
   - Avoid network-heavy applications

### Battery Management

For mobile robots:

1. **Reduce Power Consumption**
   - Lower screen brightness (affects avatar visibility)
   - Disable unnecessary background apps
   - Use System TTS instead of cloud-based TTS

2. **Monitor Temperature**
   - Use cooling if necessary
   - Reduce load during high-temperature operation
   - Give periodic rest periods

### Custom Prompts for Robotics

Configure system prompts for robot personality:

```swift
// Settings > OpenAI > System Prompt
"You are a helpful humanoid robot assistant. Keep responses concise and friendly. 
Respond in a way that's natural for voice conversation."
```

### Multiple Language Support

1. Change ASR language in provider settings
2. Update TTS voice to match language
3. Inform ChatGPT of language preference in system prompt

## Troubleshooting

### Common Issues

#### Issue: "Microphone permission denied"
**Solution:**
1. Go to iOS Settings > Privacy > Microphone
2. Enable permission for GPTMessage
3. Restart the app

#### Issue: "No audio output"
**Solution:**
1. Check device volume
2. Verify TTS is enabled in settings
3. Test with Component Tests page
4. Try different TTS provider
5. Check speaker connection (if external)

#### Issue: "Speech not recognized"
**Solution:**
1. Verify microphone is working (try native voice recording)
2. Reduce background noise
3. Speak closer to device (1-3 feet)
4. Check internet connection
5. Try different ASR provider
6. Verify API key is correct

#### Issue: "Avatar not animating"
**Solution:**
1. Enable Avatar Display in settings
2. Restart the app
3. Check animation speed setting (not set to 0)
4. Verify in full-screen mode

#### Issue: "Slow response time"
**Solution:**
1. Check internet connection speed
2. Reduce conversation history
3. Use GPT-3.5-turbo instead of GPT-4
4. Switch to faster ASR/TTS provider
5. Clear app cache and restart

#### Issue: "Device overheating"
**Solution:**
1. Ensure proper ventilation
2. Lower screen brightness
3. Use System TTS to reduce processing
4. Give the device rest periods
5. Add cooling fan to robot setup
6. Avoid direct sunlight

#### Issue: "API errors"
**Solution:**
1. Verify API keys are correct
2. Check API quota/billing
3. Ensure APIs are enabled in cloud console
4. Check network connectivity
5. Try different API provider

### Debug Mode

To enable detailed logging:

1. Build the app in Debug mode
2. Check Xcode console for detailed logs
3. Look for errors in ASR, TTS, or Avatar services

## Best Practices

### For Best User Experience

1. **Keep responses concise**: Configure ChatGPT with prompts that encourage brief responses
2. **Use wake words**: Implement custom wake word detection (requires additional development)
3. **Visual feedback**: Enable subtitles so users can read along
4. **Expressive avatar**: Enable auto-detect emotion for more engaging interactions
5. **Appropriate volume**: Set TTS volume loud enough but not overwhelming

### For Reliability

1. **Stable mounting**: Secure the device properly to prevent falls
2. **Continuous power**: Always use external power for extended operation
3. **Network backup**: Have cellular data as backup if WiFi fails
4. **Regular updates**: Keep the app and iOS updated
5. **Monitor performance**: Check device temperature and battery regularly

### For Safety

1. **Heat management**: Ensure adequate cooling
2. **Secure mounting**: Use quality mounting hardware
3. **Cable management**: Secure all cables to prevent tripping
4. **Volume limits**: Don't set volume too high
5. **Supervision**: Monitor robot operation, especially around children

### For Cost Optimization

1. **Use Whisper for ASR**: Included with OpenAI API key
2. **Use System TTS**: Free, no API calls needed
3. **Manage conversation length**: Shorter history = lower costs
4. **Use GPT-3.5**: More cost-effective than GPT-4
5. **Cache responses**: For frequently asked questions

## Technical Specifications

### Supported ASR Providers
- **OpenAI Whisper**: Multilingual, high accuracy
- **Google Speech-to-Text**: Fast, reliable
- **Microsoft Azure Speech**: Enterprise features

### Supported TTS Providers
- **iOS System TTS**: Native, offline capable
- **OpenAI TTS**: Natural voices (alloy, echo, fable, onyx, nova, shimmer)
- **Microsoft Azure TTS**: Multiple voice options
- **Google Cloud TTS**: High-quality synthesis

### Performance Metrics
- **ASR Latency**: 1-5 seconds (provider-dependent)
- **LLM Processing**: 2-10 seconds (model and length-dependent)
- **TTS Generation**: 1-3 seconds (provider-dependent)
- **Total Response Time**: 5-20 seconds (typical)

### Audio Specifications
- **Recording Format**: AAC, 16kHz, Mono
- **Playback Format**: Provider-dependent (MP3, WAV, CAF)
- **Audio Quality**: High (suitable for conversation)

## Support and Resources

### Documentation
- In-app Setup Guide
- Component Test Page
- This documentation

### Community
- GitHub Issues for bug reports
- Feature requests via GitHub
- Community discussions

### API Documentation
- [OpenAI API Docs](https://platform.openai.com/docs)
- [Google Cloud Speech API](https://cloud.google.com/speech-to-text/docs)
- [Azure Speech Services](https://docs.microsoft.com/azure/cognitive-services/speech-service/)

## Future Enhancements

Planned features:
- Wake word detection
- Gesture recognition
- Multi-language real-time translation
- Custom avatar designs
- Robot motor control integration
- Cloud-based conversation history
- Voice cloning options

---

For questions or issues, please open an issue on GitHub or refer to the in-app setup guide.
