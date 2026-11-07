import SwiftUI

@main
struct ThoughtdriftApp: App {
    @StateObject private var store = JournalStore()
    @StateObject private var purchases = PurchaseManager()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            Group {
                if store.hasOnboarded {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(store)
            .environmentObject(purchases)
            .tint(Theme.sage)
            .onChange(of: scenePhase) { phase in
                // Re-check the date (new prompt) and purchases when returning to the app.
                if phase == .active {
                    store.objectWillChange.send()
                    Task { await purchases.refreshEntitlements() }
                }
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "sun.max") }
            ProgramView()
                .tabItem { Label("Program", systemImage: "calendar") }
            CheatSheetView()
                .tabItem { Label("Distortions", systemImage: "lightbulb") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
