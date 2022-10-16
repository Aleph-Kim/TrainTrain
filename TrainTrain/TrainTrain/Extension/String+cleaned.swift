import Foundation

extension String {

  /// 띄어쓰기와 줄바꿈 제거한 문자열을 반환합니다.
  var cleaned: String {
    self.split(whereSeparator: { $0 == " " || $0 == "\n" }).joined()
  }
}
