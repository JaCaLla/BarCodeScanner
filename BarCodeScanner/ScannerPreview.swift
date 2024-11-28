//
//  ScannerPreview.swift
//  BarCodeScanner
//
//  Created by Javier Calatrava on 28/11/24.
//
import SwiftUI
import AVFoundation

// 1
struct ScannerPreview: UIViewControllerRepresentable {
    @Binding var isScanning: Bool
    var didFindBarcode: (String) -> Void = { _ in }
    // 2
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    // 3
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let captureSession = AVCaptureSession()

        // Setup the camera input
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return viewController }
        let videoDeviceInput: AVCaptureDeviceInput

        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return viewController
        }

        if (captureSession.canAddInput(videoDeviceInput)) {
            captureSession.addInput(videoDeviceInput)
        } else {
            return viewController
        }

        // Setup the metadata output
        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean13, .ean8, .pdf417, .upce, .qr, .aztec] // Add other types if needed
        } else {
            return viewController
        }

        // Setup preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)

        captureSession.startRunning()

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Here we can update the UI if needed (for example, stopping the session)
    }
    
    //1
    @MainActor
    class Coordinator: NSObject, @preconcurrency AVCaptureMetadataOutputObjectsDelegate {
        var parent: ScannerPreview
        
        init(parent: ScannerPreview) {
            self.parent = parent
        }
        // 2
        // MARK :- AVCaptureMetadataOutputObjectsDelegate
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            // 4
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.parent.isScanning = false
                // 3
                parent.didFindBarcode(String(stringValue))
            }
        }
    }
}
