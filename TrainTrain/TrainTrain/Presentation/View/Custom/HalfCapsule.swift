import SwiftUI

struct HalfCapsule: View {

  let line: SubwayLine

  var body: some View {
    Rectangle()
      .fill(line.color)
      .frame(height: 42)
      .cornerRadius(.infinity, corners: .topLeft)
      .cornerRadius(.infinity, corners: .bottomLeft)
      .overlay(alignment: .leading) {
        Text(line.rawValue)
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

private struct RoundedCorner: Shape {
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners

  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    return Path(path.cgPath)
  }
}

private extension View {
  func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    clipShape(RoundedCorner(radius: radius, corners: corners))
  }
}

struct HalfCapsule_Previews: PreviewProvider {
  static var previews: some View {
    HalfCapsule(line: .line2)
  }
}
