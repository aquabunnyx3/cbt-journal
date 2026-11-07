import SwiftUI

struct TodayView: View {
    @EnvironmentObject var store: JournalStore
    @EnvironmentObject var purchases: PurchaseManager

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Today")
                .navigationBarTitleDisplayMode(.inline)
                .animation(.easeInOut(duration: 0.35), value: store.finishedTodaysPrompt)
        }
    }

    @ViewBuilder
    private var content: some View {
        if store.finishedTodaysPrompt {
            // Today's prompt is saved: show the daily home screen.
            DailyHomeView(day: Program.days[(store.dayCompletedToday ?? Program.days.count) - 1])
                .id(JournalStore.key(for: Date()))
                .transition(.opacity)
        } else if purchases.requiresPurchase(store.currentDay) {
            // Free days are used up: keep mood + gratitude available, offer the unlock.
            DailyHomeView(day: Program.days[max(store.currentDay - 2, 0)], nextNeedsPurchase: true)
                .id(JournalStore.key(for: Date()))
        } else {
            DayEntryView(day: Program.days[store.currentDay - 1], showsTitleBar: false)
                .id(store.currentDay)
                .transition(.opacity)
        }
    }
}

struct DayEntryView: View {
    @EnvironmentObject var store: JournalStore
    let day: JournalDay
    var showsTitleBar = true
    @State private var text = ""
    @State private var saved = false
    @FocusState private var focused: Bool

    private var week: Week { Program.weeks[min((day.id - 1) / 7, 3)] }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("DAY \(day.id) · WEEK \(week.id)")
                        .font(.calm(.caption, weight: .semibold))
                        .tracking(1.2)
                        .foregroundStyle(Theme.sage)
                    Text(day.title)
                        .font(.calm(.largeTitle, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                }

                Text(day.prompt)
                    .font(.calm(.title3))
                    .foregroundStyle(Theme.ink)
                    .lineSpacing(5)
                    .card()

                VStack(alignment: .leading, spacing: 6) {
                    Text("“\(day.quote)”")
                        .font(.system(.callout, design: .serif).italic())
                        .foregroundStyle(Theme.muted)
                    Text("— \(day.author)")
                        .font(.calm(.footnote))
                        .foregroundStyle(Theme.muted.opacity(0.8))
                }
                .padding(.horizontal, 4)

                TextEditor(text: $text)
                    .font(.calm(.body))
                    .scrollContentBackground(.hidden)
                    .focused($focused)
                    .frame(minHeight: 200)
                    .padding(14)
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(alignment: .topLeading) {
                        if text.isEmpty {
                            Text("One honest sentence is enough…")
                                .font(.calm(.body))
                                .foregroundStyle(Theme.muted.opacity(0.6))
                                .padding(.horizontal, 19)
                                .padding(.vertical, 22)
                                .allowsHitTesting(false)
                        }
                    }

                Button(saved ? "Saved ✓" : "Save Entry") {
                    store.save(text, for: day.id)
                    focused = false
                    withAnimation { saved = true }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                if saved, let message = milestone {
                    Text(message)
                        .font(.calm(.callout, weight: .medium))
                        .foregroundStyle(Theme.ink)
                        .card()
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(20)
            .readableWidth()
        }
        .scrollDismissesKeyboard(.interactively)
        .calmBackground()
        .navigationTitle(showsTitleBar ? "Day \(day.id)" : "")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            text = store.entry(for: day.id)
            saved = false
        }
        .onChange(of: text) { _ in saved = false }
    }

    private var milestone: String? {
        switch day.id {
        case 7: return Reminders.milestones[1]
        case 15: return Reminders.milestones[2]
        case 21: return Reminders.milestones[3]
        case 30: return Reminders.milestones[4]
        default: return nil
        }
    }
}
