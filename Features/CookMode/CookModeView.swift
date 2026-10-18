import SwiftUI

public struct CookModeView: View {
    @State private var viewModel: CookModeViewModel
    public let onDismiss: () -> Void

    public init(recipe: Recipe, onDismiss: @escaping () -> Void) {
        _viewModel = State(initialValue: CookModeViewModel(recipe: recipe))
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Navigation & Progress Header
                topHeader

                Spacer()

                // Main Step Card
                if let step = viewModel.currentStep {
                    stepCard(step: step)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.98)),
                            removal: .opacity.combined(with: .scale(scale: 1.02))
                        ))
                        .id(viewModel.currentStepIndex)
                }

                Spacer()

                // Bottom Action Bar
                bottomActionBar
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
    }

    private var topHeader: some View {
        VStack(spacing: 14) {
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.primary)
                        .frame(width: 40, height: 40)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(Circle())
                }

                Spacer()

                VStack(spacing: 2) {
                    Text(viewModel.recipe.meal.name)
                        .font(.system(size: 15, weight: .semibold))
                        .lineLimit(1)

                    Text("Step \(viewModel.currentStepIndex + 1) of \(viewModel.recipe.steps.count)")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.secondary)
                }

                Spacer()

                // Balance layout with an invisible spacer matching the close button
                Color.clear
                    .frame(width: 40, height: 40)
            }

            // Continuous Progress Bar
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(uiColor: .tertiarySystemFill))
                        .frame(height: 6)

                    Capsule()
                        .fill(Color(red: 1.0, green: 0.42, blue: 0.21))
                        .frame(width: proxy.size.width * viewModel.progress, height: 6)
                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.progress)
                }
            }
            .frame(height: 6)
        }
        .padding(.top, 8)
    }

    private func stepCard(step: RecipeStep) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            // Step Number Badge
            HStack {
                Text("STEP \(step.stepNumber)")
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(Color(red: 1.0, green: 0.42, blue: 0.21))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(red: 1.0, green: 0.42, blue: 0.21).opacity(0.12))
                    .clipShape(Capsule())

                Spacer()

                if let mins = step.durationMinutes {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text("\(mins) min")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.secondary)
                }
            }

            // Big High-Legibility Instruction Text
            Text(step.instruction)
                .font(.system(size: 22, weight: .medium))
                .lineSpacing(6)
                .foregroundStyle(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .minimumScaleFactor(0.8)

            // Integrated Countdown Timer if duration exists
            if viewModel.totalTimerSeconds > 0 {
                stepTimerBox
            }
        }
        .padding(26)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 12, y: 4)
    }

    private var stepTimerBox: some View {
        HStack(spacing: 16) {
            Image(systemName: "timer")
                .font(.system(size: 28))
                .foregroundStyle(Color(red: 1.0, green: 0.42, blue: 0.21))

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.formattedTimer)
                    .font(.system(size: 26, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(Color.primary)

                Text(viewModel.isTimerRunning ? "Timer Running" : "Tap play to start timer")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)
            }

            Spacer()

            HStack(spacing: 10) {
                // Play / Pause Button
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    viewModel.toggleTimer()
                }) {
                    Image(systemName: viewModel.isTimerRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Color(red: 1.0, green: 0.42, blue: 0.21))
                        .clipShape(Circle())
                }

                // Reset Button
                if viewModel.remainingSeconds != viewModel.totalTimerSeconds {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        viewModel.resetTimer()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.secondary)
                            .frame(width: 36, height: 36)
                            .background(Color(uiColor: .tertiarySystemFill))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var bottomActionBar: some View {
        HStack(spacing: 14) {
            // Previous Button
            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    viewModel.previousStep()
                }
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(viewModel.isFirstStep ? Color.secondary.opacity(0.3) : Color.primary)
                    .frame(width: 56, height: 56)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(Circle())
            }
            .disabled(viewModel.isFirstStep)

            // Primary Next / Finish Button
            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                if viewModel.isLastStep {
                    onDismiss()
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        viewModel.nextStep()
                    }
                }
            }) {
                HStack(spacing: 8) {
                    Text(viewModel.isLastStep ? "Finish Cooking 🎉" : "Next Step")
                        .font(.system(size: 17, weight: .semibold))

                    if !viewModel.isLastStep {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .semibold))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(red: 1.0, green: 0.42, blue: 0.21))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .padding(.bottom, 12)
    }
}
