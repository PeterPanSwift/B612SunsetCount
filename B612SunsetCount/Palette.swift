import SwiftUI

/// 可以線性插值的 RGB 顏色，用來讓天空隨著日落進度平滑變色。
struct RGB {
    var r: Double
    var g: Double
    var b: Double

    init(_ hex: UInt32) {
        r = Double((hex >> 16) & 0xFF) / 255
        g = Double((hex >> 8) & 0xFF) / 255
        b = Double(hex & 0xFF) / 255
    }

    init(r: Double, g: Double, b: Double) {
        self.r = r
        self.g = g
        self.b = b
    }

    func mix(_ other: RGB, _ t: Double) -> RGB {
        RGB(r: r + (other.r - r) * t,
            g: g + (other.g - g) * t,
            b: b + (other.b - b) * t)
    }

    var color: Color { Color(red: r, green: g, blue: b) }

    /// 在平均分布的色票之間依 t (0...1) 取色。
    static func keyframes(_ stops: [UInt32], at t: Double) -> RGB {
        let t = min(max(t, 0), 1)
        let scaled = t * Double(stops.count - 1)
        let i = min(Int(scaled), stops.count - 2)
        return RGB(stops[i]).mix(RGB(stops[i + 1]), scaled - Double(i))
    }
}

func smoothstep(_ edge0: Double, _ edge1: Double, _ x: Double) -> Double {
    let t = min(max((x - edge0) / (edge1 - edge0), 0), 1)
    return t * t * (3 - 2 * t)
}

/// 依照日落進度 (0 = 金色黃昏, 1 = 星夜) 算出整個場景的配色。
struct ScenePalette {
    let skyTop: Color
    let skyUpper: Color
    let skyLower: Color
    let skyHorizon: Color
    let sun: Color
    let sunCore: Color
    let glow: Color
    let cloud: Color
    let planetLight: Color
    let planetDark: Color
    let silhouette: RGB
    let coat: Color
    let gold: Color
    let rose: Color

    init(progress p: Double) {
        skyTop     = RGB.keyframes([0x3D4F8F, 0x262A63, 0x070B24], at: p).color
        skyUpper   = RGB.keyframes([0x8E6CA8, 0x5E3C80, 0x15173A], at: p).color
        skyLower   = RGB.keyframes([0xF2A3A0, 0xC9587A, 0x2B2152], at: p).color
        skyHorizon = RGB.keyframes([0xFFD8A0, 0xFF8A5C, 0x4C3068], at: p).color
        sun        = RGB.keyframes([0xFFD27A, 0xFF8045, 0xE8484E], at: p).color
        sunCore    = RGB.keyframes([0xFFF6DC, 0xFFD9A0, 0xFFB08A], at: p).color
        glow       = RGB.keyframes([0xFFC27A, 0xFF7A50, 0x8A3A6A], at: p).color
        cloud      = RGB.keyframes([0xFFC6AE, 0xE27C8C, 0x2C2652], at: p).color
        planetLight = RGB.keyframes([0x7E5E92, 0x4E3262, 0x1E1A3C], at: p).color
        planetDark  = RGB.keyframes([0x3A2850, 0x24183A, 0x0B0A1C], at: p).color
        let sil = RGB.keyframes([0x3B2547, 0x221634, 0x0C0A1A], at: p)
        silhouette = sil
        coat = RGB(0x3F6E5C).mix(sil, 0.35 + p * 0.55).color
        gold = RGB(0xF6C64A).mix(sil, p * 0.55).color
        rose = RGB(0xE5485C).mix(sil, p * 0.5).color
    }
}

extension Color {
    static let cream = Color(red: 1.0, green: 0.96, blue: 0.88)
    static let sunGold = Color(red: 1.0, green: 0.80, blue: 0.40)
}
