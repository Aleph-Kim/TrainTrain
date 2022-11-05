import SwiftUI

struct TrainProgressView: View {
  private let isMovingNow: Bool
  @State private var progressPercentage: CGFloat
  let arrivalState: TrainInfo.ArrivalState
  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  init(arrivalState: TrainInfo.ArrivalState) {
    self.arrivalState = arrivalState
    switch arrivalState {
    case .approaching:
      progressPercentage = 0
      isMovingNow = true
    case .arrived:
      progressPercentage = 0.25
      isMovingNow = false
    case .departed:
      progressPercentage = 0.25
      isMovingNow = true
    case .previousApproaching:
      progressPercentage = 0
      isMovingNow = true
    case .previousArrived:
      progressPercentage = 0.25
      isMovingNow = false
    case .previousDeparted:
      progressPercentage = 0.25
      isMovingNow = true
    default:
      progressPercentage = 0.25
      isMovingNow = false
    }
  }
  
  var body: some View {
    GeometryReader { proxy in
      HStack(spacing: 0) {
        Image(systemName: "train.side.middle.car")
          .font(.system(size: 13))
        Image(systemName: "train.side.front.car")
          .font(.system(size: 13))
        LinearGradient(colors: [.yellow, .clear], startPoint: .leading, endPoint: .trailing)
          .frame(width: 15, height: 10)
          .mask(Triangle())
          .offset(CGSize(width: -3, height: 3))
          .opacity(isMovingNow ? 1.0 : 0.0)
      }
      .offset(x: (progressPercentage * proxy.size.width) - 19.5, y: proxy.size.height - 13)
      Rectangle()
        .frame(width: 5, height: 10)
        .foregroundColor(.white)
        .offset(x:proxy.size.width * 0.25, y: proxy.size.height)
    }
    .onReceive(timer, perform: { _ in
      if arrivalState == .approaching || arrivalState == .previousApproaching {
        if progressPercentage < 0.25 {
          progressPercentage += 0.015
        }
      } else if arrivalState == .arrived || arrivalState == .previousArrived {
        if progressPercentage <= 0.25 {
          progressPercentage += 0.015
        }
      } else if arrivalState == .departed || arrivalState == .previousDeparted {
        if progressPercentage <= 1 {
          progressPercentage += 0.015
        }
      }
    })
  }
}

// MARK: SwiftUI previews

struct TrainProgressView_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      Color.black
      HStack {
        TrainProgressView(arrivalState: .departed)
          .foregroundColor(.white)
          .padding(30)
          .frame(width: 150, height: 160)
      }
    }
  }
}
