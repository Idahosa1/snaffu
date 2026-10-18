// ContentView.swift
// Snaffu — Root tab controller

import SwiftUI

struct ContentView: View {

    @State private var selectedTab: Tab = .discover

    enum Tab: String, CaseIterable {
        case discover = "Discover"
        case search   = "Search"
        case saved    = "Saved"
        case plan     = "Plan"
        case profile  = "Profile"

        var icon: String {
            switch self {
            case .discover: "fork.knife"
            case .search:   "magnifyingglass"
            case .saved:    "bookmark.fill"
            case .plan:     "calendar"
            case .profile:  "person.circle.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Discover", systemImage: "fork.knife", value: .discover) {
                DiscoverView()
            }
            Tab("Search", systemImage: "magnifyingglass", value: .search) {
                Text("Search")
                    .foregroundStyle(.secondary)
            }
            Tab("Saved", systemImage: "bookmark.fill", value: .saved) {
                Text("Saved Recipes")
                    .foregroundStyle(.secondary)
            }
            Tab("Plan", systemImage: "calendar", value: .plan) {
                Text("Meal Plan")
                    .foregroundStyle(.secondary)
            }
            Tab("Profile", systemImage: "person.circle.fill", value: .profile) {
                Text("Profile")
                    .foregroundStyle(.secondary)
            }
        }
        .tint(.red)   // Apple red — brand accent
    }
}

#Preview {
    ContentView()
        .environment(RecipeStore())
}
