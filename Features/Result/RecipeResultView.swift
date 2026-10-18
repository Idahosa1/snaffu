import SwiftUI

public struct RecipeResultView: View {
    public let recipe: Recipe
    public let mealImageData: Data?
    public var isSaved: Bool
    public let onToggleSave: (() -> Void)?
    public let onDismiss: () -> Void

    @State private var servingMultiplier: Double = 1.0
    @State private var checkedIngredients: Set<UUID> = []
    @State private var showingCookMode: Bool = false

    public init(
        recipe: Recipe,
        mealImageData: Data? = nil,
        isSaved: Bool = false,
        onToggleSave: (() -> Void)? = nil,
        onDismiss: @escaping () -> Void
    ) {
        self.recipe = recipe
        self.mealImageData = mealImageData
        self.isSaved = isSaved
        self.onToggleSave = onToggleSave
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    servingsAdjuster
                    ingredientsSection
                    cookingStepsSection
                    startCookModeButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done", action: onDismiss)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(red: 1.0, green: 0.42, blue: 0.21))
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    if let onToggleSave {
                        Button(action: onToggleSave) {
                            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                .foregroundStyle(Color(red: 1.0, green: 0.42, blue: 0.21))
                        }
                    }

                    ShareLink(
                        item: shareableText,
                        preview: SharePreview(recipe.meal.name, icon: Image(systemName: "fork.knife"))
                    ) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(Color(red: 1.0, green: 0.42, blue: 0.21))
                    }
                }
            }
            .fullScreenCover(isPresented: $showingCookMode) {
                CookModeView(recipe: recipe) {
                    showingCookMode = false
                }
            }
        }
    }

    private var startCookModeButton: some View {
        Button(action: { showingCookMode = true }) {
            HStack(spacing: 10) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                Text("Start Cooking")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.35, blue: 0.12), Color(red: 1.0, green: 0.22, blue: 0.30)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(recipe.meal.mealType.rawValue.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1.0)
                    .foregroundStyle(Color(red: 1.0, green: 0.35, blue: 0.12))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(red: 1.0, green: 0.35, blue: 0.12).opacity(0.12))
                    .clipShape(Capsule())

                Spacer()

                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("\(Int(recipe.meal.confidenceScore * 100))% match")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(uiColor: .tertiarySystemFill))
                .clipShape(Capsule())
            }

            Text(recipe.meal.name)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Color.primary)

            HStack(spacing: 16) {
                Label("\(recipe.totalTimeMinutes) min", systemImage: "clock")
                Label("\(recipe.difficulty.rawValue)", systemImage: "flame")
                Label("\(Int(Double(recipe.baseServings) * servingMultiplier)) servings", systemImage: "person.2")
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Color.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var servingsAdjuster: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Adjust Servings")
                    .font(.system(size: 15, weight: .medium))
                Text("Quantities adjust automatically")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)
            }

            Spacer()

            HStack(spacing: 14) {
                Button(action: {
                    if servingMultiplier > 0.5 { servingMultiplier -= 0.5 }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(servingMultiplier > 0.5 ? Color(red: 1.0, green: 0.42, blue: 0.21) : Color.gray.opacity(0.3))
                }
                .disabled(servingMultiplier <= 0.5)

                Text("\(Int(Double(recipe.baseServings) * servingMultiplier))")
                    .font(.system(size: 18, weight: .semibold))
                    .monospacedDigit()
                    .frame(minWidth: 24)

                Button(action: {
                    if servingMultiplier < 4.0 { servingMultiplier += 0.5 }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Color(red: 1.0, green: 0.42, blue: 0.21))
                }
            }
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.primary)

            VStack(spacing: 0) {
                ForEach(recipe.ingredients) { item in
                    let isChecked = checkedIngredients.contains(item.id)

                    HStack(spacing: 12) {
                        Button(action: {
                            if isChecked {
                                checkedIngredients.remove(item.id)
                            } else {
                                checkedIngredients.insert(item.id)
                            }
                        }) {
                            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                                .foregroundStyle(isChecked ? Color.green : Color.secondary.opacity(0.5))
                        }

                        Text(item.emoji)
                            .font(.system(size: 18))

                        Text(item.name)
                            .font(.system(size: 15))
                            .strikethrough(isChecked, color: .secondary)
                            .foregroundStyle(isChecked ? Color.secondary : Color.primary)

                        Spacer()

                        Text(item.formattedAmount(multiplier: servingMultiplier))
                            .font(.system(size: 14, weight: .medium))
                            .monospacedDigit()
                            .foregroundStyle(Color.secondary)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)

                    if item.id != recipe.ingredients.last?.id {
                        Divider()
                            .padding(.leading, 46)
                    }
                }
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var cookingStepsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preparation & Cooking")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.primary)

            VStack(spacing: 14) {
                ForEach(recipe.steps) { step in
                    HStack(alignment: .top, spacing: 14) {
                        Text("\(step.stepNumber)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 26, height: 26)
                            .background(Color(red: 1.0, green: 0.42, blue: 0.21))
                            .clipShape(Circle())
                            .padding(.top, 2)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(step.instruction)
                                .font(.system(size: 15))
                                .foregroundStyle(Color.primary)
                                .lineSpacing(3)

                            if let duration = step.durationMinutes {
                                HStack(spacing: 4) {
                                    Image(systemName: "timer")
                                    Text("\(duration) min")
                                }
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color(red: 1.0, green: 0.42, blue: 0.21))
                            }
                        }

                        Spacer()
                    }
                    .padding(14)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
    }

    private var shareableText: String {
        var text = "\(recipe.meal.name) (\(recipe.meal.mealType.rawValue))\n\n"
        text += "Ingredients (\(Int(Double(recipe.baseServings) * servingMultiplier)) servings):\n"
        for ing in recipe.ingredients {
            text += "- \(ing.formattedAmount(multiplier: servingMultiplier)) \(ing.name)\n"
        }
        text += "\nSteps:\n"
        for step in recipe.steps {
            text += "\(step.stepNumber). \(step.instruction)\n"
        }
        text += "\nGenerated with Snaffu."
        return text
    }
}
