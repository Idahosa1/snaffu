import SwiftUI

public struct ProfileView: View {
    public let snapCount: Int
    public let savedCount: Int

    @Environment(\.dismiss) private var dismiss

    @AppStorage("chefName") private var chefName: String = "Chef Guest"
    @AppStorage("chefBio") private var chefBio: String = "Home Cook · Snaffu Member"
    @AppStorage("selectedAvatarEmoji") private var selectedAvatarEmoji: String = "👩‍🍳"
    @AppStorage("dietaryPreference") private var dietaryPreference: String = "None"
    @AppStorage("measurementSystem") private var measurementSystem: String = "Metric (g, ml)"
    @AppStorage("pushNotifications") private var pushNotifications: Bool = true
    @AppStorage("hapticFeedback") private var hapticFeedback: Bool = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = true

    @State private var showingAvatarPicker: Bool = false
    @State private var showingLogoutAlert: Bool = false
    @State private var showingDeleteAlert: Bool = false
    @State private var showingEditProfileSheet: Bool = false
    @State private var draftName: String = ""
    @State private var draftBio: String = ""

    public init(snapCount: Int = 5, savedCount: Int = 2) {
        self.snapCount = snapCount
        self.savedCount = savedCount
    }

    public var body: some View {
        NavigationStack {
            List {
                // 1. User Info Section with Clean Typography & Edit CTA
                Section {
                    HStack(spacing: 16) {
                        Button(action: { showingAvatarPicker = true }) {
                            ZStack(alignment: .bottomTrailing) {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(red: 1.0, green: 0.42, blue: 0.21), Color(red: 1.0, green: 0.6, blue: 0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 64, height: 64)

                                Text(selectedAvatarEmoji)
                                    .font(.system(size: 32))

                                // Camera Edit Badge
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 1.0, green: 0.35, blue: 0.12))
                                        .frame(width: 24, height: 24)
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                                .offset(x: 4, y: 4)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Change avatar photo")

                        VStack(alignment: .leading, spacing: 4) {
                            Text(chefName)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.primary)
                                .lineLimit(1)

                            Text(chefBio)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(Color.secondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        // Working Edit CTA Button
                        Button(action: {
                            draftName = chefName
                            draftBio = chefBio
                            showingEditProfileSheet = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 11, weight: .semibold))
                                Text("Edit")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(red: 1.0, green: 0.35, blue: 0.12).opacity(0.12))
                            .foregroundStyle(Color(red: 1.0, green: 0.35, blue: 0.12))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Profile Info")
                } footer: {
                    Text("Tap avatar to change icon, or tap Edit to update your name and bio.")
                        .font(.system(size: 12))
                }

                // 2. Stats Section
                Section("Activity") {
                    HStack {
                        statItem(label: "Meals Snapped", count: "\(snapCount)", icon: "camera.fill")
                        Divider()
                        statItem(label: "Saved Recipes", count: "\(savedCount)", icon: "bookmark.fill")
                    }
                    .padding(.vertical, 4)
                }

                // 3. Cooking Preferences
                Section("Preferences") {
                    Picker("Dietary Preference", selection: $dietaryPreference) {
                        Text("None / Everything").tag("None")
                        Text("Vegetarian").tag("Vegetarian")
                        Text("Vegan").tag("Vegan")
                        Text("Gluten-Free").tag("Gluten-Free")
                        Text("Dairy-Free").tag("Dairy-Free")
                        Text("Pescatarian").tag("Pescatarian")
                        Text("Keto").tag("Keto")
                    }

                    Picker("Measurement Units", selection: $measurementSystem) {
                        Text("Metric (g, ml)").tag("Metric (g, ml)")
                        Text("Imperial (oz, cups)").tag("Imperial (oz, cups)")
                        Text("US Customary").tag("US Customary")
                    }

                    Toggle("Push Notifications", isOn: $pushNotifications)

                    Toggle("Haptic Feedback on Snap", isOn: $hapticFeedback)
                }

                // 4. Support & About
                Section("Support & About") {
                    Link(destination: URL(string: "mailto:support@snaffu.app?subject=Snaffu%20Support")!) {
                        HStack {
                            Text("Contact & Support")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.primary)
                            Spacer()
                            Text("support@snaffu.app")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(Color.secondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.secondary.opacity(0.4))
                        }
                    }

                    HStack {
                        Text("Recognition Engine")
                            .font(.system(size: 15, weight: .medium))
                        Spacer()
                        Text("Local Recipe Engine")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.green)
                    }

                    HStack {
                        Text("App Version")
                            .font(.system(size: 15, weight: .medium))
                        Spacer()
                        Text("Snaffu 1.0.0 (v1 Offline)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.secondary)
                    }
                    // Version is intentionally a static row without button/tap actions
                }

                // 5. Account Actions
                Section("Account") {
                    Button(action: { showingLogoutAlert = true }) {
                        HStack {
                            Text("Log Out")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color(red: 1.0, green: 0.35, blue: 0.12))
                            Spacer()
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color(red: 1.0, green: 0.35, blue: 0.12))
                        }
                    }

                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        HStack {
                            Text("Delete Account")
                                .font(.system(size: 15, weight: .semibold))
                            Spacer()
                            Image(systemName: "trash")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundStyle(Color(red: 1.0, green: 0.35, blue: 0.12))
                    }
                }
            }
            .confirmationDialog("Choose Avatar", isPresented: $showingAvatarPicker) {
                Button("👩‍🍳 Chef Woman") { selectedAvatarEmoji = "👩‍🍳" }
                Button("👨‍🍳 Chef Man") { selectedAvatarEmoji = "👨‍🍳" }
                Button("🍳 Gourmet Pan") { selectedAvatarEmoji = "🍳" }
                Button("🥑 Avocado") { selectedAvatarEmoji = "🥑" }
                Button("🥗 Healthy Bowl") { selectedAvatarEmoji = "🥗" }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) { dismiss() }
            } message: {
                Text("Are you sure you want to log out of Snaffu?")
            }
            .alert("Delete Account", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete Account", role: .destructive) {
                    hasCompletedOnboarding = false
                    dismiss()
                }
            } message: {
                Text("Warning: Deleting your account will permanently remove all your saved recipes and meal history. This action cannot be undone.")
            }
            .sheet(isPresented: $showingEditProfileSheet) {
                NavigationStack {
                    Form {
                        Section {
                            TextField("Your Name", text: $draftName)
                                .font(.system(size: 16))
                        } header: {
                            Text("Name")
                        } footer: {
                            Text("This name appears in your home screen greeting.")
                                .font(.system(size: 12))
                        }

                        Section {
                            TextField("Tell us about yourself or cooking style", text: $draftBio, axis: .vertical)
                                .font(.system(size: 15))
                                .lineLimit(3...5)
                        } header: {
                            Text("Bio / Status")
                        }

                        Section {
                            Button(action: {
                                let trimmedName = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
                                let trimmedBio = draftBio.trimmingCharacters(in: .whitespacesAndNewlines)
                                chefName = trimmedName.isEmpty ? "Chef Guest" : trimmedName
                                chefBio = trimmedBio.isEmpty ? "Home Cook · Snaffu Member" : trimmedBio
                                showingEditProfileSheet = false
                            }) {
                                HStack {
                                    Spacer()
                                    Text("Save Changes")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.white)
                                    Spacer()
                                }
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        colors: [Color(red: 1.0, green: 0.27, blue: 0.23), Color(red: 1.0, green: 0.18, blue: 0.33)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        }
                    }
                    .navigationTitle("Edit Profile")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingEditProfileSheet = false
                            }
                            .foregroundStyle(Color(red: 1.0, green: 0.35, blue: 0.12))
                        }
                    }
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private func statItem(label: String, count: String, icon: String) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 1.0, green: 0.42, blue: 0.21))
                Text(count)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .monospacedDigit()
            }

            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
