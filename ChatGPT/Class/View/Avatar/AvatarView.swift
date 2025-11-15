//
//  AvatarView.swift
//  ChatGPT
//
//  Avatar View for displaying robot face with animations
//

import SwiftUI

struct AvatarView: View {
    @ObservedObject var animationService = AvatarAnimationService.shared
    @ObservedObject var configuration = AvatarConfiguration.shared
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(configuration.faceColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                )
            
            VStack(spacing: 30) {
                // Eyes
                HStack(spacing: 60) {
                    eyeView()
                    eyeView()
                }
                .padding(.top, 40)
                
                // Mouth
                if configuration.displayMode == .fullFace {
                    mouthView()
                        .padding(.bottom, 40)
                }
            }
            
            // Subtitle text
            if configuration.showSubtitles && !animationService.currentState.currentText.isEmpty {
                VStack {
                    Spacer()
                    Text(animationService.currentState.currentText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1.0, contentMode: .fit)
    }
    
    @ViewBuilder
    private func eyeView() -> some View {
        let state = animationService.currentState.eyeState
        
        ZStack {
            // Eye base
            Circle()
                .fill(Color.white)
                .frame(width: 60, height: 60)
            
            // Pupil
            Circle()
                .fill(configuration.eyeColor)
                .frame(width: 30, height: eyeHeight(for: state))
                .offset(y: eyeOffset(for: state))
            
            // Highlight
            Circle()
                .fill(Color.white.opacity(0.6))
                .frame(width: 12, height: 12)
                .offset(x: -6, y: -6)
        }
        .animation(.easeInOut(duration: 0.2 / configuration.animationSpeed), value: state)
    }
    
    private func eyeHeight(for state: EyeState) -> CGFloat {
        switch state {
        case .open:
            return 30
        case .closed, .blinking:
            return 2
        case .halfOpen:
            return 15
        }
    }
    
    private func eyeOffset(for state: EyeState) -> CGFloat {
        switch state {
        case .halfOpen:
            return 7.5
        default:
            return 0
        }
    }
    
    @ViewBuilder
    private func mouthView() -> some View {
        let state = animationService.currentState.mouthState
        
        ZStack {
            switch state {
            case .closed:
                Capsule()
                    .fill(Color.black.opacity(0.6))
                    .frame(width: 80, height: 4)
                
            case .open, .talking:
                Ellipse()
                    .fill(Color.black.opacity(0.8))
                    .frame(width: 60, height: state == .talking ? 30 : 40)
                
            case .smile:
                // Smile curve
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 10))
                    path.addQuadCurve(
                        to: CGPoint(x: 80, y: 10),
                        control: CGPoint(x: 40, y: 30)
                    )
                }
                .stroke(Color.black.opacity(0.8), lineWidth: 4)
                .frame(width: 80, height: 30)
                
            case .frown:
                // Frown curve
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 20))
                    path.addQuadCurve(
                        to: CGPoint(x: 80, y: 20),
                        control: CGPoint(x: 40, y: 0)
                    )
                }
                .stroke(Color.black.opacity(0.8), lineWidth: 4)
                .frame(width: 80, height: 30)
            }
        }
        .animation(.easeInOut(duration: 0.15 / configuration.animationSpeed), value: state)
    }
}

// MARK: - Full Screen Avatar View for Robotics

struct FullScreenAvatarView: View {
    @ObservedObject var animationService = AvatarAnimationService.shared
    @ObservedObject var configuration = AvatarConfiguration.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Black background for robotics display
            Color.black.ignoresSafeArea()
            
            // Avatar
            AvatarView()
                .padding(40)
            
            // Close button (for testing)
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .statusBar(hidden: true)
#if os(iOS)
        .onAppear {
            // Keep screen on for robotics use
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
#endif
    }
}

// MARK: - Preview

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AvatarView()
                .frame(height: 300)
                .padding()
            
            // Test buttons
            HStack {
                Button("Happy") {
                    AvatarAnimationService.shared.setEmotion(.happy)
                }
                Button("Sad") {
                    AvatarAnimationService.shared.setEmotion(.sad)
                }
                Button("Speak") {
                    AvatarAnimationService.shared.startSpeakingAnimation(text: "Hello!")
                }
                Button("Stop") {
                    AvatarAnimationService.shared.stopSpeakingAnimation()
                }
            }
        }
    }
}
