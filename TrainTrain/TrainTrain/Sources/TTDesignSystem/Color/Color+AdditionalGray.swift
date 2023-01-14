import SwiftUI

extension Color {
  enum AdditionalGray {
    case additionalGray1
    case additionalGray2
    case additionalGray3
    case additionalGray4
    case additionalGray5
    case additionalGray6
  }

  static func additionalGray(of level: AdditionalGray, for scheme: ColorScheme) -> Color {
    let isLightMode = scheme == .light

    let additionalGray1 = Color(hex: 0x8E8E93)
    let additionalGray2 = Color(hex: 0x636366)
    let additionalGray3 = Color(hex: 0x48484A)
    let additionalGray4 = Color(hex: 0x3A3A3C)
    let additionalGray5 = Color(hex: 0x1C1C1E)
    let additionalGray6 = Color(hex: 0x1C1C1E)

    let additionalGray1Dark = Color(hex: 0x8E8E93)
    let additionalGray2Dark = Color(hex: 0xAEAEB2)
    let additionalGray3Dark = Color(hex: 0xC7C7CC)
    let additionalGray4Dark = Color(hex: 0xD1D1D6)
    let additionalGray5Dark = Color(hex: 0xE5E5EA)
    let additionalGray6Dark = Color(hex: 0xF2F2F7)

    switch level {
    case .additionalGray1: return isLightMode ? additionalGray1 : additionalGray1Dark
    case .additionalGray2: return isLightMode ? additionalGray2 : additionalGray2Dark
    case .additionalGray3: return isLightMode ? additionalGray3 : additionalGray3Dark
    case .additionalGray4: return isLightMode ? additionalGray4 : additionalGray4Dark
    case .additionalGray5: return isLightMode ? additionalGray5 : additionalGray5Dark
    case .additionalGray6: return isLightMode ? additionalGray6 : additionalGray6Dark
    }
  }
}
