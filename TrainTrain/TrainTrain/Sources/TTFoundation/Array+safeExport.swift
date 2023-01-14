import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
      // iOS 9 or later
      return indices ~= index ? self[index] : nil
    }
}
