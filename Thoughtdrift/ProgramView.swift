import SwiftUI

struct ProgramView: View {
    @EnvironmentObject var store: JournalStore
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    progress
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 340), spacing: 24, alignment: .top)], spacing: 24) {
                        ForEach(Program.weeks) { week in
                            weekSection(week)
                        }
                    }
                }
                .padding(20)
                .readableWidth(1000)
            }
            .calmBackground()
            .navigationTitle("Program")
            .sheet(isPresented: $showPaywall) { PaywallView().environmentObject(purchases) }
        }
    }

    private var progress: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(store.completedCount) of 30 days")
                .font(.calm(.title2, weight: .semibold))
                .foregroundStyle(Theme.ink)
            ProgressView(value: Double(store.completedCount), total: 30)
                .tint(Theme.sage)
            Text(store.finishedTodaysPrompt && !store.allComplete
                 ? "Nice work today. A new prompt unlocks each day."
                 : "One new prompt unlocks each day.")
                .font(.calm(.footnote))
                .foregroundStyle(Theme.muted)
        }
        .card()
    }

    private func weekSection(_ week: Week) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Week \(week.id) · \(week.title)")
                    .font(.calm(.title3, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Text(week.goal)
                    .font(.calm(.subheadline))
                    .foregroundStyle(Theme.muted)
            }

            let start = (week.id - 1) * 7
            let days = Array(Program.days[start..<min(start + 7, 30)])
            VStack(spacing: 0) {
                ForEach(days) { day in
                    row(day)
                    if day.id != days.last?.id { Divider().padding(.leading, 56) }
                }
            }
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous))

            if week.id > 1 && !purchases.hasFullAccess {
                EmptyView()
            } else if store.weekComplete(week.id) || week.id == 4 && store.completedCount >= 28 {
                NavigationLink {
                    CheckInView(week: week)
                } label: {
                    Label("Week \(week.id) Check-In", systemImage: "heart.text.square")
                        .font(.calm(.headline))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.sage.opacity(0.18), in: Capsule())
                        .foregroundStyle(Theme.ink)
                }
            }
        }
    }

    @ViewBuilder
    private func row(_ day: JournalDay) -> some View {
        let premiumLocked = purchases.requiresPurchase(day.id)
        let unlocked = store.isUnlocked(day.id) && !premiumLocked
        let done = store.isComplete(day.id)
        let content = HStack(spacing: 14) {
            Image(systemName: premiumLocked ? "lock.fill" : done ? "checkmark.circle.fill" : unlocked ? "circle" : "lock")
                .font(.title3)
                .foregroundStyle(done ? Theme.sage : Theme.muted.opacity(0.6))
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text("Day \(day.id)")
                    .font(.calm(.caption))
                    .foregroundStyle(Theme.muted)
                Text(day.title)
                    .font(.calm(.body, weight: .medium))
                    .foregroundStyle(unlocked ? Theme.ink : Theme.muted)
            }
            Spacer()
            if premiumLocked {
                Text("FULL")
                    .font(.calm(.caption2, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(Theme.sage)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.sage.opacity(0.15), in: Capsule())
            }
        }
        .padding(16)
        .contentShape(Rectangle())

        if premiumLocked {
            Button { showPaywall = true } label: { content }
                .buttonStyle(.plain)
        } else if unlocked {
            NavigationLink { DayEntryView(day: day) } label: { content }
                .buttonStyle(.plain)
        } else {
            content
        }
    }
}

struct CheckInView: View {
    let week: Week
    @AppStorage private var reflection: String

    init(week: Week) {
        self.week = week
        _reflection = AppStorage(wrappedValue: "", "checkin-\(week.id)")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Week \(week.id) Check-In")
                    .font(.calm(.largeTitle, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Text(week.summary)
                    .font(.calm(.body))
                    .foregroundStyle(Theme.ink)
                    .lineSpacing(5)
                    .card()
                Text("Quick reflection: \(week.reflection)")
                    .font(.calm(.headline))
                    .foregroundStyle(Theme.sage)
                TextEditor(text: $reflection)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 160)
                    .padding(14)
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .padding(20)
            .readableWidth()
        }
        .scrollDismissesKeyboard(.interactively)
        .calmBackground()
        .navigationBarTitleDisplayMode(.inline)
    }
}
