import SwiftUI

struct NewTrainProgressView: View {

  let trainInfo: TrainInfo
  let targetStation: StationInfo
  let directionStationID: String
  let networkManager = NetworkManager()
  
  private let movingTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  private let refreshingTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
  
  @State private var eta: Int
  // 0이 시작, 100이 끝
  @State private var remainDistance: CGFloat
  // 초당 움직이는 거리
  @State private var distancePerTic: CGFloat
  
  init(trainInfo: TrainInfo, targetStation: StationInfo, directionStationID: String) {
    self.trainInfo = trainInfo
    self.targetStation = targetStation
    self.directionStationID = directionStationID
    self.eta = Int(trainInfo.eta)!
    self.remainDistance = CGFloat(Int(trainInfo.eta)!) / 300 * 100
    self.distancePerTic = 100 / 300
  }

  var body: some View {
    GeometryReader { proxy in
      let width = proxy.size.width
      let xOffset = width * (1 - remainDistance / 100)

      Circle()
        .frame(width: 15, height: 15)
        .foregroundColor(.yellow)
        .offset(x: xOffset - 7.5)
        .onReceive(refreshingTimer) { _ in
          Task {
            guard let newTrainInfo = await networkManager.fetch(targetStation: targetStation, directionStationID: directionStationID).filter({ $0.id == trainInfo.id }).first else { return }

            if eta >= 30 {
              eta = Int(newTrainInfo.eta)!
              distancePerTic = remainDistance / CGFloat(eta)
            }
          }
        }
        .onReceive(movingTimer) { _ in
          if eta > 0 {
            eta -= 1
          }
          
          if remainDistance > 0 {
            remainDistance -= distancePerTic
          }
        }
    }
  }
}

struct NewTrainProgressView_Previews: PreviewProvider {
  static var previews: some View {
    
    let gangNam = StationInfo(
      subwayLineID: "1002",
      stationID: "1002000222",
      stationName: "강남",
      lowerStationID_1: "1002000223",
      lowerStationETA_1: 60,
      lowerStationID_2: "",
      lowerStationETA_2: "",
      upperStationID_1: "1002000221",
      upperStationETA_1: 60,
      upperStationID_2: "",
      upperStationETA_2: "")

    let mock = TrainInfo(
      subwayLineID: "1002",
      trainDestination: "성수행 - 역삼방면",
      previousStationID: "1002000223",
      nextStationID: "1002000221",
      stationID: "1002000222",
      stationName: "강남",
      trainType: TrainType.normal,
      eta: "300",
      terminusStationID: "88",
      terminusStationName: "성수",
      createdAt: "2022-11-19 16:12:40.0",
      firstMessage: "전역 도착",
      secondMessage: "교대",
      arrivalState: TrainInfo.ArrivalState.previousArrived,
      id: "3245")

    NewTrainProgressView(trainInfo: mock, targetStation: gangNam, directionStationID: "1002000221")
  }
}
