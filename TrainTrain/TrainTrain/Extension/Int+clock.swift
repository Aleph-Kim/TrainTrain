import Foundation

extension Int {

  var asClock: String {
    if self < 60 {
      return "약 \(self)초"
    } else if (self % 60) == 0 {
      return "약 \(self / 60)분"
    } else {
      return "약 \(self / 60)분 \(self % 60)초"
    }
  }
}
