import SwiftUI

@main
struct ThoughtdriftApp: App {
    @StateObject private var store = JournalStore()

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
            .tint(Theme.sage)
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
