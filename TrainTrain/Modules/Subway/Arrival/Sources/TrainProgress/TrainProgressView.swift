import Combine
import SubwayModels
import StationInfoClient
import SwiftUI

struct TrainProgressView: View {

  private let trainInfo: TrainInfo
  private let targetStation: StationInfo
  private let directionStationID: String
  private let subwayLineColor: Color
  private let movingTimer: Publishers.Autoconnect<Timer.TimerPublisher>

  /// 열차 도착까지 남은 시간(초) - 1초씩 깎이는 실제 eta 입니다.
  @State private var eta: Int
  /// 0이 시작, 100이 끝
  @State private var remainDistance: CGFloat
  /// 초당 움직이는 거리
  @State private var distancePerTic: CGFloat

  init(
    trainInfo: TrainInfo,
    targetStation: StationInfo,
    directionStationID: String,
    subwayLineColor: Color,
    movingTimer: Publishers.Autoconnect<Timer.TimerPublisher>
  ) {
    self.trainInfo = trainInfo
    self.targetStation = targetStation
    self.directionStationID = directionStationID
    self.subwayLineColor = subwayLineColor
    self.movingTimer = movingTimer
    self.eta = Int(trainInfo.eta)!
    self.remainDistance = CGFloat(Int(trainInfo.eta)!) / 300 * 100
    self.distancePerTic = 100 / 300
  }

  var body: some View {
    GeometryReader { proxy in
      let width = proxy.size.width - 15
      let xOffset = width * (1 - remainDistance / 100)

      trainCircle(xOffset: xOffset)
        .onReceive(movingTimer) { _ in
          moveTrainCirclePerTic()
        }
        .overlay {
          extraInformationView(eta: eta, xOffset: xOffset)
        }
        .opacity(eta <= 300 ? 1 : 0)
    }
    .onChange(of: trainInfo) { newTrainInfo in
      repositionIfNeeded(with: newTrainInfo)
      update(with: newTrainInfo)
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

  /// 새로운 열차 정보를 토대로 열차의 위치를 변경합니다.
  ///
  /// - 새 열차 정보가 다음과 같을 경우 다시 렌더링합니다.
  /// 1. 새 열차 ID가 기존 열차 ID와 다를 경우
  /// 2. 새 열차의 전역이 기존 열차의 전역과 다른 경우
  /// 3. 새 열차의 현재역이 기존 열차의 현재역과 다른 경우
  /// 4. 새 열차의 다음역이 기존 열차의 다음역과 다른 경우
  /// - Parameter newTrainInfo: 새로운 기차 정보
  private func repositionIfNeeded(with newTrainInfo: TrainInfo) {
    let needsRerender = (newTrainInfo.id != trainInfo.id) ||
      (newTrainInfo.previousStationID != trainInfo.previousStationID) ||
      (newTrainInfo.stationID != trainInfo.stationID) ||
      (newTrainInfo.nextStationID != trainInfo.nextStationID)

    guard needsRerender else { return }
    guard let eta = Int(newTrainInfo.eta) else { return }
    self.eta = eta
    self.remainDistance = CGFloat(eta) / 300 * 100
    self.distancePerTic = 100 / 300
  }

  private func update(with newTrainInfo: TrainInfo) {
    let isFetchedFromNextStation = newTrainInfo.previousStationID == targetStation.stationID

    // 목표역에 근접한 열차는 다음역에서 가져온 열차 목록이 신뢰도가 높음
    if isFetchedFromNextStation {
      let hasArrivedTargetStation = (newTrainInfo.arrivalState == .previousApproaching) ||
        (newTrainInfo.arrivalState == .previousArrived)
      // 목표역인 전역에 근접 또는 도착한 경우 eta와 남은 거리를 0으로 설정하여 도착 위치로 이동
      guard hasArrivedTargetStation else { return }
      eta = 0
      remainDistance = 0
      return
    }

    // 목표역 -> 방향역 설정으로 가져온 열차 목록(목표역에 근접하지 않은 경우 신뢰도가 높음)
    if eta >= 30 {
      eta = Int(newTrainInfo.eta)!
      distancePerTic = remainDistance / CGFloat(eta)
    }
  }
}

struct TrainProgressView_Previews: PreviewProvider {
  static let stationInfoClient: StationInfoClient = .live()

  static var previews: some View {

    let gangNam = stationInfoClient.findStationInfo(from: "1002000222")
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
      subwayLineColor: .red,
      movingTimer: Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    )
  }
}
