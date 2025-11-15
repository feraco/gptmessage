//
//  CameraService.swift
//  ChatGPT
//
//  Created by GitHub Copilot on 2025/11/15.
//

import Foundation
import SwiftUI
import UIKit
import AVFoundation

#if os(iOS)
/// Service for handling camera capture operations
class CameraService: NSObject, ObservableObject {
    
    @Published var capturedImage: UIImage?
    @Published var isAuthorized = false
    @Published var showCamera = false
    
    override init() {
        super.init()
        checkAuthorization()
    }
    
    // MARK: - Authorization
    
    func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
        case .notDetermined:
            requestAuthorization()
        case .denied, .restricted:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }
    }
    
    private func requestAuthorization() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
            }
        }
    }
    
    // MARK: - Image Capture
    
    func captureImage(completion: @escaping (UIImage?) -> Void) {
        guard isAuthorized else {
            completion(nil)
            return
        }
        
        showCamera = true
    }
}

/// SwiftUI wrapper for UIImagePickerController
struct CameraView: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
        }
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No update needed
    }
}
#endif
