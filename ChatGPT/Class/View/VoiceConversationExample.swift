//
//  VoiceConversationExample.swift
//  ChatGPT
//
//  Example integration of AudioManager with conversation flow
//

import SwiftUI
import Combine

/// Example view demonstrating voice conversation integration
@available(iOS 13.0, macOS 10.15, *)
struct VoiceConversationView: View {
    @StateObject private var viewModel = VoiceConversationViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // State indicator
            Text("State: \(viewModel.currentState.rawValue)")
                .font(.headline)
                .foregroundColor(stateColor)
            
            // Recognized text display
            if !viewModel.recognizedText.isEmpty {
                Text("You said: \(viewModel.recognizedText)")
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            // Response display
            if !viewModel.response.isEmpty {
                Text("Response: \(viewModel.response)")
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Spacer()
            
            // Control buttons
            HStack(spacing: 20) {
                // Start listening button
                Button(action: {
                    Task {
                        await viewModel.startListening()
                    }
                }) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(viewModel.isListening ? Color.red : Color.blue)
                        .clipShape(Circle())
                }
                .disabled(viewModel.isListening || viewModel.isPlaying)
                
                // Stop listening button
                Button(action: {
                    Task {
                        await viewModel.stopListening()
                    }
                }) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.gray)
                        .clipShape(Circle())
                }
                .disabled(!viewModel.isListening)
                
                // Test speak button
                Button(action: {
                    Task {
                        await viewModel.testSpeak()
                    }
                }) {
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.green)
                        .clipShape(Circle())
                }
                .disabled(viewModel.isListening || viewModel.isPlaying)
            }
            .padding()
        }
        .padding()
        .onAppear {
            viewModel.requestAuthorization()
        }
    }
    
    private var stateColor: Color {
        switch viewModel.currentState {
        case .idle:
            return .gray
        case .listening:
            return .red
        case .processing:
            return .orange
        case .playing:
            return .green
        }
    }
}

/// ViewModel for voice conversation example
@available(iOS 13.0, macOS 10.15, *)
class VoiceConversationViewModel: ObservableObject {
    @Published var currentState: AudioState = .idle
    @Published var recognizedText: String = ""
    @Published var response: String = ""
    @Published var isAuthorized: Bool = false
    
    private let audioManager = AudioManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    var isListening: Bool {
        currentState == .listening
    }
    
    var isPlaying: Bool {
        currentState == .playing
    }
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        // Subscribe to state changes
        audioManager.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.currentState = state
            }
            .store(in: &cancellables)
        
        // Subscribe to recognized text
        audioManager.recognizedTextPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text, isFinal in
                self?.recognizedText = text
                
                if isFinal {
                    // Process the recognized text
                    self?.processRecognizedText(text)
                }
            }
            .store(in: &cancellables)
    }
    
    func requestAuthorization() {
        audioManager.requestAuthorization { [weak self] authorized in
            DispatchQueue.main.async {
                self?.isAuthorized = authorized
                if !authorized {
                    print("Authorization denied for speech recognition")
                }
            }
        }
    }
    
    func startListening() async {
        guard isAuthorized else {
            print("Not authorized for speech recognition")
            return
        }
        
        do {
            try await audioManager.startListening()
        } catch {
            print("Error starting listening: \(error)")
        }
    }
    
    func stopListening() async {
        await audioManager.stopListening()
    }
    
    func testSpeak() async {
        let testMessage = "Hello! This is a test of the text to speech system."
        await speakResponse(testMessage)
    }
    
    private func processRecognizedText(_ text: String) {
        // In a real app, this would send to ChatGPT API
        // For this example, we'll just echo back
        let response = "You said: \(text)"
        
        Task {
            await speakResponse(response)
        }
    }
    
    private func speakResponse(_ text: String) async {
        DispatchQueue.main.async { [weak self] in
            self?.response = text
        }
        
        do {
            try await audioManager.speak(text)
        } catch {
            print("Error speaking: \(error)")
        }
    }
}

// MARK: - Preview

@available(iOS 13.0, macOS 10.15, *)
struct VoiceConversationView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceConversationView()
    }
}
