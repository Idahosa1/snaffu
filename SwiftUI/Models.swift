// Models.swift
// Snaffu — Data models (value types throughout)

import Foundation

// MARK: - Recipe

struct Recipe: Identifiable, Hashable, Sendable {
    let id: UUID
    var title: String
    var cuisine: String
    var category: Category
    var durationMinutes: Int
    var rating: Double           // 0.0 – 5.0
    var imageURL: URL
    var chef: Chef
    var nutritionFacts: NutritionFacts
    var isFeatured: Bool
    var tags: [String]

    enum Category: String, CaseIterable, Sendable {
        case all       = "All"
        case salads    = "Salads"
        case pasta     = "Pasta"
        case sushi     = "Sushi"
        case desserts  = "Desserts"
        case stews     = "Stews"

        var emoji: String {
            switch self {
            case .all:      "🍽"
            case .salads:   "🥗"
            case .pasta:    "🍝"
            case .sushi:    "🍣"
            case .desserts: "🍰"
            case .stews:    "🥘"
            }
        }
    }
}

// MARK: - Chef

struct Chef: Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var avatarURL: URL
}

// MARK: - Nutrition

struct NutritionFacts: Hashable, Sendable {
    var calories: Int
    var proteinGrams: Double
    var carbsGrams: Double
    var fatGrams: Double
}

// MARK: - Sample data (preview / mock)

extension Recipe {
    static let samples: [Recipe] = [
        Recipe(
            id: UUID(),
            title: "Creamy Black Truffle Risotto",
            cuisine: "Italian",
            category: .pasta,
            durationMinutes: 35,
            rating: 4.8,
            imageURL: URL(string: "https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=600")!,
            chef: Chef(id: UUID(), name: "Marco Rossi",
                       avatarURL: URL(string: "https://i.pravatar.cc/52?img=11")!),
            nutritionFacts: NutritionFacts(calories: 620, proteinGrams: 18, carbsGrams: 72, fatGrams: 28),
            isFeatured: true,
            tags: ["Gluten-Free"]
        ),
        Recipe(
            id: UUID(),
            title: "Smashed Avocado & Poached Egg Toast",
            cuisine: "Brunch",
            category: .salads,
            durationMinutes: 15,
            rating: 4.6,
            imageURL: URL(string: "https://images.unsplash.com/photo-1603046891744-1f608e2a0b8e?w=600")!,
            chef: Chef(id: UUID(), name: "Sofia Chen",
                       avatarURL: URL(string: "https://i.pravatar.cc/52?img=5")!),
            nutritionFacts: NutritionFacts(calories: 340, proteinGrams: 14, carbsGrams: 30, fatGrams: 18),
            isFeatured: true,
            tags: ["Vegetarian"]
        ),
        Recipe(
            id: UUID(),
            title: "Caprese Salad",
            cuisine: "Italian",
            category: .salads,
            durationMinutes: 10,
            rating: 4.0,
            imageURL: URL(string: "https://images.unsplash.com/photo-1592417817098-8fd3d9eb14a5?w=200")!,
            chef: Chef(id: UUID(), name: "Laura Bianchi",
                       avatarURL: URL(string: "https://i.pravatar.cc/52?img=9")!),
            nutritionFacts: NutritionFacts(calories: 180, proteinGrams: 9, carbsGrams: 6, fatGrams: 12),
            isFeatured: false,
            tags: ["Vegan"]
        ),
        Recipe(
            id: UUID(),
            title: "Lemon Garlic Pasta",
            cuisine: "Italian",
            category: .pasta,
            durationMinutes: 20,
            rating: 5.0,
            imageURL: URL(string: "https://images.unsplash.com/photo-1555949258-eb67b1ef0ceb?w=200")!,
            chef: Chef(id: UUID(), name: "Antonio Verde",
                       avatarURL: URL(string: "https://i.pravatar.cc/52?img=7")!),
            nutritionFacts: NutritionFacts(calories: 520, proteinGrams: 16, carbsGrams: 84, fatGrams: 14),
            isFeatured: false,
            tags: []
        ),
        Recipe(
            id: UUID(),
            title: "Mango Sorbet",
            cuisine: "Dessert",
            category: .desserts,
            durationMinutes: 5,
            rating: 4.5,
            imageURL: URL(string: "https://images.unsplash.com/photo-1580915411954-282cb1b0d780?w=200")!,
            chef: Chef(id: UUID(), name: "Mia Torres",
                       avatarURL: URL(string: "https://i.pravatar.cc/52?img=3")!),
            nutritionFacts: NutritionFacts(calories: 120, proteinGrams: 1, carbsGrams: 28, fatGrams: 0),
            isFeatured: false,
            tags: ["Vegan", "Gluten-Free"]
        ),
    ]
}
