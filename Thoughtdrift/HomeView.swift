import SwiftUI

/// Shown on the Today tab once today's prompt is done (or when the next prompt is locked).
struct DailyHomeView: View {
    @EnvironmentObject var store: JournalStore
    @EnvironmentObject var purchases: PurchaseManager
    /// The day whose quote leads the screen.
    let day: JournalDay
    /// True when the next prompt is waiting behind the paywall rather than the clock.
    var nextNeedsPurchase = false

    @State private var checkIn = DailyCheckIn()
    @State private var loaded = false
    @FocusState private var focusedField: Int?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                quote
                MoodPicker(mood: $checkIn.mood)
                gratitude
                status
            }
            .padding(20)
            .readableWidth()
        }
        .scrollDismissesKeyboard(.interactively)
        .calmBackground()
        .onAppear {
            checkIn = store.todaysCheckIn
            loaded = true
        }
        .onChange(of: checkIn) { newValue in
            if loaded { store.saveTodaysCheckIn(newValue) }
        }
    }

    private var quote: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()).uppercased())
                .font(.calm(.caption, weight: .semibold))
                .tracking(1.2)
                .foregroundStyle(Theme.sage)
            Text("“\(day.quote)”")
                .font(.system(.title2, design: .serif).italic())
                .foregroundStyle(Theme.ink)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            Text("— \(day.author)")
                .font(.calm(.subheadline))
                .foregroundStyle(Theme.muted)
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
    }

    private var gratitude: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("3 things I'm grateful for today")
                .font(.calm(.headline))
                .foregroundStyle(Theme.ink)
            ForEach(0..<3, id: \.self) { i in
                HStack(spacing: 12) {
                    Text("\(i + 1)")
                        .font(.calm(.subheadline, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(Theme.accent, in: Circle())
                    TextField(placeholder(i), text: $checkIn.gratitude[i])
                        .font(.calm(.body))
                        .focused($focusedField, equals: i)
                        .submitLabel(i < 2 ? .next : .done)
                        .onSubmit { focusedField = i < 2 ? i + 1 : nil }
                }
                if i < 2 { Divider().padding(.leading, 40) }
            }
        }
        .card()
    }

    private func placeholder(_ i: Int) -> String {
        ["A person who helped me…", "A small moment I enjoyed…", "Something about myself…"][i]
    }

    @ViewBuilder
    private var status: some View {
        if let message = milestone {
            Text(message)
                .font(.calm(.callout, weight: .medium))
                .foregroundStyle(Theme.ink)
                .card()
        }

        if nextNeedsPurchase || (!store.allComplete && purchases.requiresPurchase(store.currentDay)) {
            UnlockCard()
        } else if store.allComplete {
            Label("You've completed all 30 days. Keep checking in daily.", systemImage: "sparkles")
                .font(.calm(.subheadline))
                .foregroundStyle(Theme.muted)
        } else if store.finishedTodaysPrompt {
            Label("Your next prompt unlocks tomorrow.", systemImage: "moon.stars")
                .font(.calm(.subheadline))
                .foregroundStyle(Theme.muted)
        }

        if store.isComplete(day.id) {
            NavigationLink {
                DayEntryView(day: day)
            } label: {
                Label(store.dayCompletedToday == day.id ? "View today's entry" : "View Day \(day.id) entry", systemImage: "book.closed")
                    .font(.calm(.headline))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.sage.opacity(0.18), in: Capsule())
                    .foregroundStyle(Theme.ink)
            }
        }
    }

    private var milestone: String? {
        guard store.dayCompletedToday == day.id else { return nil }
        switch day.id {
        case 7: return Reminders.milestones[1]
        case 15: return Reminders.milestones[2]
        case 21: return Reminders.milestones[3]
        case 30: return Reminders.milestones[4]
        default: return nil
        }
    }
}
