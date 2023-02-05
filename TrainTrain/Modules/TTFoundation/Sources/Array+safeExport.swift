import Foundation

extension Array {
  public subscript (safe index: Int) -> Element? {
    // iOS 9 or later
    return indices ~= index ? self[index] : nil
  }
}
