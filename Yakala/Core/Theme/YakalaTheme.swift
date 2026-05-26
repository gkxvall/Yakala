import SwiftUI
import UIKit

enum YakalaTheme {
    static let primary = Color(hex: "#FF2A2F")
    static let primaryDark = Color(hex: "#D91F24")
    static let primaryLight = Color.dynamic(light: "#FFE8E9", dark: "#3A1114")
    static let subtleRedBackground = Color.dynamic(light: "#FFE8E9", dark: "#2A0D0F")
    static let background = Color.dynamic(light: "#FFFFFF", dark: "#111113")
    static let surface = Color.dynamic(light: "#F8F8F8", dark: "#18181B")
    static let card = Color.dynamic(light: "#FFFFFF", dark: "#202024")
    static let textPrimary = Color.dynamic(light: "#1C1C1E", dark: "#F4F4F5")
    static let textSecondary = Color.dynamic(light: "#6B6B6B", dark: "#A1A1AA")
    static let border = Color.dynamic(light: "#E5E5EA", dark: "#34343A")
    static let success = Color(hex: "#22C55E")
    static let warning = Color(hex: "#F59E0B")

    static let cornerRadius: CGFloat = 18
    static let cardRadius: CGFloat = 20
    static let spacing: CGFloat = 16
}

extension Color {
    static func dynamic(light: String, dark: String) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(Color(hex: dark)) : UIColor(Color(hex: light))
        })
    }

    init(hex: String) {
        let cleanedHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&int)

        let red: UInt64
        let green: UInt64
        let blue: UInt64
        let alpha: UInt64

        switch cleanedHex.count {
        case 3:
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (255, 255, 42, 47)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}

extension View {
    func yakalaCardStyle() -> some View {
        self
            .background(YakalaTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: YakalaTheme.cardRadius, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 7, x: 0, y: 8)
    }

    func yakalaSurfaceStyle(cornerRadius: CGFloat = YakalaTheme.cornerRadius) -> some View {
        self
            .background(YakalaTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
