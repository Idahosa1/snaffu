import SwiftUI
import SwiftData

@main
struct SnaffuApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showingSplash: Bool = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showingSplash {
                    SplashScreenView {
                        showingSplash = false
                    }
                    .transition(.opacity)
                } else if !hasCompletedOnboarding {
                    OnboardingView {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            hasCompletedOnboarding = true
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                } else {
                    MainTabView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.35), value: showingSplash)
            .animation(.easeInOut(duration: 0.35), value: hasCompletedOnboarding)
        }
        .modelContainer(for: SnapRecord.self)
    }
}
