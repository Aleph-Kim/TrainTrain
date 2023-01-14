import Foundation

extension Int {

  /// Int 타입의 숫자를 시간으로 보이도록 변환합니다.
  /// (예시) Int 가 135 라고 하면, "약 2분 15초"로 반환됩니다.
  var asClock: String {
    if self < 60 {
      return "\(self)초"
    } else if (self % 60) == 0 {
      return "\(self / 60)분"
    } else {
      return "\(self / 60)분 \(self % 60)초"
    }
  }
}
