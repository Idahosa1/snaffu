// RecipeStore.swift
// Snaffu — Observable state store (Swift 6.2, @Observable)

import SwiftUI

@Observable
final class RecipeStore {

    // All recipes — source of truth
    private(set) var recipes: [Recipe] = Recipe.samples

    // UI state — selected filter
    var selectedCategory: Recipe.Category = .all

    // Saved / favourites set
    var savedIDs: Set<UUID> = []

    // MARK: - Derived

    var filteredRecipes: [Recipe] {
        guard selectedCategory != .all else { return recipes }
        return recipes.filter { $0.category == selectedCategory }
    }

    var featuredRecipes: [Recipe] { recipes.filter(\.isFeatured) }

    var quickRecipes: [Recipe] {
        recipes
            .filter { !$0.isFeatured && $0.durationMinutes <= 30 }
            .sorted { $0.durationMinutes < $1.durationMinutes }
    }

    // MARK: - Mutations (synchronous — no data races possible)

    func toggleSaved(_ recipe: Recipe) {
        if savedIDs.contains(recipe.id) {
            savedIDs.remove(recipe.id)
        } else {
            savedIDs.insert(recipe.id)
        }
    }

    func isSaved(_ recipe: Recipe) -> Bool {
        savedIDs.contains(recipe.id)
    }
}
