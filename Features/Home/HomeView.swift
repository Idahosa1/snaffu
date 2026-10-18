import SwiftUI

public struct HomeView: View {
    public let onSelectRecipe: ((Recipe) -> Void)?
    public let onOpenProfile: (() -> Void)?

    @State private var recentSnaps: [Recipe] = LocalRecipeAnalysisService.curatedCatalog

    public init(
        onSelectRecipe: ((Recipe) -> Void)? = nil,
        onOpenProfile: (() -> Void)? = nil
    ) {
        self.onSelectRecipe = onSelectRecipe
        self.onOpenProfile = onOpenProfile
    }

    private var timeGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning, Chef" }
        else if hour < 17 { return "Good afternoon, Chef" }
        else { return "Good evening, Chef" }
    }

    private var inspirationItems: [Recipe] {
        Array(recentSnaps.prefix(4))
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 26) {
                        // 1. Time-adaptive Greeting & Copy
                        greetingHeader

                        // 2. Inspiration Carousel (3 or 4 starter options)
                        inspirationCarouselSection

                        // 3. Recent Snaps Archive with Real Photography
                        recentSnapsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 120) // Clearance for floating snap bar
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 0) {
                        Text("snaf")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Color.primary)
                        Text("fu")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Color(red: 1.0, green: 0.35, blue: 0.12))
                    }
                }
            }
        }
    }

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(timeGreeting)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.secondary)

            HStack(alignment: .center, spacing: 16) {
                Text("What should we cook today?")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(2)

                Spacer()

                Button(action: { onOpenProfile?() }) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 42))
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                }
                .accessibilityLabel("Profile & Settings")
            }
        }
    }

    private var inspirationCarouselSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Start with These")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.primary)

                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(inspirationItems) { item in
                        Button(action: { onSelectRecipe?(item) }) {
                            carouselCard(for: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func carouselCard(for recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: recipe.meal.imageURLString ?? "")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 220, height: 140)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color(uiColor: .tertiarySystemFill))
                            .frame(width: 220, height: 140)
                            .overlay {
                                ProgressView()
                            }
                    }
                }

                // Meal Type Badge
                Text(recipe.meal.mealType.rawValue)
                    .font(.system(size: 11, weight: .semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(10)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.meal.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text("\(recipe.totalTimeMinutes) min")
                        .font(.system(size: 12, weight: .medium))

                    Text("·")

                    Text(recipe.difficulty.rawValue)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(Color.secondary)
            }
            .padding(14)
        }
        .frame(width: 220)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color(uiColor: .separator), lineWidth: 0.5)
        )
    }

    private var recentSnapsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recent Snaps")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.primary)

            LazyVStack(spacing: 12) {
                ForEach(recentSnaps) { recipe in
                    Button(action: { onSelectRecipe?(recipe) }) {
                        recentSnapRow(for: recipe)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func recentSnapRow(for recipe: Recipe) -> some View {
        HStack(spacing: 14) {
            AsyncImage(url: URL(string: recipe.meal.imageURLString ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(uiColor: .tertiarySystemFill))
                        .frame(width: 64, height: 64)
                        .overlay {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 22))
                                .foregroundStyle(Color.secondary)
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
}
