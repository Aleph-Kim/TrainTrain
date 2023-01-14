import Foundation

extension Comparable {

  /// 특정 값을 원하는 범위로 자릅니다.
  /// - Returns: 10.clamped(to 0...3) -> 3 혹은 -2.clamped(to 0...3) -> 0
  func clamped(to limits: ClosedRange<Self>) -> Self {
    return min(max(self, limits.lowerBound), limits.upperBound)
  }
}
