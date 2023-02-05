import SharedModels
import SwiftUI

struct AskCapsuleViewModifier: ViewModifier {

  let bold: Bool

  func body(content: Content) -> some View {
    content
      .font(bold ? Font.body.bold() : Font.body)
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
      .backgroundColor(.secondarySystemBackground)
      .clipShape(Capsule())
  }
}

public extension View {
  func askCapsule(bold: Bool = true) -> some View {
    modifier(AskCapsuleViewModifier(bold: bold))
  }
}

struct AskCapsuleViewModifier_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      Text(SubwayLine.line2.rawValue)
        .askCapsule()

      Image(systemName: "arrow.uturn.left")
        .askCapsule(bold: false)
        .tint(.primary)
    }
  }
}
