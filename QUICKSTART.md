# Quick Start Guide for Robotics Features

Get your humanoid robot up and running in 5 minutes!

## Prerequisites
- iPhone/iPad with iOS 16.0+
- OpenAI API key ([Get one here](https://platform.openai.com/api-keys))
- Internet connection

## 5-Minute Setup

### Step 1: Configure API Key (1 minute)
1. Open the app
2. Tap Settings (⚙️ icon)
3. Go to Settings > OpenAI
4. Enter your OpenAI API key
5. Tap "Done"

### Step 2: Enable Robotics Features (2 minutes)
1. Go to Settings > Robotics > ASR, TTS & Avatar
2. Enable these three toggles:
   - ✅ Enable Speech Input
   - ✅ Enable Speech Output
   - ✅ Enable Avatar Display
3. Select providers:
   - ASR Provider: **OpenAI Whisper** (uses your OpenAI key)
   - TTS Provider: **System TTS** (free, works offline)
4. Enable:
   - ✅ Auto-play responses
   - ✅ Auto-detect Emotion
   - ✅ Show Subtitles
5. Tap back to save settings

### Step 3: Test the Robot (2 minutes)
1. Go to Settings > Robotics > Test Components
2. **Test Speech Recognition:**
   - Tap "Start Recording"
   - Say something like "Hello robot"
   - Tap "Stop Recording"
   - Your text should appear transcribed
3. **Test Text-to-Speech:**
   - Type "Hello! I am your robot assistant."
   - Tap "Speak Text"
   - You should hear the robot speak
4. **Test Avatar:**
   - Tap emotion buttons to see facial expressions
   - Watch the eyes and mouth animate

### Step 4: Start Conversing
1. Go back to main screen
2. Tap the robot icon (🤖) in the toolbar
3. The avatar will display full-screen
4. Start talking to your robot!

## Basic Usage

### Talking to the Robot
1. In full-screen avatar mode (or normal chat)
2. Tap the microphone button (🎤)
3. Speak your question
4. Tap stop when done
5. Robot will:
   - Show "thinking" expression
   - Process your question with ChatGPT
   - Display response text
   - Speak the answer
   - Show appropriate emotions

### Example Conversations
Try asking:
- "What's the weather like today?"
- "Tell me a joke"
- "Explain quantum physics in simple terms"
- "What's 25 times 37?"
- "How do I make pancakes?"

## Troubleshooting

### "Microphone permission denied"
→ Go to iOS Settings > Privacy > Microphone > Enable GPTMessage

### "No sound"
→ Check device volume, enable TTS in settings

### "Speech not recognized"
→ Speak clearly, reduce background noise, check internet

### "Avatar not showing"
→ Tap the robot icon (🤖) in toolbar

### "Slow responses"
→ Check internet connection, reduce background apps

## Next Steps

### Customize Your Robot
1. Go to Settings > Robotics > Avatar Settings
2. Change colors:
   - Eye Color: Choose your favorite
   - Face Color: Customize appearance
3. Adjust animation speed
4. Try different TTS voices

### Improve Voice Recognition
For better accuracy:
1. Speak 1-3 feet from device
2. Reduce background noise
3. Speak in complete sentences
4. Wait for robot to finish speaking

### Use Full-Screen Mode
Perfect for mounting on a robot:
1. Enable Avatar Display
2. Tap robot icon in toolbar
3. Screen stays on automatically
4. Mount device as robot's face

### Try Advanced Providers
For even better quality:

**Better Speech Recognition:**
1. Get Google Cloud API key
2. Settings > Robotics > ASR
3. Select "Google Speech-to-Text"
4. Enter API key

**Better Voice Quality:**
1. Settings > Robotics > TTS
2. Select "OpenAI TTS"
3. Choose voice: Alloy, Echo, Fable, etc.

## Tips for Best Experience

### Voice Commands
- Be specific and clear
- Use natural conversational language
- Wait for the robot to finish before speaking again
- Speak at normal volume and pace

### Battery Life
- Keep device plugged in for continuous use
- Lower screen brightness if needed
- Use System TTS to save battery

### Performance
- Close other apps
- Use WiFi when possible
- Position device for good microphone access

### Robot Personality
Customize the system prompt:
1. Settings > OpenAI > System Prompt
2. Try: "You are a friendly robot assistant. Keep responses brief and conversational."

## Cost Estimates

Using default settings (Whisper + System TTS):
- **Speech Recognition**: ~$0.006 per minute
- **ChatGPT**: ~$0.002 per conversation
- **Text-to-Speech**: Free (System TTS)

**Total**: ~$0.01 per minute of conversation

*Costs may vary based on usage and selected providers.*

## Support

### In-App Help
- Settings > Robotics > Setup Guide (detailed instructions)
- Settings > Robotics > Test Components (verify everything works)

### Documentation
- `README.md` - General app documentation
- `ROBOTICS_GUIDE.md` - Detailed technical guide
- `ROBOTICS_EXAMPLES.md` - Configuration examples

### Need More Help?
- Check the GitHub repository for issues
- Read the comprehensive robotics guide
- Test each component separately

## What's Next?

Once you're comfortable with basic operation:
1. Read `ROBOTICS_GUIDE.md` for advanced features
2. Try different configuration examples in `ROBOTICS_EXAMPLES.md`
3. Explore robot assembly instructions for physical integration
4. Experiment with different emotions and expressions
5. Customize prompts for specific use cases

---

**Congratulations! Your robot is ready to talk!** 🤖✨

Start a conversation and enjoy your new AI-powered humanoid robot assistant!
