import SwiftUI

// All custom RGB colors — theme-independent (we force .dark and never read system colors).
enum SporeTheme {
    // Deep rotting-log forest floor
    static let bg          = Color(red: 0.055, green: 0.075, blue: 0.070)
    static let bgDeep      = Color(red: 0.030, green: 0.045, blue: 0.045)
    static let card        = Color(red: 0.098, green: 0.130, blue: 0.120)
    static let cardRaised  = Color(red: 0.140, green: 0.180, blue: 0.165)
    static let cardLocked  = Color(red: 0.080, green: 0.100, blue: 0.095)

    // Bioluminescent glow
    static let teal        = Color(red: 0.250, green: 0.900, blue: 0.780)
    static let tealDim     = Color(red: 0.180, green: 0.620, blue: 0.560)
    static let violet      = Color(red: 0.640, green: 0.420, blue: 0.950)
    static let violetDim   = Color(red: 0.430, green: 0.290, blue: 0.680)
    static let amber       = Color(red: 0.980, green: 0.760, blue: 0.380)
    static let moss        = Color(red: 0.420, green: 0.560, blue: 0.360)

    static let text        = Color(red: 0.880, green: 0.940, blue: 0.910)
    static let textDim     = Color(red: 0.560, green: 0.640, blue: 0.610)
    static let textFaint   = Color(red: 0.360, green: 0.430, blue: 0.410)

    static let danger      = Color(red: 0.920, green: 0.420, blue: 0.380)
    static let good        = Color(red: 0.420, green: 0.880, blue: 0.560)
}

// Abbreviate large numbers: 12.3K / 4.50M / 1.20B ...
enum SporeFormat {
    private static let suffixes = ["", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"]

    static func abbrev(_ value: Double) -> String {
        if value.isNaN || value.isInfinite { return "0" }
        let v = value
        if v < 1000 {
            if v == v.rounded() { return String(Int(v)) }
            return String(format: "%.1f", v)
        }
        var idx = 0
        var n = v
        while n >= 1000 && idx < suffixes.count - 1 {
            n /= 1000
            idx += 1
        }
        if n >= 100 { return String(format: "%.0f%@", n, suffixes[idx]) }
        if n >= 10  { return String(format: "%.1f%@", n, suffixes[idx]) }
        return String(format: "%.2f%@", n, suffixes[idx])
    }

    static func rate(_ value: Double) -> String {
        return abbrev(value) + "/s"
    }

    static func percent(_ fraction: Double) -> String {
        return String(format: "%.0f%%", fraction * 100)
    }
}
