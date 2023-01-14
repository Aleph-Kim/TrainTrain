import SwiftUI

struct TrainProgressView: View {
  
  private let trainInfo: TrainInfo
  private let targetStation: StationInfo
  private let directionStationID: String
  private let subwayClient: SubwayClient = .live()
  private let subwayLineColor: Color
  
  private let movingTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  private let refreshingTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
  
  /// 열차 도착까지 남은 시간(초) - 1초씩 깎이는 실제 eta 입니다.
  @State private var eta: Int
  /// 0이 시작, 100이 끝
  @State private var remainDistance: CGFloat
  /// 초당 움직이는 거리
  @State private var distancePerTic: CGFloat
  
  init(trainInfo: TrainInfo, targetStation: StationInfo, directionStationID: String, subwayLineColor: Color) {
    self.trainInfo = trainInfo
    self.targetStation = targetStation
    self.directionStationID = directionStationID
    self.subwayLineColor = subwayLineColor
    self.eta = Int(trainInfo.eta)!
    self.remainDistance = CGFloat(Int(trainInfo.eta)!) / 300 * 100
    self.distancePerTic = 100 / 300
  }
  
  var body: some View {
    GeometryReader { proxy in
      let width = proxy.size.width - 15
      let xOffset = width * (1 - remainDistance / 100)
      
      trainCircle(xOffset: xOffset)
        .onReceive(refreshingTimer) { _ in
          fetch()
        }
        .onReceive(movingTimer) { _ in
          moveTrainCirclePerTic()
        }
        .overlay {
          extraInformationView(eta: eta, xOffset: xOffset)
        }
        .opacity(eta <= 300 ? 1 : 0)
    }
    .onAppear {
      fetch()
    }
  }
  
  private func trainCircle(xOffset: CGFloat) -> some View {
    let frameSize: CGFloat = 12.0
    
    return Circle()
      .frame(width: frameSize, height: frameSize)
      .foregroundColor(subwayLineColor)
      .offset(x: xOffset)
  }
  
  private func extraInformationView(eta: Int, xOffset: CGFloat) -> some View {
    Text(extraInformation(eta: eta))
      .font(.caption2)
      .foregroundColor(.secondary)
      .offset(x: xOffset, y: -18)
      .frame(width: 100)
  }
  
  private func extraInformation(eta: Int) -> String {
    if eta == .zero {
      return "도착"
    } else if eta < 30 {
      return "곧 도착"
    } else {
      return eta.asClock
    }
  }
  
  private func moveTrainCirclePerTic() {
    if eta >= 300 {
      remainDistance = 100
    }
    
    if eta > 0 {
      eta -= 1
    }
    
    if remainDistance < 1 {
      remainDistance = 0
    } else {
      remainDistance -= distancePerTic
    }
  }
  
  private func fetch() {
    Task {
      guard let newTrainInfo = try await subwayClient.fetchTrainInfos(targetStation: targetStation, directionStationID: directionStationID).filter({ $0.id == trainInfo.id }).first else { return }
      
      // 다음 역을 기준으로 fetch 했니?
      if newTrainInfo.previousStationID == targetStation.stationID {
        if newTrainInfo.arrivalState == .departed
            || newTrainInfo.arrivalState == .arrived
            || newTrainInfo.arrivalState == .approaching
            || newTrainInfo.arrivalState == .previousDeparted {
          return
        } else {
          eta = 0
          remainDistance = 0
        }
      }
      
      if eta >= 30 {
        eta = Int(newTrainInfo.eta)!
        distancePerTic = remainDistance / CGFloat(eta)
      }
    }
  }
}

struct TrainProgressView_Previews: PreviewProvider {
  static var previews: some View {
    
    let gangNam = StationInfo.findStationInfo(from: "1002000222")
    let mock = TrainInfo(
      subwayLineID: "1002",
      trainDestination: "성수행 - 역삼방면",
      previousStationID: "1002000223",
      nextStationID: "1002000221",
      stationID: "1002000222",
      stationName: "강남",
      trainType: TrainType.normal,
      eta: "0",
      terminusStationID: "88",
      terminusStationName: "성수",
      createdAt: "2022-11-19 16:12:40.0",
      firstMessage: "전역 도착",
      secondMessage: "교대",
      arrivalState: TrainInfo.ArrivalState.previousArrived,
      id: "3245")
    
    TrainProgressView(
      trainInfo: mock,
      targetStation: gangNam,
      directionStationID: "1002000221",
      subwayLineColor: .red)
  }
}
