import SwiftUI

struct CheatSheetView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
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
                    Text("Pro tip: Don't try to fix every distortion at once. Pick the one that shows up most often and practice catching it for a week.")
                        .font(.calm(.footnote))
                        .foregroundStyle(Theme.muted)
                        .padding(.horizontal, 8)
                }
                .padding(20)
            }
            .calmBackground()
            .navigationTitle("Distortions")
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var store: JournalStore

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily reminder") {
                    Toggle("Remind me", isOn: $store.remindersEnabled)
                    if store.remindersEnabled {
                        DatePicker("Time", selection: $store.reminderTime, displayedComponents: .hourAndMinute)
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
            .task(id: store.remindersEnabled) { await store.updateReminders() }
            .onChange(of: store.reminderTime) { _ in Task { await store.updateReminders() } }
        }
    }
}
