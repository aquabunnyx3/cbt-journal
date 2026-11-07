import SwiftUI

struct CheatSheetView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 14, alignment: .top)], spacing: 14) {
                        ForEach(Program.distortions) { item in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(item.name)
                                    .font(.calm(.headline))
                                    .foregroundStyle(Theme.ink)
                                Text(item.example)
                                    .font(.calm(.subheadline))
                                    .foregroundStyle(Theme.muted)
                                Label(item.reframe, systemImage: "arrow.turn.down.right")
                                    .font(.calm(.subheadline, weight: .medium))
                                    .foregroundStyle(Theme.sage)
                            }
                            .card()
                        }
                    }
                    Text("Pro tip: Don't try to fix every distortion at once. Pick the one that shows up most often and practice catching it for a week.")
                        .font(.calm(.footnote))
                        .foregroundStyle(Theme.muted)
                        .padding(.horizontal, 8)
                }
                .padding(20)
                .readableWidth(1000)
            }
            .calmBackground()
            .navigationTitle("Distortions")
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var store: JournalStore
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily reminder") {
                    Toggle("Remind me", isOn: $store.remindersEnabled)
                    if store.remindersEnabled {
                        DatePicker("Time", selection: $store.reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
                Section("Full program") {
                    if purchases.hasFullAccess {
                        Label("All 30 days unlocked", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(Theme.sage)
                    } else {
                        Button("Unlock all 30 days") { showPaywall = true }
                    }
                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                }
                Section("Privacy") {
                    Text("Your entries are stored only on this device.")
                        .foregroundStyle(.secondary)
                }
                Section {
                    Text("Thoughtdrift is a self-help tool, not a substitute for professional care. If you're in crisis, contact local emergency services or a crisis line such as 988 in the US.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .scrollContentBackground(.hidden)
            .calmBackground()
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) { PaywallView().environmentObject(purchases) }
            .alert("Purchase", isPresented: Binding(
                get: { purchases.errorMessage != nil && !showPaywall },
                set: { if !$0 { purchases.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(purchases.errorMessage ?? "")
            }
            .task(id: store.remindersEnabled) { await store.updateReminders() }
            .onChange(of: store.reminderTime) { _ in Task { await store.updateReminders() } }
        }
    }
}
