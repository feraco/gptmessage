//
//  RoboticsSetupGuideView.swift
//  ChatGPT
//
//  Setup guide for integrating the app with a humanoid robot
//

import SwiftUI

struct RoboticsSetupGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                
                overviewSection
                
                hardwareRequirementsSection
                
                assemblyStepsSection
                
                configurationStepsSection
                
                usageSection
                
                troubleshootingSection
            }
            .padding()
        }
        .navigationTitle("Robot Setup Guide")
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Humanoid Robot Integration Guide")
                .font(.title)
                .bold()
            
            Text("Transform your iPhone/iPad into the face of a humanoid robot")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Overview")
                .font(.title2)
                .bold()
            
            Text("""
            This app enables your device to act as the conversational interface for a humanoid robot. It provides:
            
            • Speech recognition to capture voice input
            • AI-powered conversation via ChatGPT
            • Text-to-speech for vocal responses
            • Animated avatar display for visual feedback
            • Real-time emotional expressions
            """)
            .padding(.vertical, 5)
        }
    }
    
    private var hardwareRequirementsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hardware Requirements")
                .font(.title2)
                .bold()
            
            Group {
                RequirementRow(
                    icon: "iphone",
                    title: "iPhone or iPad",
                    description: "iOS 16.0 or later"
                )
                
                RequirementRow(
                    icon: "mic.fill",
                    title: "Working Microphone",
                    description: "For speech input"
                )
                
                RequirementRow(
                    icon: "speaker.wave.3.fill",
                    title: "Speakers",
                    description: "Built-in or external"
                )
                
                RequirementRow(
                    icon: "mount.fill",
                    title: "Device Mount",
                    description: "Secure mounting system for robot head"
                )
                
                RequirementRow(
                    icon: "cable.connector",
                    title: "Power Supply",
                    description: "Continuous power source or high-capacity battery"
                )
            }
        }
    }
    
    private var assemblyStepsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Assembly Steps")
                .font(.title2)
                .bold()
            
            AssemblyStep(
                number: 1,
                title: "Prepare the Robot Frame",
                description: "Ensure your robot has a stable head mount that can securely hold your device.",
                tips: ["Use shock-absorbing mounting", "Ensure proper ventilation"]
            )
            
            AssemblyStep(
                number: 2,
                title: "Mount the Device",
                description: "Position your iPhone/iPad at the head location, facing forward.",
                tips: ["Device should be at eye level", "Ensure clear view of display"]
            )
            
            AssemblyStep(
                number: 3,
                title: "Connect Power",
                description: "Connect a continuous power supply to prevent battery drain during extended use.",
                tips: ["Use Lightning/USB-C cable", "Consider wireless charging option"]
            )
            
            AssemblyStep(
                number: 4,
                title: "Position Speakers",
                description: "Place speakers near the robot's head for clear audio output.",
                tips: ["Use Bluetooth speakers for wireless setup", "Adjust volume appropriately"]
            )
        }
    }
    
    private var configurationStepsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Configuration")
                .font(.title2)
                .bold()
            
            ConfigStep(
                number: 1,
                title: "API Keys",
                description: "Enter your OpenAI API key in Settings > OpenAI"
            )
            
            ConfigStep(
                number: 2,
                title: "Enable ASR",
                description: "Go to Settings > Robotics > Enable Speech Input"
            )
            
            ConfigStep(
                number: 3,
                title: "Enable TTS",
                description: "Go to Settings > Robotics > Enable Speech Output"
            )
            
            ConfigStep(
                number: 4,
                title: "Enable Avatar",
                description: "Go to Settings > Robotics > Enable Avatar Display"
            )
            
            ConfigStep(
                number: 5,
                title: "Test Components",
                description: "Use the Test Components page to verify all systems work"
            )
        }
    }
    
    private var usageSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Usage")
                .font(.title2)
                .bold()
            
            Text("""
            **Basic Operation:**
            
            1. Open a new conversation in the app
            2. Enable the full-screen avatar mode
            3. Speak to the robot - it will automatically detect speech
            4. The robot will process your input, respond with text and speech
            5. The avatar will animate to show expressions
            
            **Tips:**
            
            • Speak clearly and at a moderate pace
            • Wait for the robot to finish speaking before asking another question
            • Use the emotion auto-detection for more natural interactions
            • Keep the device screen clean for best visual experience
            • Monitor battery and temperature during extended use
            """)
            .padding(.vertical, 5)
        }
    }
    
    private var troubleshootingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Troubleshooting")
                .font(.title2)
                .bold()
            
            TroubleshootingItem(
                issue: "Speech not recognized",
                solution: "Check microphone permissions, reduce background noise, speak closer to device"
            )
            
            TroubleshootingItem(
                issue: "No audio output",
                solution: "Check volume settings, verify TTS is enabled, test with Component Tests"
            )
            
            TroubleshootingItem(
                issue: "Avatar not animating",
                solution: "Enable Avatar Display in settings, check animation speed setting"
            )
            
            TroubleshootingItem(
                issue: "Slow response time",
                solution: "Check internet connection, reduce conversation history, use faster model"
            )
            
            TroubleshootingItem(
                issue: "Device overheating",
                solution: "Ensure proper ventilation, reduce screen brightness, enable power-saving mode"
            )
        }
    }
}

// MARK: - Supporting Views

struct RequirementRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct AssemblyStep: View {
    let number: Int
    let title: String
    let description: String
    let tips: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Text("\(number)")
                            .font(.headline)
                            .foregroundColor(.white)
                    )
                
                Text(title)
                    .font(.headline)
            }
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.leading, 42)
            
            if !tips.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(tips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                            Text(tip)
                                .font(.caption)
                        }
                    }
                }
                .foregroundColor(.secondary)
                .padding(.leading, 52)
            }
        }
        .padding(.vertical, 8)
    }
}

struct ConfigStep: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number).")
                .font(.headline)
                .foregroundColor(.blue)
                .frame(width: 25, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

struct TroubleshootingItem: View {
    let issue: String
    let solution: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text(issue)
                    .font(.headline)
            }
            
            Text(solution)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, 28)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Preview

struct RoboticsSetupGuideView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RoboticsSetupGuideView()
        }
    }
}
