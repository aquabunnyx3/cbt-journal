import Foundation
import UserNotifications

@MainActor
final class JournalStore: ObservableObject {
    @Published private(set) var entries: [Int: String] = [:]
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

    init() {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = dir.appendingPathComponent("entries.json")
        hasOnboarded = defaults.bool(forKey: "hasOnboarded")
        remindersEnabled = defaults.bool(forKey: "remindersEnabled")
        reminderTime = defaults.object(forKey: "reminderTime") as? Date
            ?? Calendar.current.date(from: DateComponents(hour: 9)) ?? Date()
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([Int: String].self, from: data) {
            entries = decoded
        }
    }

    func entry(for day: Int) -> String { entries[day] ?? "" }

    func isComplete(_ day: Int) -> Bool {
        !entry(for: day).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var completedCount: Int { Program.days.filter { isComplete($0.id) }.count }

    // First day without an entry, so missed days never need catching up.
    var currentDay: Int { Program.days.first { !isComplete($0.id) }?.id ?? 30 }

    func isUnlocked(_ day: Int) -> Bool { day <= currentDay || isComplete(day) }

    func weekComplete(_ week: Int) -> Bool {
        let range = ((week - 1) * 7 + 1)...min(week * 7, 30)
        return range.allSatisfy(isComplete)
    }

    func save(_ text: String, for day: Int) {
        entries[day] = text
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: fileURL, options: [.atomic, .completeFileProtection])
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
