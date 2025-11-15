# Vision Features Documentation

## Overview

GPTMessage now includes native iOS Vision API integration that enables camera-based interactions for face detection, scene analysis, and object recognition.

## Features

### 1. Face Recognition
- **Self-Introduction**: The system can detect faces and associate them with names when you introduce yourself
- **Face Recall**: Once a face is saved, the system will recognize and address you by name in future interactions
- **Privacy-First**: All facial data is stored locally on your device and requires explicit user consent

### 2. Scene Analysis
- **On-Demand Vision**: Use voice commands to trigger vision-based analysis instead of constant polling
- **Object Recognition**: Identify objects, scenes, and activities in captured images
- **Text Detection**: Recognize and read text visible in images
- **Edge Detection**: Analyze shapes and contours in images

### 3. Conversational Vision Triggers

The system responds to natural language vision queries:
- "Who is in front of me?"
- "What do you see?"
- "Describe what you see"
- "Analyze this scene"
- "Who am I?"
- "Recognize me"

## Getting Started

### Enabling Vision Features

1. Open the app and go to **Settings**
2. Navigate to **Vision Features**
3. Toggle **Enable Vision Features** to ON
4. Enable specific features:
   - **Scene Analysis**: For general image description and object recognition
   - **Face Recognition**: For recognizing people (requires consent)

### Granting Permissions

The app requires the following permissions for vision features:
- **Camera Access**: To capture images for analysis
- **Face Recognition Consent**: To store facial data locally (optional)

You'll be prompted for these permissions when first using vision features.

## How to Use

### Capturing Images for Analysis

1. In the conversation view, you'll see a **camera icon** button (when the text field is empty)
2. Tap the camera button to capture an image
3. Once captured, type your question or query
4. The system will analyze the image and respond

### Introducing Yourself

To have the system remember you:

1. Capture an image with your face visible using the camera button
2. Type an introduction like:
   - "My name is John"
   - "I am Sarah"
   - "Call me Alex"
3. The system will save your facial data and confirm: "Nice to meet you, [Name]! I'll remember you for next time."

**Note**: Face recognition requires explicit consent. You'll be asked to grant permission the first time you enable this feature.

### Asking Vision Questions

After capturing an image, you can ask:

- **"Who is in front of me?"** - Recognizes saved faces or detects unknown people
- **"What do you see?"** - Provides a detailed scene description
- **"Describe what you see"** - Similar to above, analyzes the entire scene
- **"What's in this image?"** - Identifies objects and elements

### Example Conversations

**Example 1: Introduction**
```
You: [Capture image with camera]
You: "My name is John"
AI: "Nice to meet you, John! I'll remember you for next time."
```

**Example 2: Recognition**
```
You: [Capture image with camera]
You: "Who is in front of me?"
AI: "I can see John! How can I help you today?"
```

**Example 3: Scene Analysis**
```
You: [Capture image of a park]
You: "What do you see?"
AI: "I can see an outdoor scene. The scene appears to be a park or recreational area (confidence: 78%). I also detect: trees, grass, bench."
```

## Privacy and Data Management

### What Data is Stored?

When face recognition is enabled:
- **Face features**: Geometric data about detected faces (bounding boxes, orientations)
- **Face thumbnails**: Small compressed images of detected faces
- **Names**: User-provided names associated with faces

### Where is Data Stored?

All facial recognition data is stored **locally on your device** using iOS UserDefaults. It is never transmitted to external servers.

### Managing Your Data

To view or delete saved face data:

1. Go to **Settings** > **Vision Features**
2. In the **Face Recognition** section:
   - View the count of **Saved Faces**
   - Tap **Clear All Face Data** to permanently delete all facial data

**Warning**: Clearing face data is permanent and cannot be undone.

### Revoking Consent

To disable face recognition:

1. Go to **Settings** > **Vision Features**
2. Toggle **Face Recognition** to OFF
3. Optionally, tap **Clear All Face Data** to remove saved data

## Technical Details

### Vision Framework Capabilities

The app uses Apple's Vision framework for:
- **VNDetectFaceRectanglesRequest**: Face detection
- **VNDetectFaceLandmarksRequest**: Facial features detection
- **VNClassifyImageRequest**: Scene and object classification
- **VNRecognizeTextRequest**: Text recognition
- **VNDetectContoursRequest**: Edge detection
- **VNGenerateAttentionBasedSaliencyImageRequest**: Saliency analysis

### Limitations

- Face recognition uses basic feature comparison. It's not as sophisticated as dedicated face recognition systems
- Scene classification depends on the Vision framework's trained models
- Best results require good lighting and clear images
- Face recognition works best with frontal face views

## System Requirements

- iOS 14.0 or later
- Camera-equipped device
- Camera permissions granted

## Troubleshooting

### "Camera permission is required"
- Go to iPhone **Settings** > **GPTMessage** > Enable **Camera**

### "Face recognition is not enabled"
- Go to app **Settings** > **Vision Features** > Enable **Face Recognition**
- Grant consent when prompted

### "I don't see any faces"
- Ensure faces are clearly visible and well-lit
- Try capturing from a closer distance
- Make sure the face is facing the camera

### Vision features not working
- Check that **Enable Vision Features** is toggled ON in Settings
- Verify camera permissions are granted
- Try restarting the app

## Best Practices

1. **Good Lighting**: Capture images in well-lit environments for best results
2. **Clear Images**: Avoid blurry or motion-affected images
3. **Frontal Faces**: For face recognition, capture faces looking toward the camera
4. **Regular Updates**: Re-introduce yourself if the system doesn't recognize you
5. **Privacy First**: Only enable face recognition if you're comfortable with local data storage

## Privacy Statement

- All vision processing happens on-device using iOS Vision framework
- Facial data is stored locally and never transmitted to external servers
- You can delete all facial data at any time
- Face recognition requires explicit user consent
- No third-party services have access to your facial data

## Support

For issues or questions about vision features:
- Check the Troubleshooting section above
- Review your Settings > Vision Features configuration
- Ensure all required permissions are granted

---

**Note**: Vision features are currently available on iOS only. macOS support may be added in future updates.
