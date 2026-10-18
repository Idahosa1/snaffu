import SwiftUI

public struct OnboardingStep: Identifiable {
    public let id: Int
    public let category: String
    public let title: String
    public let description: String
    public let imageName: String
    public let badgeText: String
}

public struct OnboardingView: View {
    @State private var currentStep: Int = 0
    public var onComplete: () -> Void

    private let steps: [OnboardingStep] = [
        OnboardingStep(
            id: 0,
            category: "Point & Discover",
            title: "Snap Any Meal",
            description: "See a dish you love at a restaurant, on social media, or at home? Point your camera and snap it in a second.",
            imageName: "camera.viewfinder",
            badgeText: "Instant Detection"
        ),
        OnboardingStep(
            id: 1,
            category: "AI Vision Engine",
            title: "Get Instant Recipes",
            description: "Snaffu deconstructs every dish into exact measured ingredients, secret seasonings, and estimated prep times.",
            imageName: "sparkles",
            badgeText: "Ingredient Breakdown"
        ),
        OnboardingStep(
            id: 2,
            category: "Guided Kitchen Mode",
            title: "Cook with Precision",
            description: "Follow hands-free, distraction-free guided steps with built-in timers calibrated specifically for each step.",
            imageName: "timer",
            badgeText: "Hands-Free Mode"
        )
    ]

    public init(onComplete: @escaping () -> Void = {}) {
        self.onComplete = onComplete
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar with Logo and Skip Button
            HStack {
                HStack(spacing: 2) {
                    Text("snaf")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.primary)
                    Text("fu")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color(red: 1.0, green: 0.23, blue: 0.19))
                }

                Spacer()

                Button("Skip") {
                    onComplete()
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 8)

            // Step Carousel Content
            TabView(selection: $currentStep) {
                ForEach(steps) { step in
                    VStack(spacing: 20) {
                        // Visual Card Frame
                        visualCard(for: step)
                            .frame(maxWidth: .infinity)
                            .frame(height: 320)
                            .padding(.horizontal, 24)
                            .padding(.top, 8)

                        // Typographic Content
                        VStack(alignment: .leading, spacing: 10) {
                            Text(step.title)
                                .font(.system(size: 28, weight: .bold, design: .default))
                                .foregroundStyle(Color.primary)
                                .tracking(-0.6)

                            Text(step.description)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(Color.secondary)
                                .lineSpacing(3)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)

                        Spacer()
                    }
                    .tag(step.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Bottom Navigation: Indicator Dots + CTA Button
            VStack(spacing: 18) {
                // Smooth Capsule Dots Indicator
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentStep ? Color(red: 1.0, green: 0.23, blue: 0.19) : Color.secondary.opacity(0.25))
                            .frame(width: index == currentStep ? 26 : 8, height: 8)
                            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: currentStep)
                            .onTapGesture {
                                currentStep = index
                            }
                    }
                }

                // Primary CTA Button
                Button(action: {
                    if currentStep < steps.count - 1 {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            currentStep += 1
                        }
                    } else {
                        onComplete()
                    }
                }) {
                    HStack(spacing: 8) {
                        Text(currentStep == steps.count - 1 ? "Get Started" : "Continue")
                            .font(.system(size: 16, weight: .semibold))

                        Image(systemName: currentStep == steps.count - 1 ? "sparkles" : "arrow.right")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.27, blue: 0.23), Color(red: 1.0, green: 0.18, blue: 0.33)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }

    @ViewBuilder
    private func visualCard(for step: OnboardingStep) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 24, y: 8)

            if step.id == 0 {
                // Card 1: Camera viewfinder framing
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(Color(red: 1.0, green: 0.23, blue: 0.19), style: StrokeStyle(lineWidth: 2.5, dash: [8]))
                            .frame(width: 170, height: 170)

                        Image(systemName: "fork.knife.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(Color(red: 1.0, green: 0.23, blue: 0.19).opacity(0.85))
                    }

                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.23, blue: 0.19))
                            .frame(width: 8, height: 8)
                        Text("Detecting dish in real-time…")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.secondary)
                    }
                    .padding(.top, 4)
                }
            } else if step.id == 1 {
                // Card 2: AI Recipe Ingredient Breakdown
                VStack(spacing: 10) {
                    ingredientPill(title: "Fresh Farm Eggs", amount: "4 large")
                    ingredientPill(title: "San Marzano Tomatoes", amount: "400g crushed")
                    ingredientPill(title: "Smoked Paprika & Cumin", amount: "1 tsp each")

                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(Color(red: 1.0, green: 0.23, blue: 0.19))
                        Text("Deconstructed in 1.2s")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)
            } else {
                // Card 3: Cook Mode Step Preview
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("STEP 2 OF 5")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(red: 1.0, green: 0.23, blue: 0.19))
                            .tracking(0.8)

                        Spacer()

                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color(red: 1.0, green: 0.23, blue: 0.19))
                            Text("08:45")
                                .font(.system(size: 14, weight: .bold))
                                .monospacedDigit()
                        }
                    }

                    Text("Simmer tomatoes and bell peppers on medium heat until fragrant and slightly reduced.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.primary)
                        .lineSpacing(2)

                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.green)
                        Text("Timer active")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.secondary)
                    }
                }
                .padding(20)
                .background(Color(UIColor.tertiarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, 16)
            }
        }
    }

    private func ingredientPill(title: String, amount: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.primary)
            Spacer()
            Text(amount)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(red: 1.0, green: 0.23, blue: 0.19))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
