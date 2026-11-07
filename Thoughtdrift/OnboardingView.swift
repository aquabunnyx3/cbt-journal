import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: JournalStore
    @State private var page = 0

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                welcome.tag(0)
                howItWorks.tag(1)
                prep.tag(2)
                dayOne.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button(buttonTitle) {
                if page < 3 {
                    withAnimation(.easeInOut) { page += 1 }
                } else {
                    store.hasOnboarded = true
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .readableWidth(560)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .calmBackground()
    }

    private var buttonTitle: String {
        ["Start Day 1", "I'm Ready", "Begin Day 1", "Open Today's Prompt"][page]
    }

    private func screen<Content: View>(symbol: String, headline: String, @ViewBuilder content: () -> Content) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image(systemName: symbol)
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(Theme.accent)
                    .padding(.top, 48)
                Text(headline)
                    .font(.calm(.largeTitle, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                content()
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 48)
            .readableWidth(560)
        }
    }

    private func body(_ text: String) -> some View {
        Text(text)
            .font(.calm(.body))
            .foregroundStyle(Theme.muted)
            .lineSpacing(5)
    }

    private var welcome: some View {
        screen(symbol: "leaf", headline: "Your 30-Day Journey Starts Here") {
            body("Anxiety is exhausting. Racing thoughts, tight chests, sleepless nights—your brain is trying to protect you, but it's working overtime.")
            body("This program is built on Cognitive Behavioral Therapy (CBT), one of the most researched and effective treatments for anxiety. Over the next 30 days, you'll learn to catch anxious thoughts, test them against reality, and take small steps forward.")
            body("You don't need to be a writer. You don't need to journal perfectly. You just need five honest minutes a day.")
        }
    }

    private var howItWorks: some View {
        screen(symbol: "square.stack.3d.up", headline: "Five Minutes. One Prompt. Real Tools.") {
            body("Each day, you'll get one CBT-based journal prompt designed to help you notice, challenge, and reframe anxious thinking. You'll also get an encouraging quote—because this work is hard, and you deserve support.")
            VStack(spacing: 12) {
                ForEach(Program.weeks) { week in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Week \(week.id): \(week.title)")
                            .font(.calm(.headline))
                            .foregroundStyle(Theme.ink)
                        Text(week.goal)
                            .font(.calm(.subheadline))
                            .foregroundStyle(Theme.muted)
                    }
                    .card()
                }
            }
            body("Weekly check-ins help you reflect on progress without judgment. Reminder notifications keep you gently accountable.")
        }
    }

    private var prep: some View {
        screen(symbol: "checklist", headline: "Before You Begin") {
            VStack(alignment: .leading, spacing: 16) {
                tip("clock", "Pick a time.", "Morning, lunch, or evening—consistency matters more than timing.")
                tip("house", "Find a quiet spot.", "Even a bathroom stall works if it gives you privacy.")
                tip("pencil.line", "Lower the bar.", "One sentence counts. A messy entry counts. Showing up counts.")
                tip("hourglass", "Be patient.", "Change happens slowly, then suddenly. Trust the process.")
            }
            .card()
        }
    }

    private func tip(_ symbol: String, _ title: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .foregroundStyle(Theme.sage)
                .frame(width: 28)
            Text("\(Text(title).fontWeight(.semibold).foregroundColor(Theme.ink)) \(text)")
                .font(.calm(.body))
                .foregroundStyle(Theme.muted)
        }
    }

    private var dayOne: some View {
        screen(symbol: "sparkles", headline: "Let's Notice One Thought") {
            body("Today is simple: describe a situation that triggered anxiety and write down the automatic thought that followed.")
            body("Don't analyze it yet. Don't fix it. Just notice it.")
            body("Awareness is the first skill of CBT. You're already doing the work by showing up.")
        }
    }
}
