import SwiftUI

public struct PermissionDeniedView: View {
    public let permissionType: String
    public let onOpenSettings: () -> Void
    public let onDismiss: (() -> Void)?

    public init(
        permissionType: String = "Camera",
        onOpenSettings: @escaping () -> Void,
        onDismiss: (() -> Void)? = nil
    ) {
        self.permissionType = permissionType
        self.onOpenSettings = onOpenSettings
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .frame(width: 88, height: 88)
                    .shadow(color: Color.black.opacity(0.06), radius: 10, y: 4)

                Image(systemName: "camera.fill")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(Color(red: 1.0, green: 0.42, blue: 0.21)) // Brand Tint
            }

            VStack(spacing: 8) {
                Text("\(permissionType) Access Needed")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.center)

                Text("To identify your meal and generate its recipe and steps, Snaffu needs access to your \(permissionType.lowercased()).")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 12) {
                Button(action: onOpenSettings) {
                    Text("Open Settings")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 1.0, green: 0.42, blue: 0.21))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.horizontal, 32)

                if let onDismiss {
                    Button(action: onDismiss) {
                        Text("Cancel")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.secondary)
                    }
                    .frame(height: 44)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }
}
