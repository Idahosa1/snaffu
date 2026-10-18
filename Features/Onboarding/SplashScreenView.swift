import SwiftUI

public struct SplashScreenView: View {
    @State private var isAnimating: Bool = false
    public var onFinished: () -> Void

    public init(onFinished: @escaping () -> Void = {}) {
        self.onFinished = onFinished
    }

    public var body: some View {
        ZStack {
            // Primary Color Background
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.27, blue: 0.23), // #FF453A
                    Color(red: 1.0, green: 0.18, blue: 0.33)  // #FF2D55
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Wordmark Only (Pure White on Primary Gradient)
            Text("snaffu")
                .font(.system(size: 58, weight: .bold, design: .rounded))
                .tracking(-2.2)
                .foregroundStyle(.white)
                .scaleEffect(isAnimating ? 1.0 : 0.94)
                .opacity(isAnimating ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAnimating = true
            }

            // Transition to onboarding / main app after 1.4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    onFinished()
                }
            }
        }
    }
}
