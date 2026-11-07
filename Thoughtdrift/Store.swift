import Foundation
import UserNotifications

@MainActor
final class JournalStore: ObservableObject {
    @Published private(set) var entries: [Int: String] = [:]
    /// When each day's prompt was first completed. Drives the one-prompt-per-day unlock.
    @Published private(set) var completedOn: [Int: Date] = [:]
    /// Mood and gratitude, keyed by calendar date ("yyyy-MM-dd").
    @Published private(set) var checkIns: [String: DailyCheckIn] = [:]
    @Published var hasOnboarded: Bool {
        didSet { defaults.set(hasOnboarded, forKey: "hasOnboarded") }
    }
    @Published var remindersEnabled: Bool {
        didSet { defaults.set(remindersEnabled, forKey: "remindersEnabled") }
    }
    @Published var reminderTime: Date {
        didSet { defaults.set(reminderTime, forKey: "reminderTime") }
    }

    private let defaults = UserDefaults.standard
    private let fileURL: URL
    private let datesURL: URL
    private let checkInsURL: URL

    init() {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = dir.appendingPathComponent("entries.json")
        datesURL = dir.appendingPathComponent("completed.json")
        checkInsURL = dir.appendingPathComponent("checkins.json")
        hasOnboarded = defaults.bool(forKey: "hasOnboarded")
        remindersEnabled = defaults.bool(forKey: "remindersEnabled")
        reminderTime = defaults.object(forKey: "reminderTime") as? Date
            ?? Calendar.current.date(from: DateComponents(hour: 9)) ?? Date()
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([Int: String].self, from: data) {
            entries = decoded
        }
        if let data = try? Data(contentsOf: datesURL),
           let decoded = try? JSONDecoder().decode([Int: Date].self, from: data) {
            completedOn = decoded
        }
        if let data = try? Data(contentsOf: checkInsURL),
           let decoded = try? JSONDecoder().decode([String: DailyCheckIn].self, from: data) {
            checkIns = decoded
        }
        // Refresh the Today tab when the date rolls over so the next prompt appears.
        NotificationCenter.default.addObserver(forName: .NSCalendarDayChanged, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.objectWillChange.send() }
        }
    }

    func entry(for day: Int) -> String { entries[day] ?? "" }

    func isComplete(_ day: Int) -> Bool {
        !entry(for: day).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var completedCount: Int { Program.days.filter { isComplete($0.id) }.count }

    // First day without an entry, so missed days never need catching up.
    var currentDay: Int { Program.days.first { !isComplete($0.id) }?.id ?? 30 }

    var allComplete: Bool { completedCount == Program.days.count }

    /// The prompt finished today, if any. Only one new prompt unlocks per calendar day.
    var dayCompletedToday: Int? {
        completedOn.filter { isComplete($0.key) && Calendar.current.isDateInToday($0.value) }.keys.max()
    }

    var finishedTodaysPrompt: Bool { dayCompletedToday != nil || allComplete }

    /// Unlocked by time: finished days, plus the next prompt if none was finished today.
    func isUnlocked(_ day: Int) -> Bool {
        isComplete(day) || (day == currentDay && dayCompletedToday == nil)
    }

    func weekComplete(_ week: Int) -> Bool {
        let range = ((week - 1) * 7 + 1)...min(week * 7, 30)
        return range.allSatisfy(isComplete)
    }

    func save(_ text: String, for day: Int) {
        entries[day] = text
        write(entries, to: fileURL)
        if isComplete(day), completedOn[day] == nil {
            completedOn[day] = Date()
            write(completedOn, to: datesURL)
        }
    }

    // MARK: Daily check-in (mood + gratitude)

    static func key(for date: Date) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    var todaysCheckIn: DailyCheckIn {
        var checkIn = checkIns[Self.key(for: Date())] ?? DailyCheckIn()
        while checkIn.gratitude.count < 3 { checkIn.gratitude.append("") }
        return checkIn
    }

    func saveTodaysCheckIn(_ checkIn: DailyCheckIn) {
        checkIns[Self.key(for: Date())] = checkIn
        write(checkIns, to: checkInsURL)
    }

    private func write<T: Encodable>(_ value: T, to url: URL) {
        if let data = try? JSONEncoder().encode(value) {
            try? data.write(to: url, options: [.atomic, .completeFileProtection])
        }
    }

    func updateReminders() async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        guard remindersEnabled else { return }
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        guard granted else {
            remindersEnabled = false
            return
        }
        let content = UNMutableNotificationContent()
        content.title = "Thoughtdrift"
        content.body = Reminders.morning.randomElement() ?? ""
        let parts = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: true)
        try? await center.add(UNNotificationRequest(identifier: "daily", content: content, trigger: trigger))
    }
}

struct DailyCheckIn: Codable, Equatable {
    /// 1 (rough) to 5 (great); nil until the user picks one.
    var mood: Int?
    var gratitude: [String] = ["", "", ""]
}

enum Reminders {
    static let morning = [
        "Your daily CBT prompt is ready. Five minutes of awareness can shift the whole day.",
        "New day, new thought to explore. Open your journal when you're ready.",
        "Morning check-in: What's one thought you're carrying into today?"
    ]
    static let midday = [
        "Anxiety loves autopilot. Pause for two minutes and notice one thought.",
        "Quick reminder: You don't have to believe everything you think.",
        "Stressed? Try a three-breath body check-in right now."
    ]
    static let evening = [
        "Wind down with today's journal entry. Small reflections build big change.",
        "Before bed: Name one thought that showed up today. No judgment, just notice.",
        "Your weekly check-in is waiting. Celebrate the effort, not just the outcome."
    ]
    static let missed = [
        "It's okay to skip a day. Jump back in with today's prompt—no need to catch up.",
        "Progress isn't linear. One entry is enough to restart the habit.",
        "Missed a few days? Your journal is still here, judgment-free."
    ]
    static let milestones: [Int: String] = [
        1: "Week 1 complete! You just built the foundation of thought awareness.",
        2: "Halfway there. You're proving that small steps actually work.",
        3: "Week 3 down. You're not just journaling—you're rewiring patterns.",
        4: "30 days! You turned awareness into a skill. Keep the tools that worked best."
    ]
}
