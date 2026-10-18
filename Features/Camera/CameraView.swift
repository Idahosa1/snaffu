import SwiftUI
import PhotosUI

public struct CameraView: View {
    @State private var cameraVM = CameraViewModel()
    @State private var permissionManager = PermissionManager()
    @State private var selectedPhotoItem: PhotosPickerItem?

    public let onPhotoCaptured: (Data) -> Void
    public let onDismiss: () -> Void

    public init(
        onPhotoCaptured: @escaping (Data) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.onPhotoCaptured = onPhotoCaptured
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if permissionManager.cameraStatus == .authorized {
                // Live Viewfinder
                CameraPreviewLayer(session: cameraVM.session)
                    .ignoresSafeArea()

                // Framing Overlay Guide
                VStack {
                    topControls
                    Spacer()
                    bottomControls
                }
            } else if permissionManager.cameraStatus == .denied || permissionManager.cameraStatus == .restricted {
                PermissionDeniedView(
                    permissionType: "Camera",
                    onOpenSettings: {
                        permissionManager.openAppSettings()
                    },
                    onDismiss: onDismiss
                )
            } else {
                // Permission checking / requesting phase
                ProgressView()
                    .tint(.white)
            }
        }
        .task {
            let granted = await permissionManager.requestCameraAccess()
            if granted {
                cameraVM.configureSession()
                cameraVM.startSession()
            }
        }
        .onDisappear {
            cameraVM.stopSession()
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    onPhotoCaptured(data)
                }
            }
        }
    }

    private var topControls: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.45))
                    .clipShape(Circle())
            }

            Spacer()

            Button(action: { cameraVM.toggleFlash() }) {
                Image(systemName: flashIconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.45))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private var flashIconName: String {
        switch cameraVM.flashMode {
        case .auto: return "bolt.badge.a.fill"
        case .on:   return "bolt.fill"
        case .off:  return "bolt.slash.fill"
        @unknown default: return "bolt.badge.a.fill"
        }
    }

    private var bottomControls: some View {
        HStack(alignment: .center) {
            // Photo Album Picker
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }

            Spacer()

            // Main Shutter Button
            Button(action: {
                Task {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    if let photoData = try? await cameraVM.capturePhoto() {
                        onPhotoCaptured(photoData)
                    }
                }
            }) {
                ZStack {
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 4)
                        .frame(width: 76, height: 76)

                    Circle()
                        .fill(Color(red: 1.0, green: 0.42, blue: 0.21))
                        .frame(width: 62, height: 62)
                }
            }
            .disabled(cameraVM.isCapturing)

            Spacer()

            // Spacer to balance photo picker width
            Color.clear
                .frame(width: 52, height: 52)
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 36)
    }
}
