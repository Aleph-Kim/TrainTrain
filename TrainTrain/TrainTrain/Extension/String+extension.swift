import Foundation

extension String {

  /// 띄어쓰기와 줄바꿈 제거한 문자열을 반환합니다.
  var cleaned: String {
    self.split(whereSeparator: { $0 == " " || $0 == "\n" }).joined()
  }

  /// String 타입으로 들어오는 ETA 를 대략적인 '분 / 초' 로 반환합니다.
  /// 30초 초과 ~ 60초 미만인 경우에는 '초' 로 반환합니다.
  /// 30초 이하인 경우에는 "곧 도착" 으로 반환합니다.
  var asApproximateClock: String {
    guard let self = Int(self) else { return "정보 없음" }

    if self <= 30 {
      return "곧 도착"
    } else if self < 60 {
      return self.asClock
    } else {
      return "약 \(self / 60)분 후"
    }
  }
}
