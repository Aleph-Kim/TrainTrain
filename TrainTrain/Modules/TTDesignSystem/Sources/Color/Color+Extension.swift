import SharedModels
import SwiftUI

extension Color {
  init(hex: UInt, alpha: Double = 1) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xff) / 255,
      green: Double((hex >> 08) & 0xff) / 255,
      blue: Double((hex >> 00) & 0xff) / 255,
      opacity: alpha
    )
  }
}

public extension SubwayLine {
  /// 각 지하철 호선의 고유 컬러
  var color: Color {
    switch self {
    case .line1: return .line1
    case .line2: return .line2
    case .line3: return .line3
    case .line4: return .line4
    case .line5: return .line5
    case .line6: return .line6
    case .line7: return .line7
    case .line8: return .line8
    case .line9: return .line9
    }
  }
}
