import Foundation

public enum MealType: String, Sendable, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case dessert = "Dessert"
    case appetizer = "Appetizer"
    case snack = "Snack"

    public var id: String { rawValue }

    public var emoji: String {
        switch self {
        case .breakfast: return "🥞"
        case .lunch:     return "🥗"
        case .dinner:    return "🍲"
        case .dessert:   return "🧁"
        case .appetizer: return "🥟"
        case .snack:     return "🥨"
        }
    }
}

public struct MealIdentification: Sendable, Hashable, Identifiable {
    public let id: UUID
    public let name: String
    public let mealType: MealType
    public let cuisine: String
    public let imageURLString: String?
    public let confidenceScore: Double
    public let alternativeMatches: [String]

    public init(
        id: UUID = UUID(),
        name: String,
        mealType: MealType,
        cuisine: String = "General",
        imageURLString: String? = nil,
        confidenceScore: Double,
        alternativeMatches: [String] = []
    ) {
        self.id = id
        self.name = name
        self.mealType = mealType
        self.cuisine = cuisine
        self.imageURLString = imageURLString
        self.confidenceScore = confidenceScore
        self.alternativeMatches = alternativeMatches
    }
}

public struct Ingredient: Sendable, Hashable, Identifiable {
    public let id: UUID
    public let name: String
    public let amount: Double
    public let unit: String
    public let emoji: String

    public init(
        id: UUID = UUID(),
        name: String,
        amount: Double,
        unit: String,
        emoji: String = "🥘"
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
        self.emoji = emoji
    }

    public func formattedAmount(multiplier: Double = 1.0) -> String {
        let scaled = amount * multiplier
        if scaled.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(scaled)) \(unit)".trimmingCharacters(in: .whitespaces)
        } else {
            return String(format: "%.1f %@", scaled, unit).trimmingCharacters(in: .whitespaces)
        }
    }
}

public struct RecipeStep: Sendable, Hashable, Identifiable {
    public let id: UUID
    public let stepNumber: Int
    public let instruction: String
    public let durationMinutes: Int?

    public init(
        id: UUID = UUID(),
        stepNumber: Int,
        instruction: String,
        durationMinutes: Int? = nil
    ) {
        self.id = id
        self.stepNumber = stepNumber
        self.instruction = instruction
        self.durationMinutes = durationMinutes
    }
}

public enum RecipeDifficulty: String, Sendable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

public struct Recipe: Sendable, Hashable, Identifiable {
    public let id: UUID
    public let meal: MealIdentification
    public let prepTimeMinutes: Int
    public let cookTimeMinutes: Int
    public let baseServings: Int
    public let difficulty: RecipeDifficulty
    public let ingredients: [Ingredient]
    public let steps: [RecipeStep]

    public var totalTimeMinutes: Int {
        prepTimeMinutes + cookTimeMinutes
    }

    public init(
        id: UUID = UUID(),
        meal: MealIdentification,
        prepTimeMinutes: Int,
        cookTimeMinutes: Int,
        baseServings: Int = 2,
        difficulty: RecipeDifficulty = .easy,
        ingredients: [Ingredient],
        steps: [RecipeStep]
    ) {
        self.id = id
        self.meal = meal
        self.prepTimeMinutes = prepTimeMinutes
        self.cookTimeMinutes = cookTimeMinutes
        self.baseServings = baseServings
        self.difficulty = difficulty
        self.ingredients = ingredients
        self.steps = steps
    }
}
