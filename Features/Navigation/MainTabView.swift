import SwiftUI

public enum AppTab: Hashable {
    case home
    case history
    case saved
}

public struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    @State private var allSnaps: [Recipe] = LocalRecipeAnalysisService.curatedCatalog
    @State private var savedRecipes: [Recipe] = [
        LocalRecipeAnalysisService.curatedCatalog[0],
        LocalRecipeAnalysisService.curatedCatalog[1]
    ]
    @State private var activeRecipe: Recipe?
    @State private var showingCamera = false
    @State private var showingProfile = false
    @State private var isAnalyzing = false

    private let analysisService: RecipeAnalysisServiceProtocol = LocalRecipeAnalysisService()

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Main Tab Content
            Group {
                switch selectedTab {
                case .home:
                    HomeView(
                        onSelectRecipe: { recipe in
                            activeRecipe = recipe
                        },
                        onOpenProfile: {
                            showingProfile = true
                        }
                    )
                case .history:
                    SnapsHistoryView(
                        allSnaps: allSnaps,
                        onSelectRecipe: { recipe in
                            activeRecipe = recipe
                        }
                    )
                case .saved:
                    SavedRecipesView(
                        savedRecipes: savedRecipes,
                        onSelectRecipe: { recipe in
                            activeRecipe = recipe
                        },
                        onRemoveFromSaved: { recipe in
                            savedRecipes.removeAll(where: { $0.id == recipe.id })
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Floating Apple Music Island & Disconnected Snap Button
            appleMusicFloatingBar
                .padding(.horizontal, 14)
                .padding(.bottom, 24)

            // Analysis Overlay
            if isAnalyzing {
                Color.black.opacity(0.65)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)

                    Text("Analyzing meal & recipe…")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraView(
                onPhotoCaptured: { photoData in
                    showingCamera = false
                    handlePhotoCaptured(photoData)
                },
                onDismiss: {
                    showingCamera = false
                }
            )
        }
        .sheet(item: $activeRecipe) { recipe in
            RecipeResultView(
                recipe: recipe,
                isSaved: savedRecipes.contains(where: { $0.id == recipe.id }),
                onToggleSave: {
                    if let index = savedRecipes.firstIndex(where: { $0.id == recipe.id }) {
                        savedRecipes.remove(at: index)
                    } else {
                        savedRecipes.append(recipe)
                    }
                },
                onDismiss: {
                    activeRecipe = nil
                }
            )
        }
        .fullScreenCover(isPresented: $showingProfile) {
            ProfileView(
                snapCount: allSnaps.count,
                savedCount: savedRecipes.count
            )
        }
    }

    private var appleMusicFloatingBar: some View {
        HStack(spacing: 10) {
            // Main Floating Island Dock (3 tabs: Home, My Snaps, Saved)
            HStack(spacing: 4) {
                islandTabButton(tab: .home, icon: "house.fill", label: "Home")
                islandTabButton(tab: .history, icon: "square.grid.2x2.fill", label: "My Snaps")
                islandTabButton(tab: .saved, icon: "bookmark.fill", label: "Saved")
            }
            .padding(.horizontal, 6)
            .frame(height: 64)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color.white.opacity(0.65), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 24, y: 8)

            // Disconnected Floating Snap Circle (in primary color, similar to Apple Music search)
            Button(action: { showingCamera = true }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.27, blue: 0.23), Color(red: 1.0, green: 0.18, blue: 0.33)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color(red: 1.0, green: 0.27, blue: 0.23).opacity(0.45), radius: 16, y: 6)

                    Image(systemName: "camera.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private func islandTabButton(tab: AppTab, icon: String, label: String) -> some View {
        let isSelected = selectedTab == tab

        return Button(action: {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? Color(red: 1.0, green: 0.27, blue: 0.23) : Color.primary)

                Text(label)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? Color(red: 1.0, green: 0.27, blue: 0.23) : Color.primary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                isSelected ?
                Color(uiColor: .tertiarySystemFill) :
                Color.clear
            )
            .clipShape(Capsule())
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private func handlePhotoCaptured(_ data: Data) {
        isAnalyzing = true
        Task {
            do {
                let recipe = try await analysisService.analyzeMealImage(data: data)
                isAnalyzing = false
                if !allSnaps.contains(where: { $0.id == recipe.id }) {
                    allSnaps.insert(recipe, at: 0)
                }
                activeRecipe = recipe
            } catch {
                isAnalyzing = false
            }
        }
    }
}
