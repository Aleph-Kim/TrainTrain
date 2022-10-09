import SwiftUI

struct AskCapsuleViewModifier: ViewModifier {

  func body(content: Content) -> some View {
    content
      .bold()
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
      .background(.quaternary)
      .clipShape(Capsule())
  }
}

extension View {
  func askCapsule() -> some View {
    modifier(AskCapsuleViewModifier())
  }
}

struct AskCapsuleViewModifier_Previews: PreviewProvider {
  static var previews: some View {
    Text(SubwayLine.line2.rawValue)
      .askCapsule()
  }
}
