//
//  RoboticsSettingsView.swift
//  ChatGPT
//
//  Settings view for ASR, TTS, and Avatar configuration for robotics
//

import SwiftUI

struct RoboticsSettingsView: View {
    @ObservedObject var asrConfig = ASRConfiguration.shared
    @ObservedObject var ttsConfig = TTSConfiguration.shared
    @ObservedObject var avatarConfig = AvatarConfiguration.shared
    
    @State private var showFullScreenAvatar = false
    
    var body: some View {
        Form {
            // ASR Settings
            Section(header: Text("Speech Recognition (ASR)")) {
                Toggle("Enable Speech Input", isOn: $asrConfig.isEnabled)
                
                if asrConfig.isEnabled {
                    Picker("ASR Provider", selection: $asrConfig.provider) {
                        ForEach(ASRProvider.allCases, id: \.self) { provider in
                            Text(provider.rawValue)
                        }
                    }
                    
                    switch asrConfig.provider {
                    case .google:
                        SecureField("Google API Key", text: $asrConfig.googleAPIKey)
                    case .azure:
                        SecureField("Azure API Key", text: $asrConfig.azureAPIKey)
                        TextField("Azure Region", text: $asrConfig.azureRegion)
                            .autocapitalization(.none)
                    case .whisper:
                        Text("Uses OpenAI API Key from main settings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // TTS Settings
            Section(header: Text("Text-to-Speech (TTS)")) {
                Toggle("Enable Speech Output", isOn: $ttsConfig.isEnabled)
                
                if ttsConfig.isEnabled {
                    Toggle("Auto-play responses", isOn: $ttsConfig.autoPlay)
                    
                    Picker("TTS Provider", selection: $ttsConfig.provider) {
                        ForEach(TTSProvider.allCases, id: \.self) { provider in
                            Text(provider.rawValue)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Speech Rate")
                            Spacer()
                            Text(String(format: "%.1fx", ttsConfig.speechRate))
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $ttsConfig.speechRate, in: 0.5...2.0, step: 0.1)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Volume")
                            Spacer()
                            Text(String(format: "%.0f%%", ttsConfig.volume * 100))
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $ttsConfig.volume, in: 0.0...1.0, step: 0.1)
                    }
                    
                    if ttsConfig.provider == .openAI {
                        Picker("Voice", selection: $ttsConfig.openAIVoice) {
                            ForEach(OpenAIVoice.allCases, id: \.self) { voice in
                                Text(voice.rawValue.capitalized)
                            }
                        }
                    }
                    
                    if ttsConfig.provider == .azure {
                        TextField("Azure Region", text: $ttsConfig.azureRegion)
                            .autocapitalization(.none)
                    }
                }
            }
            
            // Avatar Settings
            Section(header: Text("Avatar Animation")) {
                Toggle("Enable Avatar Display", isOn: $avatarConfig.isEnabled)
                
                if avatarConfig.isEnabled {
                    Toggle("Auto-detect Emotion", isOn: $avatarConfig.autoDetectEmotion)
                    
                    Text("Automatically detect emotion from response text")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Toggle("Show Subtitles", isOn: $avatarConfig.showSubtitles)
                    
                    Picker("Display Mode", selection: $avatarConfig.displayMode) {
                        ForEach(AvatarDisplayMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Animation Speed")
                            Spacer()
                            Text(String(format: "%.1fx", avatarConfig.animationSpeed))
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $avatarConfig.animationSpeed, in: 0.5...2.0, step: 0.1)
                    }
                    
                    ColorPicker("Eye Color", selection: $avatarConfig.eyeColor)
                    ColorPicker("Face Color", selection: $avatarConfig.faceColor)
                    
                    Button {
                        showFullScreenAvatar = true
                    } label: {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Test Full Screen Avatar")
                        }
                    }
                }
            }
            
            // Robotics Integration
            Section(header: Text("Robotics Integration")) {
                NavigationLink {
                    RoboticsSetupGuideView()
                } label: {
                    HStack {
                        Image(systemName: "book.fill")
                        Text("Setup Guide")
                    }
                }
                
                NavigationLink {
                    RoboticsTestView()
                } label: {
                    HStack {
                        Image(systemName: "wrench.and.screwdriver.fill")
                        Text("Test Components")
                    }
                }
            }
        }
        .navigationTitle("Robotics Settings")
        .sheet(isPresented: $showFullScreenAvatar) {
            FullScreenAvatarView()
        }
    }
}

// MARK: - Test View

struct RoboticsTestView: View {
    @ObservedObject var asrService = ASRService.shared
    @ObservedObject var ttsService = TTSService.shared
    @ObservedObject var avatarService = AvatarAnimationService.shared
    
    @State private var isRecording = false
    @State private var recordingURL: URL?
    @State private var transcription = ""
    @State private var testText = "Hello! I am your robot assistant."
    @State private var statusMessage = ""
    
    var body: some View {
        Form {
            Section(header: Text("Speech Recognition Test")) {
                Button {
                    Task {
                        if isRecording {
                            await stopRecording()
                        } else {
                            await startRecording()
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .foregroundColor(isRecording ? .red : .blue)
                        Text(isRecording ? "Stop Recording" : "Start Recording")
                    }
                }
                
                if !transcription.isEmpty {
                    Text("Transcription: \(transcription)")
                        .font(.caption)
                }
            }
            
            Section(header: Text("Text-to-Speech Test")) {
                TextField("Test Text", text: $testText)
                
                Button {
                    Task {
                        await testTTS()
                    }
                } label: {
                    HStack {
                        Image(systemName: "speaker.wave.3.fill")
                        Text("Speak Text")
                    }
                }
                .disabled(ttsService.isSpeaking)
                
                if ttsService.isSpeaking {
                    Button {
                        ttsService.stopSpeaking()
                    } label: {
                        HStack {
                            Image(systemName: "stop.fill")
                            Text("Stop Speaking")
                        }
                    }
                }
            }
            
            Section(header: Text("Avatar Animation Test")) {
                HStack {
                    ForEach(AvatarEmotion.allCases, id: \.self) { emotion in
                        Button(emotion.rawValue.capitalized) {
                            avatarService.setEmotion(emotion)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                AvatarView()
                    .frame(height: 250)
                    .padding()
            }
            
            if !statusMessage.isEmpty {
                Section {
                    Text(statusMessage)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Component Tests")
    }
    
    private func startRecording() async {
        do {
            isRecording = true
            recordingURL = try await asrService.startRecording()
            statusMessage = "Recording..."
        } catch {
            statusMessage = "Error: \(error.localizedDescription)"
            isRecording = false
        }
    }
    
    private func stopRecording() async {
        guard let url = asrService.stopRecording() else {
            statusMessage = "No recording to stop"
            isRecording = false
            return
        }
        
        isRecording = false
        statusMessage = "Transcribing..."
        
        do {
            let provider = ASRConfiguration.shared.provider
            let apiKey: String
            
            switch provider {
            case .whisper:
                apiKey = AppConfiguration.shared.key
            case .google:
                apiKey = ASRConfiguration.shared.googleAPIKey
            case .azure:
                apiKey = ASRConfiguration.shared.azureAPIKey
            }
            
            transcription = try await asrService.transcribe(
                audioURL: url,
                provider: provider,
                apiKey: apiKey
            )
            statusMessage = "Transcription complete"
        } catch {
            statusMessage = "Transcription error: \(error.localizedDescription)"
        }
    }
    
    private func testTTS() async {
        do {
            statusMessage = "Generating speech..."
            avatarService.startSpeakingAnimation(text: testText)
            
            let provider = TTSConfiguration.shared.provider
            let apiKey = provider.requiresAPIKey ? AppConfiguration.shared.key : ""
            
            _ = try await ttsService.speak(
                text: testText,
                provider: provider,
                apiKey: apiKey
            )
            
            avatarService.stopSpeakingAnimation()
            statusMessage = "Speech complete"
        } catch {
            avatarService.stopSpeakingAnimation()
            statusMessage = "TTS error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Preview

struct RoboticsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RoboticsSettingsView()
        }
    }
}
