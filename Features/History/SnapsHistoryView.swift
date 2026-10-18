import SwiftUI

public struct SnapsHistoryView: View {
    public let allSnaps: [Recipe]
    public let onSelectRecipe: (Recipe) -> Void

    @State private var searchText: String = ""
    @State private var selectedMealType: MealType? = nil

    public init(
        allSnaps: [Recipe],
        onSelectRecipe: @escaping (Recipe) -> Void
    ) {
        self.allSnaps = allSnaps
        self.onSelectRecipe = onSelectRecipe
    }

    private var filteredSnaps: [Recipe] {
        allSnaps.filter { recipe in
            let matchesSearch = searchText.isEmpty ||
                recipe.meal.name.localizedCaseInsensitiveContains(searchText) ||
                recipe.meal.mealType.rawValue.localizedCaseInsensitiveContains(searchText)

            let matchesType = selectedMealType == nil || recipe.meal.mealType == selectedMealType

            return matchesSearch && matchesType
        }
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                if allSnaps.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            mealTypeFilterBar

                            LazyVStack(spacing: 12) {
                                ForEach(filteredSnaps) { recipe in
                                    Button(action: { onSelectRecipe(recipe) }) {
                                        historyRow(for: recipe)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 120)
                    }
                }
            }
            .navigationTitle("My Snaps")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search meal or ingredients")
        }
    }

    private var mealTypeFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button(action: { selectedMealType = nil }) {
                    Text("All (\(allSnaps.count))")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(selectedMealType == nil ? .white : Color.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            selectedMealType == nil ?
                            Color(red: 1.0, green: 0.35, blue: 0.12) :
                            Color(uiColor: .secondarySystemGroupedBackground)
                        )
                        .clipShape(Capsule())
                }

                ForEach(MealType.allCases) { type in
                    let isSelected = selectedMealType == type
                    let count = allSnaps.filter { $0.meal.mealType == type }.count
                    Button(action: { selectedMealType = type }) {
                        Text("\(type.rawValue) (\(count))")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(isSelected ? .white : Color.primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                isSelected ?
                                Color(red: 1.0, green: 0.35, blue: 0.12) :
                                Color(uiColor: .secondarySystemGroupedBackground)
                            )
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private func historyRow(for recipe: Recipe) -> some View {
        HStack(spacing: 14) {
            AsyncImage(url: URL(string: recipe.meal.imageURLString ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 62, height: 62)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(uiColor: .tertiarySystemFill))
                        .frame(width: 62, height: 62)
                        .overlay {
                            Text(recipe.meal.mealType.emoji)
                                .font(.system(size: 24))
                        }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.meal.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)

                HStack(spacing: 6) {
                    Text(recipe.meal.mealType.rawValue)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color(red: 1.0, green: 0.35, blue: 0.12))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(red: 1.0, green: 0.35, blue: 0.12).opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                    Text("· \(recipe.totalTimeMinutes) min · \(recipe.ingredients.count) ingredients")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary.opacity(0.35))
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
    }

    private var emptyStateView: some View {
        VStack(spacing: 14) {
            Image(systemName: "camera.badge.ellipsis")
                .font(.system(size: 48))
                .foregroundStyle(Color.secondary.opacity(0.5))

            Text("No Snaps Found")
                .font(.system(size: 20, weight: .semibold))

            Text("Try clearing search or snapping new meals with the floating camera bar.")
                .font(.system(size: 14))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
