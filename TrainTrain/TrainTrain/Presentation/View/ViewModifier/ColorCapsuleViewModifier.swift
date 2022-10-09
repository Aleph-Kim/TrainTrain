import SwiftUI

struct ColorCapsuleViewModifier: ViewModifier {

  let color: Color

  func body(content: Content) -> some View {
    content
      .bold()
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
      .background(
        Capsule()
          .inset(by: 2)
          .stroke(color, lineWidth: 2)
      )
  }
}

extension View {
  func colorCapsule(_ color: Color) -> some View {
    modifier(ColorCapsuleViewModifier(color: color))
  }
}

struct ColorCapsuleViewModifier_Previews: PreviewProvider {
  static var previews: some View {
    Text(SubwayLine.line2.rawValue)
      .colorCapsule(Color.line2)
  }
}
