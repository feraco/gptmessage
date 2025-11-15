# Robotics Configuration Examples

This file provides example configurations for different use cases of the robotics integration.

## Basic Voice Assistant Setup

Minimal configuration for a stationary voice assistant robot:

```
ASR Configuration:
- Provider: OpenAI Whisper
- API Key: Use existing OpenAI key
- Enabled: Yes

TTS Configuration:
- Provider: System TTS
- Auto-play: Yes
- Speech Rate: 1.0x
- Volume: 80%
- Enabled: Yes

Avatar Configuration:
- Enabled: No (optional for voice-only setup)
- Display Mode: N/A
```

**Best for:** Simple voice assistant, low-cost setup, no visual display needed

---

## Full Robot with Avatar Display

Complete setup with visual and audio feedback:

```
ASR Configuration:
- Provider: OpenAI Whisper
- API Key: [Your OpenAI API Key]
- Enabled: Yes

TTS Configuration:
- Provider: OpenAI TTS
- Voice: Alloy (or your preference)
- Auto-play: Yes
- Speech Rate: 1.0x
- Volume: 100%
- Enabled: Yes

Avatar Configuration:
- Enabled: Yes
- Auto-detect Emotion: Yes
- Show Subtitles: Yes
- Display Mode: Full Face
- Animation Speed: 1.0x
- Eye Color: Blue
- Face Color: White
```

**Best for:** Interactive humanoid robot, full conversational experience, demo purposes

---

## High-Performance Enterprise Setup

Optimized for commercial/enterprise use with fastest response times:

```
ASR Configuration:
- Provider: Google Speech-to-Text
- API Key: [Your Google Cloud API Key]
- Enabled: Yes

TTS Configuration:
- Provider: Google Cloud TTS
- API Key: [Your Google Cloud API Key]
- Auto-play: Yes
- Speech Rate: 1.2x (slightly faster for efficiency)
- Volume: 100%
- Enabled: Yes

Avatar Configuration:
- Enabled: Yes
- Auto-detect Emotion: Yes
- Show Subtitles: No (cleaner display)
- Display Mode: Full Face
- Animation Speed: 1.2x
- Eye Color: Custom brand color
- Face Color: Custom brand color
```

**Best for:** Commercial deployments, exhibitions, high-traffic environments

---

## Educational Robot Setup

Designed for classroom/learning environments:

```
ASR Configuration:
- Provider: OpenAI Whisper (multilingual support)
- API Key: [Your OpenAI API Key]
- Enabled: Yes

TTS Configuration:
- Provider: System TTS
- Auto-play: Yes
- Speech Rate: 0.8x (slower for clarity)
- Volume: 100%
- Language: Based on classroom needs
- Enabled: Yes

Avatar Configuration:
- Enabled: Yes
- Auto-detect Emotion: Yes
- Show Subtitles: Yes (helps with learning)
- Display Mode: Full Face
- Animation Speed: 0.9x
- Eye Color: Friendly color
- Face Color: White
```

**Best for:** Education, tutoring, language learning, accessibility

---

## Mobile Robot Setup

Battery-optimized configuration for mobile robots:

```
ASR Configuration:
- Provider: OpenAI Whisper
- API Key: [Your OpenAI API Key]
- Enabled: Yes

TTS Configuration:
- Provider: System TTS (no API calls, lower battery usage)
- Auto-play: Yes
- Speech Rate: 1.0x
- Volume: 80%
- Enabled: Yes

Avatar Configuration:
- Enabled: Yes
- Auto-detect Emotion: Yes
- Show Subtitles: No (saves processing)
- Display Mode: Minimal (lower power consumption)
- Animation Speed: 1.0x
- Eye Color: Blue
- Face Color: Black (saves battery on OLED)
```

**Best for:** Mobile robots, battery-powered setups, autonomous navigation

---

## Multilingual International Setup

Configuration for international deployment:

```
ASR Configuration:
- Provider: OpenAI Whisper (70+ languages)
- API Key: [Your OpenAI API Key]
- Enabled: Yes

TTS Configuration:
- Provider: Azure TTS
- API Key: [Your Azure API Key]
- Region: [Your nearest region]
- Voice: Neural voices in target language
- Auto-play: Yes
- Speech Rate: 1.0x
- Volume: 100%
- Enabled: Yes

Avatar Configuration:
- Enabled: Yes
- Auto-detect Emotion: Yes
- Show Subtitles: Yes (important for multilingual)
- Display Mode: Full Face
- Animation Speed: 1.0x
```

**Best for:** International deployments, tourist information, multilingual support

---

## Testing and Development Setup

Configuration for development and testing:

```
ASR Configuration:
- Provider: OpenAI Whisper
- API Key: [Your OpenAI API Key]
- Enabled: Yes

TTS Configuration:
- Provider: System TTS (faster iteration)
- Auto-play: No (manual control for testing)
- Speech Rate: 1.5x (faster testing)
- Volume: 50%
- Enabled: Yes

Avatar Configuration:
- Enabled: Yes
- Auto-detect Emotion: Yes
- Show Subtitles: Yes (debugging)
- Display Mode: Full Face
- Animation Speed: 1.5x (faster testing)
```

**Best for:** Development, debugging, rapid testing, demonstrations

---

## Comparison Table

| Feature | Basic | Full | Enterprise | Educational | Mobile | Multilingual | Dev |
|---------|-------|------|------------|-------------|--------|--------------|-----|
| ASR Provider | Whisper | Whisper | Google | Whisper | Whisper | Whisper | Whisper |
| TTS Provider | System | OpenAI | Google | System | System | Azure | System |
| Avatar | Optional | Yes | Yes | Yes | Minimal | Yes | Yes |
| Cost | Low | Medium | High | Low | Low | High | Low |
| Response Time | Medium | Medium | Fast | Slow | Medium | Medium | Fast |
| Quality | Good | Excellent | Excellent | Good | Good | Excellent | Good |
| Battery Usage | Low | High | High | Medium | Low | High | Medium |

---

## Notes on API Costs

### OpenAI Whisper
- $0.006 per minute of audio
- Highly accurate, multilingual
- Recommended for most use cases

### OpenAI TTS
- $15 per 1M characters
- Natural-sounding voices
- Great for production

### Google Cloud
- Speech-to-Text: $0.006-0.009 per 15 seconds
- Text-to-Speech: $4-16 per 1M characters
- Fast and reliable

### Azure Speech Services
- Speech-to-Text: $1 per hour
- Text-to-Speech: $16 per 1M characters
- Enterprise features

### System TTS
- Free
- Good quality
- Offline capable
- Recommended for development and mobile

---

## Recommended Combinations

1. **Budget-Friendly**: Whisper + System TTS
2. **Best Quality**: Whisper + OpenAI TTS
3. **Fastest**: Google STT + Google TTS
4. **Most Reliable**: Azure STT + Azure TTS
5. **Mobile**: Whisper + System TTS with minimal avatar

---

## Configuration Tips

1. **Always test before deployment**: Use the Component Tests page
2. **Monitor costs**: Track API usage in your provider dashboards
3. **Adjust for environment**: Noisier environments need better ASR
4. **Consider latency**: Faster providers may cost more
5. **Battery management**: Mobile setups should use System TTS
6. **User preferences**: Let users customize avatar appearance
7. **Backup providers**: Have a fallback TTS if primary fails

---

For more details, see the main ROBOTICS_GUIDE.md documentation.
