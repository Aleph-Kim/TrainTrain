import SwiftUI

struct NewTrainProgressView: View {
  
  let trainInfo: TrainInfo
  let targetStation: StationInfo
  let directionStationID: String
  let networkManager = NetworkManager()
  let randomString = ["영차열차!🐢", "신나는 하루!🥰", "파이팅💪", "걷기 좋은날🚶‍♂️", "🎶눈누난나", "🏝떠나고 싶어", "🚀로켓처럼 갈게", "반짝이는 하루💡", "🎊나를 위한 날", "💤졸려...", "아메리카노~☕️", "🤖즐겁습니까휴먼?", "👀열차언제와~!!", "교통약자우선🧑‍🦽", "힘내게🦀", "🦞가재는내편", "🐝왱~", "🐄힘내소", "🐈힘드냥", "🐁재밌쥐?"].randomElement()!
  
  private let movingTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  private let refreshingTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

  /// 열차 도착까지 남은 시간(초) - 1초씩 깎이는 실제 eta 입니다.
  @State private var eta: Int
  /// 0이 시작, 100이 끝
  @State private var remainDistance: CGFloat
  /// 초당 움직이는 거리
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
      let width = proxy.size.width - 15
      let xOffset = width * (1 - remainDistance / 100)
      
      Circle()
        .frame(width: 15, height: 15)
        .foregroundColor(.yellow)
        .offset(x: xOffset)
        .onReceive(refreshingTimer) { _ in
          fetch()
        }
        .onReceive(movingTimer) { _ in
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
        .overlay {
          if eta <= 300 {
            if eta == .zero {
              Text("도착")
                .font(.caption2)
                .foregroundColor(.white)
                .offset(x: xOffset, y: +20)
                .frame(width: 100)
            } else if eta < 30 {
              Text("곧 도착")
                .font(.caption2)
                .foregroundColor(.white)
                .offset(x: xOffset, y: +20)
                .frame(width: 100)
            } else {
              Text(eta.asClock)
                .font(.caption2)
                .foregroundColor(.white)
                .offset(x: xOffset, y: +20)
                .frame(width: 100)
            }
          }
        }
        .overlay {
          if eta <= 300 {
            Text(randomString)
              .font(.system(size: 9))
              .foregroundColor(.white)
              .offset(x: xOffset, y: -20)
              .frame(width: 100)
          }
        }
        .opacity(eta <= 300 ? 1 : 0)
    }
    .onAppear {
      fetch()
    }
  }
  
  private func fetch() {
    Task {
      guard let newTrainInfo = await networkManager.fetch(targetStation: targetStation, directionStationID: directionStationID).filter({ $0.id == trainInfo.id }).first else { return }
      
      // 다음 역을 기준으로 fetch 했니?
      if newTrainInfo.previousStationID == targetStation.stationID {
        if newTrainInfo.arrivalState == .departed
            || newTrainInfo.arrivalState == .arrived
            || newTrainInfo.arrivalState == .approaching
            || newTrainInfo.arrivalState == .previousDeparted{
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

struct NewTrainProgressView_Previews: PreviewProvider {
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
    
    NewTrainProgressView(trainInfo: mock, targetStation: gangNam, directionStationID: "1002000221")
  }
}
