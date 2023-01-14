import SwiftUI

extension Color {
  static func lineColor(subwayLine: SubwayLine, for scheme: ColorScheme = .light) -> Color {
    let isLightMode = scheme == .light

    // Light 모드에서의 색상
    let line1 = Color(hex: 0x0052A4)
    let line2 = Color(hex: 0x43AD35)
    let line3 = Color(hex: 0xEB662F)
    let line4 = Color(hex: 0x39A3D7)
    let line5 = Color(hex: 0x924BBC)
    let line6 = Color(hex: 0xCD6D33)
    let line7 = Color(hex: 0x7D8E20)
    let line8 = Color(hex: 0xDF5884)
    let line9 = Color(hex: 0xB8A366)

    // Dark 모드에서의 색상
    let line1Dark = Color(hex: 0x2B82EC)
    let line2Dark = Color(hex: 0x5DC84E)
    let line3Dark = Color(hex: 0xEF7340)
    let line4Dark = Color(hex: 0x48B6EC)
    let line5Dark = Color(hex: 0xA34FD5)
    let line6Dark = Color(hex: 0xE17F45)
    let line7Dark = Color(hex: 0x97AA32)
    let line8Dark = Color(hex: 0xEA5A89)
    let line9Dark = Color(hex: 0xD0BB7C)

    // ColorScheme에 따른 색상 반환
    switch subwayLine {
    case .line1: return isLightMode ? line1 : line1Dark
    case .line2: return isLightMode ? line2 : line2Dark
    case .line3: return isLightMode ? line3 : line3Dark
    case .line4: return isLightMode ? line4 : line4Dark
    case .line5: return isLightMode ? line5 : line5Dark
    case .line6: return isLightMode ? line6 : line6Dark
    case .line7: return isLightMode ? line7 : line7Dark
    case .line8: return isLightMode ? line8 : line8Dark
    case .line9: return isLightMode ? line9 : line9Dark
    }
  }

  static let bg = Color(uiColor: .quaternarySystemFill)
}

