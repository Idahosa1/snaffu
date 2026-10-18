import Foundation
import SwiftData

@MainActor
public final class SnapRepository {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Saves a newly recognized recipe to disk
    public func save(recipe: Recipe, imageData: Data? = nil, isSaved: Bool = false) {
        let snap = SnapRecord(
            id: recipe.id,
            capturedAt: Date(),
            imageData: imageData,
            mealName: recipe.meal.name,
            mealType: recipe.meal.mealType,
            cuisine: recipe.meal.cuisine,
            confidenceScore: recipe.meal.confidenceScore,
            prepTimeMinutes: recipe.prepTimeMinutes,
            cookTimeMinutes: recipe.cookTimeMinutes,
            baseServings: recipe.baseServings,
            difficulty: recipe.difficulty,
            isSaved: isSaved
        )

        for (index, ing) in recipe.ingredients.enumerated() {
            let ingRecord = IngredientRecord(
                id: ing.id,
                name: ing.name,
                amount: ing.amount,
                unit: ing.unit,
                emoji: ing.emoji,
                orderIndex: index,
                snap: snap
            )
            snap.ingredients.append(ingRecord)
        }

        for step in recipe.steps {
            let stepRecord = StepRecord(
                id: step.id,
                stepNumber: step.stepNumber,
                instruction: step.instruction,
                durationMinutes: step.durationMinutes,
                snap: snap
            )
            snap.steps.append(stepRecord)
        }

        modelContext.insert(snap)
        try? modelContext.save()
    }

    /// Fetches all historical snaps sorted newest first
    public func fetchAllSnaps() -> [Recipe] {
        var descriptor = FetchDescriptor<SnapRecord>(sortBy: [SortDescriptor(\.capturedAt, order: .reverse)])
        let records = (try? modelContext.fetch(descriptor)) ?? []
        return records.map { $0.toRecipe() }
    }

    /// Fetches only bookmarked / saved recipes
    public func fetchSavedRecipes() -> [Recipe] {
        var descriptor = FetchDescriptor<SnapRecord>(
            predicate: #Predicate { $0.isSaved == true },
            sortBy: [SortDescriptor(\.capturedAt, order: .reverse)]
        )
        let records = (try? modelContext.fetch(descriptor)) ?? []
        return records.map { $0.toRecipe() }
    }

    /// Toggles the bookmark status of a recipe
    public func toggleSave(for recipeId: UUID) {
        let predicate = #Predicate<SnapRecord> { $0.id == recipeId }
        var descriptor = FetchDescriptor<SnapRecord>(predicate: predicate)

        if let record = (try? modelContext.fetch(descriptor))?.first {
            record.isSaved.toggle()
            try? modelContext.save()
        }
    }

    /// Deletes a snap record
    public func delete(recipeId: UUID) {
        let predicate = #Predicate<SnapRecord> { $0.id == recipeId }
        var descriptor = FetchDescriptor<SnapRecord>(predicate: predicate)

        if let record = (try? modelContext.fetch(descriptor))?.first {
            modelContext.delete(record)
            try? modelContext.save()
        }
    }
}
