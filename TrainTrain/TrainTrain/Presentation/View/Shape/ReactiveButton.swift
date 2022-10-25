import SwiftUI

struct ReactiveButton: ButtonStyle {

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.95 : 1)
      .opacity(configuration.isPressed ? 0.6 : 1)
  }
}

struct ReactiveButtonViewModifier_Previews: PreviewProvider {
  static var previews: some View {
    Button(action: {}) {
      Image(systemName: "arrow.uturn.left")
        .askCapsule(bold: false)
        .tint(.primary)
    }
    .buttonStyle(ReactiveButton())
  }
}
