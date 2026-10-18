// DiscoverView.swift
// Snaffu — Main discover screen (mirrors the HTML prototype 1-to-1)

import SwiftUI

struct DiscoverView: View {

    @Environment(RecipeStore.self) private var store
    @State private var searchText = ""

    var body: some View {
        // @Observable binding requires explicit Bindable wrapper
        @Bindable var store = store

        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {

                    // ── Category chips ───────────────────────────
                    CategoryChipsView(selected: $store.selectedCategory)

                    // ── Greeting banner ──────────────────────────
                    GreetingBannerView()
                        .padding(.horizontal)

                    // ── Featured carousel ────────────────────────
                    SectionHeaderView(title: "Featured Today", ctaLabel: "See All") {}

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(store.featuredRecipes) { recipe in
                                HeroCardView(recipe: recipe)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // ── Quick recipes list ───────────────────────
                    SectionHeaderView(title: "Quick & Easy", ctaLabel: "See All") {}

                    LazyVStack(spacing: 0) {
                        ForEach(store.quickRecipes) { recipe in
                            NavigationLink(destination: Text(recipe.title)) {
                                RecipeRowView(recipe: recipe)
                            }
                            .buttonStyle(.plain)

                            if recipe.id != store.quickRecipes.last?.id {
                                Divider().padding(.leading, 80)
                            }
                        }
                    }
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    // concentric: 16 card + 16 H padding + outer bg ~= systemGroupedBackground
                    .padding(.horizontal)
                    .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                    .shadow(color: .black.opacity(0.04), radius: 3,  x: 0, y: 1)

                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Recipes, chefs…")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // notifications
                    } label: {
                        Image(systemName: "bell")
                            .symbolVariant(.none)
                    }
                }
            }
        }
    }
}

// MARK: - Greeting banner

private struct GreetingBannerView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Good morning, Chef!")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("12 new recipes match your taste profile")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }
            Spacer()
            Text("👨‍🍳")
                .font(.system(size: 44))
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [.red, .orange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .red.opacity(0.35), radius: 20, x: 0, y: 4)
    }
}

// MARK: - Category chips

private struct CategoryChipsView: View {
    @Binding var selected: Recipe.Category

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Recipe.Category.allCases, id: \.self) { cat in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selected = cat
                        }
                    } label: {
                        Label(cat.rawValue, systemImage: "")
                        // emoji prefix instead of SF Symbol
                        Text("\(cat.emoji) \(cat.rawValue)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(selected == cat ? .white : .secondary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background(
                                selected == cat
                                    ? Color.red
                                    : Color(.secondarySystemFill),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                    // min touch target
                    .frame(minHeight: 44)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Section header

private struct SectionHeaderView: View {
    let title: String
    let ctaLabel: String
    let action: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title2.bold())
            Spacer()
            Button(ctaLabel, action: action)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.blue)
        }
        .padding(.horizontal)
    }
}

// MARK: - Hero card

private struct HeroCardView: View {
    @Environment(RecipeStore.self) private var store
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            ZStack(alignment: .topLeading) {
                AsyncImage(url: recipe.imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color(.secondarySystemFill))
                }
                .frame(width: 300, height: 180)
                .clipped()

                // Badge
                Text("Staff Pick")
                    .font(.caption.weight(.black))
                    .textCase(.uppercase)
                    .foregroundStyle(.white)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(.red, in: Capsule())
                    .padding(12)

                // Favourite button — top-right
                Button {
                    store.toggleSaved(recipe)
                } label: {
                    Image(systemName: store.isSaved(recipe) ? "heart.fill" : "heart")
                        .foregroundStyle(store.isSaved(recipe) ? .red : .primary)
                        .padding(8)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, maxHeight: .infinity,
                       alignment: .topTrailing)
                .padding(10)
            }
            .frame(width: 300, height: 180)

            // Body
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(recipe.cuisine).font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text("·").foregroundStyle(.quaternary)
                    Text(recipe.category.rawValue).font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Text(recipe.title)
                    .font(.headline)
                    .lineLimit(2)

                HStack {
                    // Chef
                    AsyncImage(url: recipe.chef.avatarURL) { img in
                        img.resizable().scaledToFill()
                    } placeholder: {
                        Circle().fill(Color(.secondarySystemFill))
                    }
                    .frame(width: 26, height: 26)
                    .clipShape(Circle())

                    Text(recipe.chef.name)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Spacer()

                    Label("\(recipe.durationMinutes)m", systemImage: "clock")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Label(String(format: "%.1f", recipe.rating), systemImage: "star.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                }
            }
            .padding(14)
        }
        .frame(width: 300)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 4)
        .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Recipe row (list)

private struct RecipeRowView: View {
    let recipe: Recipe

    var body: some View {
        HStack(spacing: 14) {
            AsyncImage(url: recipe.imageURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemFill))
            }
            .frame(width: 52, height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            // 1px photo outline per Jakub Krehel rules
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(recipe.title)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(recipe.cuisine)
                    Text("·")
                    Text("\(recipe.durationMinutes) min")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                // Stars
                HStack(spacing: 1) {
                    ForEach(0..<5) { i in
                        Image(systemName: Double(i) < recipe.rating ? "star.fill" : "star")
                            .font(.system(size: 10))
                            .foregroundStyle(Double(i) < recipe.rating ? .orange : .quaternary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.quaternary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .contentShape(Rectangle())   // full-row tap target
    }
}

#Preview {
    DiscoverView()
        .environment(RecipeStore())
}
