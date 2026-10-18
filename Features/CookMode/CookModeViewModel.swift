import Foundation
import UIKit
import Observation

@Observable
@MainActor
public final class CookModeViewModel {
    public let recipe: Recipe
    public var currentStepIndex: Int = 0

    // Timer properties
    public var remainingSeconds: Int = 0
    public var totalTimerSeconds: Int = 0
    public var isTimerRunning: Bool = false
    private var timerTask: Task<Void, Never>?

    public var currentStep: RecipeStep? {
        guard currentStepIndex >= 0 && currentStepIndex < recipe.steps.count else { return nil }
        return recipe.steps[currentStepIndex]
    }

    public var isFirstStep: Bool { currentStepIndex == 0 }
    public var isLastStep: Bool { currentStepIndex == recipe.steps.count - 1 }
    public var progress: Double {
        guard !recipe.steps.isEmpty else { return 0 }
        return Double(currentStepIndex + 1) / Double(recipe.steps.count)
    }

    public init(recipe: Recipe) {
        self.recipe = recipe
        setupStepTimer()
    }

    public func onAppear() {
        // Keep phone screen awake while user is actively cooking
        UIApplication.shared.isIdleTimerDisabled = true
    }

    public func onDisappear() {
        // Restore standard screen auto-lock when leaving cook mode
        UIApplication.shared.isIdleTimerDisabled = false
        stopTimer()
    }

    public func nextStep() {
        guard !isLastStep else { return }
        stopTimer()
        currentStepIndex += 1
        setupStepTimer()
    }

    public func previousStep() {
        guard !isFirstStep else { return }
        stopTimer()
        currentStepIndex -= 1
        setupStepTimer()
    }

    private func setupStepTimer() {
        if let durationMins = currentStep?.durationMinutes, durationMins > 0 {
            totalTimerSeconds = durationMins * 60
            remainingSeconds = totalTimerSeconds
        } else {
            totalTimerSeconds = 0
            remainingSeconds = 0
        }
    }

    public func toggleTimer() {
        if isTimerRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }

    public func startTimer() {
        guard remainingSeconds > 0 else { return }
        isTimerRunning = true

        timerTask?.cancel()
        timerTask = Task {
            while isTimerRunning && remainingSeconds > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if !Task.isCancelled && remainingSeconds > 0 {
                    remainingSeconds -= 1
                    if remainingSeconds == 0 {
                        isTimerRunning = false
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    }
                }
            }
        }
    }

    public func pauseTimer() {
        isTimerRunning = false
        timerTask?.cancel()
        timerTask = nil
    }

    public func resetTimer() {
        pauseTimer()
        setupStepTimer()
    }

    public var formattedTimer: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
