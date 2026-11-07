import SwiftUI

enum Theme {
    static let sage = Color(light: 0x7FA99B, dark: 0x8FBFB0)
    static let sky = Color(light: 0xA7C4DD, dark: 0x5E7F9C)
    static let lavender = Color(light: 0xC9C3E6, dark: 0x6C6590)
    static let sand = Color(light: 0xF6F3EE, dark: 0x16191C)
    static let card = Color(light: 0xFFFFFF, dark: 0x22272B)
    static let ink = Color(light: 0x2F3A40, dark: 0xE8EDEF)
    static let muted = Color(light: 0x6E7B82, dark: 0x9AA6AC)

    static let background = LinearGradient(
        colors: [Color(light: 0xEAF3F1, dark: 0x16201F), sand],
        startPoint: .top, endPoint: .bottom
    )
    static let accent = LinearGradient(
        colors: [sage, sky], startPoint: .topLeading, endPoint: .bottomTrailing
    )
}

extension Color {
    init(light: UInt32, dark: UInt32) {
        self.init(UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(
                red: CGFloat((hex >> 16) & 0xFF) / 255,
                green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255,
                alpha: 1
            )
        })
    }
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 16, y: 6)
    }
}

extension View {
    func card() -> some View { modifier(CardModifier()) }
    // Keeps text comfortably narrow on the unfolded inner display.
    func readableWidth(_ width: CGFloat = 680) -> some View {
        frame(maxWidth: width).frame(maxWidth: .infinity)
    }
    func calmBackground() -> some View {
        background(Theme.background.ignoresSafeArea())
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.accent, in: Capsule())
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension Font {
    static func calm(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        .system(style, design: .rounded).weight(weight)
    }
}
