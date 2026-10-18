// SnaffuApp.swift
// Snaffu — Premium Recipe App
// Requires: iOS 17+, Swift 6.2+, Xcode 26+

import SwiftUI

@main
struct SnaffuApp: App {

    @State private var store = RecipeStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
