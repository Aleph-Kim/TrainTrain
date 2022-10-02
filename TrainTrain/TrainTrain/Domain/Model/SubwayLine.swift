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

  /// 각 지하철 호선의 고유 컬러
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

  /// 각 지하철 호선의 지하철 호선 ID
  /// (예시) 1호선은 "1001", 2호선은 "1002"
  var id: String {
    switch self {
    case .line1:
      return "1001"
    case .line2:
      return "1002"
    case .line3:
      return "1003"
    case .line4:
      return "1004"
    case .line5:
      return "1005"
    case .line6:
      return "1006"
    case .line7:
      return "1007"
    case .line8:
      return "1008"
    case .line9:
      return "1009"
    }
  }
}
