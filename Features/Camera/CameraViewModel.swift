import Foundation
import AVFoundation
import UIKit
import Observation

@Observable
@MainActor
public final class CameraViewModel: NSObject {
    public let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "com.snaffu.camera.sessionQueue")

    public var isSessionConfigured: Bool = false
    public var isRunning: Bool = false
    public var isCapturing: Bool = false
    public var flashMode: AVCaptureDevice.FlashMode = .auto

    private var photoContinuation: CheckedContinuation<Data, Error>?

    public override init() {
        super.init()
    }

    public func configureSession() {
        guard !isSessionConfigured else { return }

        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            // Configure back camera input
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: camera) else {
                self.session.commitConfiguration()
                return
            }

            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }

            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
                self.photoOutput.maxPhotoQualityPrioritization = .balanced
            }

            self.session.commitConfiguration()

            Task { @MainActor in
                self.isSessionConfigured = true
            }
        }
    }

    public func startSession() {
        sessionQueue.async { [weak self] in
            guard let self, !self.session.isRunning else { return }
            self.session.startRunning()
            Task { @MainActor in
                self.isRunning = self.session.isRunning
            }
        }
    }

    public func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
            Task { @MainActor in
                self.isRunning = false
            }
        }
    }

    public func capturePhoto() async throws -> Data {
        isCapturing = true
        defer { isCapturing = false }

        return try await withCheckedThrowingContinuation { continuation in
            self.photoContinuation = continuation

            let settings = AVCapturePhotoSettings()
            if self.photoOutput.supportedFlashModes.contains(self.flashMode) {
                settings.flashMode = self.flashMode
            }

            self.sessionQueue.async {
                self.photoOutput.capturePhoto(with: settings, delegate: self)
            }
        }
    }

    public func toggleFlash() {
        switch flashMode {
        case .auto: flashMode = .on
        case .on:   flashMode = .off
        case .off:  flashMode = .auto
        @unknown default: flashMode = .auto
        }
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    nonisolated public func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        Task { @MainActor in
            if let error {
                self.photoContinuation?.resume(throwing: error)
                self.photoContinuation = nil
                return
            }

            guard let fileData = photo.fileDataRepresentation() else {
                self.photoContinuation?.resume(throwing: RecipeAnalysisError.invalidImageData)
                self.photoContinuation = nil
                return
            }

            self.photoContinuation?.resume(returning: fileData)
            self.photoContinuation = nil
        }
    }
}
