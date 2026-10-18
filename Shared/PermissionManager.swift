import Foundation
import AVFoundation
import Photos
import UIKit
import Observation

public enum CameraAccessStatus: Sendable {
    case notDetermined
    case authorized
    case denied
    case restricted
}

public enum PhotoLibraryAccessStatus: Sendable {
    case notDetermined
    case authorized
    case limited
    case denied
    case restricted
}

@Observable
@MainActor
public final class PermissionManager {
    public var cameraStatus: CameraAccessStatus = .notDetermined
    public var photoLibraryStatus: PhotoLibraryAccessStatus = .notDetermined

    public init() {
        checkCurrentStatus()
    }

    public func checkCurrentStatus() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraStatus = .authorized
        case .notDetermined:
            cameraStatus = .notDetermined
        case .denied:
            cameraStatus = .denied
        case .restricted:
            cameraStatus = .restricted
        @unknown default:
            cameraStatus = .denied
        }

        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized:
            photoLibraryStatus = .authorized
        case .limited:
            photoLibraryStatus = .limited
        case .notDetermined:
            photoLibraryStatus = .notDetermined
        case .denied:
            photoLibraryStatus = .denied
        case .restricted:
            photoLibraryStatus = .restricted
        @unknown default:
            photoLibraryStatus = .denied
        }
    }

    /// Requests camera permission only at the point of need (when user taps the Snap button)
    public func requestCameraAccess() async -> Bool {
        let current = AVCaptureDevice.authorizationStatus(for: .video)
        if current == .authorized {
            cameraStatus = .authorized
            return true
        }

        if current == .notDetermined {
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            cameraStatus = granted ? .authorized : .denied
            return granted
        }

        cameraStatus = (current == .denied) ? .denied : .restricted
        return false
    }

    /// Requests photo library access when user chooses to select from albums
    public func requestPhotoLibraryAccess() async -> Bool {
        let current = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if current == .authorized || current == .limited {
            photoLibraryStatus = (current == .authorized) ? .authorized : .limited
            return true
        }

        if current == .notDetermined {
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            switch status {
            case .authorized:
                photoLibraryStatus = .authorized
                return true
            case .limited:
                photoLibraryStatus = .limited
                return true
            default:
                photoLibraryStatus = .denied
                return false
            }
        }

        photoLibraryStatus = (current == .denied) ? .denied : .restricted
        return false
    }

    /// Deep links directly to Snaffu's app settings in iOS Settings app
    public func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsURL) else {
            return
        }
        UIApplication.shared.open(settingsURL)
    }
}
