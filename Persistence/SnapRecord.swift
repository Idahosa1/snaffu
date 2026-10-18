import Foundation
import SwiftData

@Model
public final class SnapRecord {
    @Attribute(.unique) public var id: UUID
    public var capturedAt: Date
    public var imageData: Data?
    public var mealName: String
    public var mealTypeRaw: String
    public var cuisine: String
    public var confidenceScore: Double
    public var prepTimeMinutes: Int
    public var cookTimeMinutes: Int
    public var baseServings: Int
    public var difficultyRaw: String
    public var isSaved: Bool

    @Relationship(deleteRule: .cascade, inverse: \IngredientRecord.snap)
    public var ingredients: [IngredientRecord] = []

    @Relationship(deleteRule: .cascade, inverse: \StepRecord.snap)
    public var steps: [StepRecord] = []

    public var mealType: MealType {
        MealType(rawValue: mealTypeRaw) ?? .dinner
    }

    public var difficulty: RecipeDifficulty {
        RecipeDifficulty(rawValue: difficultyRaw) ?? .easy
    }

    public init(
        id: UUID = UUID(),
        capturedAt: Date = Date(),
        imageData: Data? = nil,
        mealName: String,
        mealType: MealType,
        cuisine: String = "General",
        confidenceScore: Double = 0.95,
        prepTimeMinutes: Int = 15,
        cookTimeMinutes: Int = 15,
        baseServings: Int = 2,
        difficulty: RecipeDifficulty = .medium,
        isSaved: Bool = false
    ) {
        self.id = id
        self.capturedAt = capturedAt
        self.imageData = imageData
        self.mealName = mealName
        self.mealTypeRaw = mealType.rawValue
        self.cuisine = cuisine
        self.confidenceScore = confidenceScore
        self.prepTimeMinutes = prepTimeMinutes
        self.cookTimeMinutes = cookTimeMinutes
        self.baseServings = baseServings
        self.difficultyRaw = difficulty.rawValue
        self.isSaved = isSaved
    }

    /// Converts persisted SwiftData record back to standard Domain Recipe
    public func toRecipe() -> Recipe {
        Recipe(
            id: id,
            meal: MealIdentification(
                id: id,
                name: mealName,
                mealType: mealType,
                cuisine: cuisine,
                confidenceScore: confidenceScore
            ),
            prepTimeMinutes: prepTimeMinutes,
            cookTimeMinutes: cookTimeMinutes,
            baseServings: baseServings,
            difficulty: difficulty,
            ingredients: ingredients.sorted(by: { $0.orderIndex < $1.orderIndex }).map { $0.toDomain() },
            steps: steps.sorted(by: { $0.stepNumber < $1.stepNumber }).map { $0.toDomain() }
        )
    }
}

@Model
public final class IngredientRecord {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var amount: Double
    public var unit: String
    public var emoji: String
    public var orderIndex: Int
    public var snap: SnapRecord?

    public init(
        id: UUID = UUID(),
        name: String,
        amount: Double,
        unit: String,
        emoji: String,
        orderIndex: Int = 0,
        snap: SnapRecord? = nil
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
        self.emoji = emoji
        self.orderIndex = orderIndex
        self.snap = snap
    }

    public func toDomain() -> Ingredient {
        Ingredient(id: id, name: name, amount: amount, unit: unit, emoji: emoji)
    }
}

@Model
public final class StepRecord {
    @Attribute(.unique) public var id: UUID
    public var stepNumber: Int
    public var instruction: String
    public var durationMinutes: Int?
    public var snap: SnapRecord?

    public init(
        id: UUID = UUID(),
        stepNumber: Int,
        instruction: String,
        durationMinutes: Int? = nil,
        snap: SnapRecord? = nil
    ) {
        self.id = id
        self.stepNumber = stepNumber
        self.instruction = instruction
        self.durationMinutes = durationMinutes
        self.snap = snap
    }

    public func toDomain() -> RecipeStep {
        RecipeStep(id: id, stepNumber: stepNumber, instruction: instruction, durationMinutes: durationMinutes)
    }
}
