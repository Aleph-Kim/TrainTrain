import SwiftUI

struct TrainProgressView: View {
  @State private var isMovingNow: Bool
  @State private var progressPercentage: CGFloat
  let eta: Int
  let arrivalState: TrainInfo.ArrivalState
  let timerCycle: CGFloat = 0.1
  let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
  
  init(arrivalState: TrainInfo.ArrivalState, eta: Int) {
    self.eta = eta
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
    }
    .onReceive(timer) { _ in
      if arrivalState == .approaching || arrivalState == .previousApproaching {
        isMovingNow = true
        if progressPercentage < 0.25 {
          progressPercentage += timerCycle / 15 * 0.25
        }
      } else if arrivalState == .arrived || arrivalState == .previousArrived {
        if progressPercentage <= 0.25 {
          progressPercentage += timerCycle / 15 * 0.25
        } else {
          isMovingNow = false
        }
      } else if arrivalState == .departed || arrivalState == .previousDeparted {
        isMovingNow = true
        if progressPercentage <= 1 {
          progressPercentage += timerCycle / CGFloat(eta - 10) * 0.75
        }
      }
    }
  }
}

// MARK: SwiftUI previews

struct TrainProgressView_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      Color.black
      HStack {
        TrainProgressView(arrivalState: .departed, eta: 10)
          .foregroundColor(.white)
          .padding(30)
          .frame(width: 150, height: 160)
      }
    }
  }
}
