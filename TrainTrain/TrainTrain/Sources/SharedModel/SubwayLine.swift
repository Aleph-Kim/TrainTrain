import SwiftUI

enum SubwayLine: String, CaseIterable, Identifiable {

  case line1 = "1001"
  case line2 = "1002"
  case line3 = "1003"
  case line4 = "1004"
  case line5 = "1005"
  case line6 = "1006"
  case line7 = "1007"
  case line8 = "1008"
  case line9 = "1009"

  /// 각 지하철 호선의 고유 컬러
  func color(for scheme: ColorScheme) -> Color {
    .lineColor(subwayLine: self, for: scheme)
  }

  /// 각 지하철 호선의 출력용 이름
  /// (예시) "1 호선", "2 호선"
  var name: String {
    switch self {
    case .line1: return "1 호선"
    case .line2: return "2 호선"
    case .line3: return "3 호선"
    case .line4: return "4 호선"
    case .line5: return "5 호선"
    case .line6: return "6 호선"
    case .line7: return "7 호선"
    case .line8: return "8 호선"
    case .line9: return "9 호선"
    }
  }

  /// 각 지하철 호선의 지하철 호선 ID
  /// (예시) 1호선은 "1001", 2호선은 "1002"
  var id: String {
    self.rawValue
  }
}
