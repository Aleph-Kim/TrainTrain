import SwiftUI

enum SubwayLine: String, CaseIterable, Identifiable {

  case line1 = "1 호선"
  case line2 = "2 호선"
  case line3 = "3 호선"
  case line4 = "4 호선"
  case line5 = "5 호선"
  case line6 = "6 호선"
  case line7 = "7 호선"
  case line8 = "8 호선"
  case line9 = "9 호선"

  var color: Color {
    switch self {
    case .line1:
      return .line1
    case .line2:
      return .line2
    case .line3:
      return .line3
    case .line4:
      return .line4
    case .line5:
      return .line5
    case .line6:
      return .line6
    case .line7:
      return .line7
    case .line8:
      return .line8
    case .line9:
      return .line9
    }
  }

  var id: String {
    self.color.hashValue.description
  }
}
