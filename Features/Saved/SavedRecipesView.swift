import SwiftUI

public struct SavedRecipesView: View {
    public let savedRecipes: [Recipe]
    public let onSelectRecipe: (Recipe) -> Void
    public let onRemoveFromSaved: (Recipe) -> Void

    public init(
        savedRecipes: [Recipe],
        onSelectRecipe: @escaping (Recipe) -> Void,
        onRemoveFromSaved: @escaping (Recipe) -> Void
    ) {
        self.savedRecipes = savedRecipes
        self.onSelectRecipe = onSelectRecipe
        self.onRemoveFromSaved = onRemoveFromSaved
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                if savedRecipes.isEmpty {
                    emptySavedState
                } else {
                    List {
                        ForEach(savedRecipes) { recipe in
                            Button(action: { onSelectRecipe(recipe) }) {
                                HStack(spacing: 14) {
                                    AsyncImage(url: URL(string: recipe.meal.imageURLString ?? "")) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 56, height: 56)
                                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                        } else {
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .fill(Color(uiColor: .tertiarySystemFill))
                                                .frame(width: 56, height: 56)
                                                .overlay {
                                                    Text(recipe.meal.mealType.emoji)
                                                        .font(.system(size: 22))
                                                }
                                        }
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(recipe.meal.name)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(Color.primary)

                                        HStack(spacing: 6) {
                                            Text(recipe.meal.mealType.rawValue)
                                                .font(.system(size: 11, weight: .semibold))
                                                .foregroundStyle(Color(red: 1.0, green: 0.35, blue: 0.12))

                                            Text("· \(recipe.totalTimeMinutes) min · \(recipe.difficulty.rawValue)")
                                                .font(.system(size: 13))
                                                .foregroundStyle(Color.secondary)
                                        }
                                    }

                                    Spacer()

                                    Image(systemName: "bookmark.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(Color(red: 1.0, green: 0.35, blue: 0.12))
                                }
                                .padding(.vertical, 4)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    onRemoveFromSaved(recipe)
                                } label: {
                                    Label("Remove", systemImage: "bookmark.slash")
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Saved Recipes")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var emptySavedState: some View {
        VStack(spacing: 14) {
            Image(systemName: "bookmark")
                .font(.system(size: 46))
                .foregroundStyle(Color.secondary.opacity(0.5))

            Text("No Saved Recipes")
                .font(.system(size: 20, weight: .semibold))

            Text("Bookmark your favorite snapped recipes to find them easily when you're ready to cook.")
                .font(.system(size: 14))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
