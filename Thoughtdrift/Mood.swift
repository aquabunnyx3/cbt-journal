import SwiftUI

enum Mood {
    static let labels = ["Rough", "Low", "Okay", "Good", "Great"]

    /// Soft palette from the app theme: lavender (rough) through sky to sage (great).
    static func color(_ level: Int) -> Color {
        switch level {
        case 1: return Color(light: 0xB7AEDB, dark: 0x7A72A3)
        case 2: return Color(light: 0xA9B9E0, dark: 0x6A7FA6)
        case 3: return Color(light: 0xA7C4DD, dark: 0x5E7F9C)
        case 4: return Color(light: 0x93BFB4, dark: 0x6FA595)
        default: return Color(light: 0x7FA99B, dark: 0x8FBFB0)
        }
    }

    static func label(_ level: Int) -> String { labels[max(0, min(level - 1, 4))] }
}

/// A simple drawn smiley. Level 1 is a frown, 3 is a flat line, 5 is a big smile.
struct MoodFace: View {
    let level: Int
    var isSelected = true

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            ZStack {
                Circle()
                    .fill(Mood.color(level).opacity(isSelected ? 1 : 0.35))
                HStack(spacing: size * 0.22) {
                    Circle().frame(width: size * 0.1, height: size * 0.1)
                    Circle().frame(width: size * 0.1, height: size * 0.1)
                }
                .offset(y: -size * 0.12)
                MouthShape(curve: CGFloat(level - 3) / 2)
                    .stroke(style: StrokeStyle(lineWidth: size * 0.07, lineCap: .round))
                    .frame(width: size * 0.42, height: size * 0.2)
                    .offset(y: size * 0.17)
            }
            .foregroundStyle(Color.white.opacity(isSelected ? 0.95 : 0.8))
            .frame(width: size, height: size)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement()
        .accessibilityLabel("Mood: \(Mood.label(level))")
    }
}

/// curve: -1 frown, 0 flat, 1 smile.
struct MouthShape: Shape {
    var curve: CGFloat
    var animatableData: CGFloat {
        get { curve }
        set { curve = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let mid = rect.midY - curve * rect.height * 0.25
        p.move(to: CGPoint(x: rect.minX, y: mid))
        p.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: mid),
            control: CGPoint(x: rect.midX, y: mid + curve * rect.height * 1.2)
        )
        return p
    }
}

/// Row of faces plus a slider; tap a face or drag the slider.
struct MoodPicker: View {
    @Binding var mood: Int?

    private var sliderValue: Binding<Double> {
        Binding(
            get: { Double(mood ?? 3) },
            set: { mood = Int($0.rounded()) }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("How are you feeling?")
                    .font(.calm(.headline))
                    .foregroundStyle(Theme.ink)
                Spacer()
                if let mood {
                    Text(Mood.label(mood))
                        .font(.calm(.subheadline, weight: .semibold))
                        .foregroundStyle(Mood.color(mood))
                }
            }

            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { level in
                    Button {
                        withAnimation(.spring(response: 0.3)) { mood = level }
                    } label: {
                        MoodFace(level: level, isSelected: mood == nil || mood == level)
                            .scaleEffect(mood == level ? 1.15 : 0.9)
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: 64)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 4)

            Slider(value: sliderValue, in: 1...5, step: 1)
                .tint(Mood.color(mood ?? 3))
                .accessibilityLabel("Mood")
                .accessibilityValue(Mood.label(mood ?? 3))
        }
        .card()
        .sensoryFeedbackIfAvailable(trigger: mood)
    }
}

private extension View {
    @ViewBuilder
    func sensoryFeedbackIfAvailable(trigger: Int?) -> some View {
        if #available(iOS 17.0, *) {
            sensoryFeedback(.selection, trigger: trigger)
        } else {
            self
        }
    }
}
