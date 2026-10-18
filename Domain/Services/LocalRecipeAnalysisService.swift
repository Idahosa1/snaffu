import Foundation

public final class LocalRecipeAnalysisService: RecipeAnalysisServiceProtocol {
    public init() {}

    public func analyzeMealImage(data: Data) async throws -> Recipe {
        guard !data.isEmpty else {
            throw RecipeAnalysisError.invalidImageData
        }

        try await Task.sleep(nanoseconds: 1_000_000_000)

        let hashValue = abs(data.hashValue)
        let catalog = Self.curatedCatalog

        return catalog[hashValue % catalog.count]
    }

    public static let curatedCatalog: [Recipe] = [
        // 1. Breakfast: Mediterranean Shakshuka
        Recipe(
            meal: MealIdentification(
                name: "Mediterranean Shakshuka",
                mealType: .breakfast,
                cuisine: "Middle Eastern",
                imageURLString: "https://images.unsplash.com/photo-1590412200988-a436970781fa?auto=format&fit=crop&w=600&q=80",
                confidenceScore: 0.96,
                alternativeMatches: ["Menemen", "Eggs in Purgatory"]
            ),
            prepTimeMinutes: 10,
            cookTimeMinutes: 15,
            baseServings: 2,
            difficulty: .easy,
            ingredients: [
                Ingredient(name: "Fresh Farm Eggs", amount: 4, unit: "large", emoji: "🥚"),
                Ingredient(name: "San Marzano Tomatoes", amount: 400, unit: "g tin", emoji: "🍅"),
                Ingredient(name: "Red Bell Pepper", amount: 1, unit: "diced", emoji: "🫑"),
                Ingredient(name: "Garlic & Cumin", amount: 3, unit: "cloves", emoji: "🧄"),
                Ingredient(name: "Crumbled Feta", amount: 50, unit: "g", emoji: "🧀")
            ],
            steps: [
                RecipeStep(stepNumber: 1, instruction: "Sauté diced bell peppers and garlic in olive oil until tender and sweet.", durationMinutes: 5),
                RecipeStep(stepNumber: 2, instruction: "Pour in crushed tomatoes and toasted cumin; simmer 10 minutes until thick.", durationMinutes: 10),
                RecipeStep(stepNumber: 3, instruction: "Create wells, crack eggs into sauce, cover and cook 5 minutes until whites set.", durationMinutes: 5)
            ]
        ),

        // 2. Lunch: Bangkok Street Pad Thai
        Recipe(
            meal: MealIdentification(
                name: "Bangkok Street Pad Thai",
                mealType: .lunch,
                cuisine: "Thai",
                imageURLString: "https://images.unsplash.com/photo-1559847844-5315695dadae?auto=format&fit=crop&w=600&q=80",
                confidenceScore: 0.95,
                alternativeMatches: ["Pad See Ew", "Drunken Noodles"]
            ),
            prepTimeMinutes: 15,
            cookTimeMinutes: 10,
            baseServings: 2,
            difficulty: .medium,
            ingredients: [
                Ingredient(name: "Rice Noodles", amount: 200, unit: "g", emoji: "🍜"),
                Ingredient(name: "Tiger Prawns or Tofu", amount: 180, unit: "g", emoji: "🍤"),
                Ingredient(name: "Tamarind Paste", amount: 3, unit: "tbsp", emoji: "🫙"),
                Ingredient(name: "Fish Sauce & Palm Sugar", amount: 2, unit: "tbsp", emoji: "🍶"),
                Ingredient(name: "Roasted Peanuts", amount: 40, unit: "g", emoji: "🥜")
            ],
            steps: [
                RecipeStep(stepNumber: 1, instruction: "Soak rice noodles in warm water for 25 minutes until pliable, then drain.", durationMinutes: 25),
                RecipeStep(stepNumber: 2, instruction: "Wok sear prawns and scramble eggs over maximum heat.", durationMinutes: 3),
                RecipeStep(stepNumber: 3, instruction: "Toss in noodles and tamarind sauce, folding continuously until caramelized.", durationMinutes: 4)
            ]
        ),

        // 3. Dinner: Roman Spaghetti Carbonara
        Recipe(
            meal: MealIdentification(
                name: "Roman Spaghetti Carbonara",
                mealType: .dinner,
                cuisine: "Italian",
                imageURLString: "https://images.unsplash.com/photo-1612874742237-6526221588e3?auto=format&fit=crop&w=600&q=80",
                confidenceScore: 0.98,
                alternativeMatches: ["Cacio e Pepe", "Pasta alla Gricia"]
            ),
            prepTimeMinutes: 10,
            cookTimeMinutes: 15,
            baseServings: 2,
            difficulty: .medium,
            ingredients: [
                Ingredient(name: "Bronze-Cut Spaghetti", amount: 200, unit: "g", emoji: "🍝"),
                Ingredient(name: "Cured Guanciale", amount: 150, unit: "g", emoji: "🥓"),
                Ingredient(name: "Egg Yolks", amount: 4, unit: "large", emoji: "🥚"),
                Ingredient(name: "Pecorino Romano DOP", amount: 80, unit: "g", emoji: "🧀"),
                Ingredient(name: "Cracked Black Pepper", amount: 1, unit: "tbsp", emoji: "🧂")
            ],
            steps: [
                RecipeStep(stepNumber: 1, instruction: "Boil spaghetti in salted water 2 minutes under package time for true al dente.", durationMinutes: 8),
                RecipeStep(stepNumber: 2, instruction: "Render guanciale over medium heat until crispy outside, chewy within; remove from heat.", durationMinutes: 7),
                RecipeStep(stepNumber: 3, instruction: "Whisk yolks and Pecorino, toss with hot pasta off heat to create glossy emulsion.", durationMinutes: 2)
            ]
        ),

        // 4. Dessert: Wild Berry Chia Parfait
        Recipe(
            meal: MealIdentification(
                name: "Wild Berry Chia Parfait",
                mealType: .dessert,
                cuisine: "Contemporary",
                imageURLString: "https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=600&q=80",
                confidenceScore: 0.93,
                alternativeMatches: ["Acai Bowl", "Yogurt Parfait"]
            ),
            prepTimeMinutes: 10,
            cookTimeMinutes: 0,
            baseServings: 2,
            difficulty: .easy,
            ingredients: [
                Ingredient(name: "Chia Seeds", amount: 4, unit: "tbsp", emoji: "🌱"),
                Ingredient(name: "Almond Milk", amount: 250, unit: "ml", emoji: "🥛"),
                Ingredient(name: "Vanilla Greek Yogurt", amount: 150, unit: "g", emoji: "🥣"),
                Ingredient(name: "Fresh Berries & Honey", amount: 100, unit: "g", emoji: "🍓")
            ],
            steps: [
                RecipeStep(stepNumber: 1, instruction: "Stir chia seeds and almond milk; chill 20 minutes to set.", durationMinutes: 20),
                RecipeStep(stepNumber: 2, instruction: "Layer Greek yogurt and chia pudding in chilled glass tumblers.", durationMinutes: 3),
                RecipeStep(stepNumber: 3, instruction: "Top with fresh raspberries, blueberries, and raw honey.", durationMinutes: 2)
            ]
        ),

        // 5. Appetizer: Crispy Veggie Spring Rolls
        Recipe(
            meal: MealIdentification(
                name: "Crispy Veggie Spring Rolls",
                mealType: .appetizer,
                cuisine: "Asian",
                imageURLString: "https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=600&q=80",
                confidenceScore: 0.94,
                alternativeMatches: ["Egg Rolls", "Summer Rolls"]
            ),
            prepTimeMinutes: 20,
            cookTimeMinutes: 10,
            baseServings: 4,
            difficulty: .medium,
            ingredients: [
                Ingredient(name: "Spring Roll Wrappers", amount: 12, unit: "sheets", emoji: "🥟"),
                Ingredient(name: "Shredded Cabbage & Carrots", amount: 200, unit: "g", emoji: "🥕"),
                Ingredient(name: "Shiitake Mushrooms", amount: 60, unit: "g", emoji: "🍄"),
                Ingredient(name: "Sweet Chili Dipping Sauce", amount: 4, unit: "tbsp", emoji: "🌶️")
            ],
            steps: [
                RecipeStep(stepNumber: 1, instruction: "Stir-fry shredded vegetables with sesame oil until crisp-tender.", durationMinutes: 5),
                RecipeStep(stepNumber: 2, instruction: "Roll filling tightly in wrappers, sealing edges with cornstarch slurry.", durationMinutes: 10),
                RecipeStep(stepNumber: 3, instruction: "Fry at 180°C (350°F) for 4 minutes until golden and shatteringly crisp.", durationMinutes: 4)
            ]
        )
    ]
}
