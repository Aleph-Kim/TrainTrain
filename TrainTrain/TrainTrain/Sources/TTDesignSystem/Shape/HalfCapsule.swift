import SwiftUI

struct HalfCapsule: View {

  @Environment(\.colorScheme) var scheme
  let line: SubwayLine

  var body: some View {
    Rectangle()
      .fill(line.color(for: scheme))
      .frame(height: 42)
      .cornerRadius(.infinity, corners: .topLeft)
      .cornerRadius(.infinity, corners: .bottomLeft)
      .overlay(alignment: .leading) {
        Text(line.name)
          .foregroundColor(.black)
          .bold()
          .padding(.horizontal, 10)
          .padding(.vertical, 5)
          .background(.white)
          .clipShape(Capsule())
          .padding(.leading, 8)
      }
  }
}

struct HalfCapsule_Previews: PreviewProvider {
  static var previews: some View {
    HalfCapsule(line: .line2)
  }
}
