//
//  DialogueSession+Vision.swift
//  ChatGPT
//
//  Created by GitHub Copilot on 2025/11/15.
//

import Foundation
import UIKit

extension DialogueSession {
    
    /// Processes vision-related commands and integrates with conversation
    @MainActor
    func processVisionCommand(_ input: String, scroll: ((UnitPoint) -> Void)? = nil) async {
        let visionManager = VisionInteractionManager.shared
        let visionConfig = VisionConfiguration.shared
        
        guard visionConfig.isVisionEnabled else {
            // If vision is disabled but user asks vision question, inform them
            if visionManager.shouldTriggerVision(for: input) {
                await appendVisionResponse("Vision features are currently disabled. You can enable them in Settings > Vision Features.")
                return
            }
            return
        }
        
        // Check if this is a vision trigger
        guard visionManager.shouldTriggerVision(for: input) else {
            return
        }
        
#if os(iOS)
        // Request camera capture
        let cameraService = CameraService()
        cameraService.checkAuthorization()
        
        guard cameraService.isAuthorized else {
            await appendVisionResponse("Camera permission is required for vision features. Please grant camera access in Settings.")
            return
        }
        
        // For now, inform user to use camera button
        await appendVisionResponse("Please capture an image using the camera button, then ask your question again.")
#endif
    }
    
    /// Processes an image with vision and generates response
    @MainActor
    func processImageWithVision(_ image: UIImage, prompt: String) async -> String {
        let visionManager = VisionInteractionManager.shared
        let visionConfig = VisionConfiguration.shared
        
        guard visionConfig.isVisionEnabled else {
            return "Vision features are currently disabled."
        }
        
        do {
            // Check if this is an introduction
            if let name = visionManager.detectsIntroduction(in: prompt) {
                return try await visionManager.associateFaceWithName(name)
            }
            
            // Otherwise, process the image normally
            return try await visionManager.processImage(image, withPrompt: prompt)
        } catch {
            return "I encountered an error processing the image: \(error.localizedDescription)"
        }
    }
    
    /// Appends a vision-generated response to conversation
    @MainActor
    private func appendVisionResponse(_ response: String) async {
        var conversation = Conversation(
            isReplying: false,
            isLast: true,
            input: "[Vision Query]",
            reply: response,
            errorDesc: nil)
        
        if conversations.count > 0 {
            conversations[conversations.endIndex-1].isLast = false
        }
        
        withAnimation(.easeInOut(duration: 0.25)) {
            appendConversation(conversation)
        }
    }
}
