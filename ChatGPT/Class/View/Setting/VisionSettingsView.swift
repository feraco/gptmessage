//
//  VisionSettingsView.swift
//  ChatGPT
//
//  Created by GitHub Copilot on 2025/11/15.
//

import SwiftUI

struct VisionSettingsView: View {
    
    @ObservedObject var configuration = VisionConfiguration.shared
    @State private var showConsentAlert = false
    @State private var showClearDataAlert = false
    
    var body: some View {
        Form {
            Section {
                Toggle("Enable Vision Features", isOn: $configuration.isVisionEnabled)
            } header: {
                Text("Vision Features")
            } footer: {
                Text("Enable camera-based vision interactions for face detection and scene analysis.")
            }
            
            if configuration.isVisionEnabled {
                Section {
                    Toggle("Scene Analysis", isOn: $configuration.isSceneAnalysisEnabled)
                        .disabled(!configuration.isVisionEnabled)
                } footer: {
                    Text("Analyze and describe scenes when you ask questions like 'What do you see?' or 'Describe what you see'.")
                }
                
                Section {
                    Toggle("Face Recognition", isOn: $configuration.isFaceRecognitionEnabled)
                        .disabled(!configuration.isVisionEnabled)
                        .onChange(of: configuration.isFaceRecognitionEnabled) { newValue in
                            if newValue && !configuration.hasFaceRecognitionConsent {
                                showConsentAlert = true
                            }
                        }
                    
                    if configuration.isFaceRecognitionEnabled {
                        HStack {
                            Text("Saved Faces")
                            Spacer()
                            Text("\(configuration.savedFaceCount)")
                                .foregroundColor(.secondary)
                        }
                        
                        Button(role: .destructive) {
                            showClearDataAlert = true
                        } label: {
                            Text("Clear All Face Data")
                        }
                    }
                } header: {
                    Text("Face Recognition")
                } footer: {
                    Text("Remember people you introduce to the system and address them by name in future conversations.")
                }
            }
        }
        .navigationTitle("Vision Settings")
        .alert("Face Recognition Consent", isPresented: $showConsentAlert) {
            Button("Allow") {
                configuration.hasFaceRecognitionConsent = true
            }
            Button("Don't Allow", role: .cancel) {
                configuration.isFaceRecognitionEnabled = false
            }
        } message: {
            Text("This app would like to save facial data to recognize you in future conversations. Your facial data will be stored locally on your device and can be deleted at any time.")
        }
        .alert("Clear All Face Data", isPresented: $showClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                configuration.clearAllFaceData()
                configuration.isFaceRecognitionEnabled = false
            }
        } message: {
            Text("This will permanently delete all saved face recognition data. This action cannot be undone.")
        }
    }
}

struct VisionSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            VisionSettingsView()
        }
    }
}
