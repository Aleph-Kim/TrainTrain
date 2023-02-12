import Foundation

extension Array {
  /// safely export element by index
  public subscript (safe index: Int) -> Element? {
    // iOS 9 or later
    return indices ~= index ? self[index] : nil
  }
}
