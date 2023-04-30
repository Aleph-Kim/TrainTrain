import SubwayModels
import StationInfoClient
import SubwayInfoClient
import SwiftUI

public struct DebugArrivalView: View {

  @Binding private var selectedStation: StationInfo
  @Binding private var directionStationID: String

  @State private var realtime: [TrainInfo] = []
  @State private var isLoading: Bool = false
  @State private var refreshTimer = 5

  private let stationInfoClient: StationInfoClient
  private let subwayInfoClient: SubwayInfoClient
  private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  public init(
    selectedStation: Binding<StationInfo>,
    directionStationID: Binding<String>,
    realtime: [TrainInfo] = [],
    isLoading: Bool = false,
    refreshTimer: Int = 5,
    stationInfoClient: StationInfoClient,
    subwayInfoClient: SubwayInfoClient
  ) {
    self._selectedStation = selectedStation
    self._directionStationID = directionStationID
    self.realtime = realtime
    self.isLoading = isLoading
    self.refreshTimer = refreshTimer
    self.stationInfoClient = stationInfoClient
    self.subwayInfoClient = subwayInfoClient
  }

  public var body: some View {
    VStack {
      HStack {
        Text("🚇 \(selectedStation.stationName)역 도착 정보")
          .font(.title)
          .fontWeight(.thin)
        Spacer()
      }

      ForEach(realtime) { trainInfo in
        GroupBox {
          VStack(alignment: .leading) {
            let directionStationName = stationInfoClient.findStationName(from: directionStationID)

            if trainInfo.trainDestination.contains(directionStationName) {
              Text("ID: \(trainInfo.id)")
                .fontWeight(.bold)
              Text("방향: \(trainInfo.trainDestination)")
              Text("ETA: \(trainInfo.eta)초 후")
                .fontWeight(.bold)
                .foregroundColor(.blue)
              Text("메시지1: \(trainInfo.formattedDrivingStatus)")
              Text("메시지2: \(trainInfo.previousStationName ?? "두번째 메세지 없음")")
              Text("도착코드: \(trainInfo.arrivalState.rawValue) - \(arrivalStateMessage(trainInfo))")
              Text("막차 여부: \(trainInfo.trainDestination.contains("막차") ? "⚠️ 막차!" : "false")")
            } else if !trainInfo.trainDestination.contains(directionStationName), trainInfo.formattedDrivingStatus.contains("진입") {
              Text("ID: \(trainInfo.id)")
                .fontWeight(.bold)
              Text("💨 \(selectedStation.stationName)역에 진입 중입니다.")
                .foregroundColor(.blue)
              Text("메시지1: \(trainInfo.formattedDrivingStatus)")
              Text("메시지2: \(trainInfo.previousStationName ?? "두번째 메세지 없음")")
              Text("도착코드: \(trainInfo.arrivalState.rawValue) - \(arrivalStateMessage(trainInfo))")
            } else if !trainInfo.trainDestination.contains(directionStationName), trainInfo.formattedDrivingStatus.contains("도착") {
              Text("ID: \(trainInfo.id)")
                .fontWeight(.bold)
              Text("🏁 \(selectedStation.stationName)역에 도착했습니다.")
                .foregroundColor(.blue)
              Text("메시지1: \(trainInfo.formattedDrivingStatus)")
              Text("메시지2: \(trainInfo.previousStationName ?? "두번째 메세지 없음")")
              Text("도착코드: \(trainInfo.arrivalState.rawValue) - \(arrivalStateMessage(trainInfo))")
            } else {
              Text("ID: \(trainInfo.id)")
                .fontWeight(.bold)
              Text("⚠️ \(selectedStation.stationName)역을 이미 떠난 열차입니다.")
                .foregroundColor(.red)
              Text("방향: \(trainInfo.trainDestination)")
            }
          }
          .font(.footnote)
          .padding(.horizontal, 50)
        }
      }

      Button {
        fetch(target: selectedStation)
      } label: {
        if isLoading {
          ProgressView()
        } else {
          Text("**\(refreshTimer)초** 후 자동 리프레시 ♻️")
        }
      }
      .buttonStyle(.bordered)
      .tint(.green)
      .disabled(isLoading)
      .onReceive(timer) { _ in
        guard !isLoading else { return }
        refreshTimer -= 1

        if refreshTimer == .zero {
          fetch(target: selectedStation)
        }
      }
      .onChange(of: directionStationID) { _ in
        fetch(target: selectedStation)
      }
      .onAppear {
        fetch(target: selectedStation)
      }
    }
    .padding(.horizontal)
  }

  private func fetch(target: StationInfo?) {
    Task {
      guard let target else { return }
      isLoading = true
      defer {
        isLoading = false
        refreshTimer = 5
      }
      realtime = try await subwayInfoClient.fetchTrainInfos(targetStation: target, directionStationID: directionStationID)
    }
  }

  private func arrivalStateMessage(_ trainInfo: TrainInfo) -> String {
    switch trainInfo.arrivalState {
    case .approaching: return "진입"
    case .arrived: return "도착"
    case .departed: return "출발"
    case .previousApproaching: return "전역 진입"
    case .previousArrived: return "전역 도착"
    case .previousDeparted: return "전역 출발"
    case .driving: return "운행 중"
    }
  }
}

// MARK: SwiftUI previews

struct DebugArrivalView_Previews: PreviewProvider {
  static let stationInfoClient: StationInfoClient = .live()
  static let subwayInfoClient: SubwayInfoClient = .live()

  static var previews: some View {
    DebugArrivalView(
      selectedStation: .constant(.mock),
      directionStationID: .constant("1002000227"),
      stationInfoClient: .live(),
      subwayInfoClient: subwayInfoClient)
  }
}
