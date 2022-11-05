import SwiftUI

struct SimplifiedArrivalView: View {

  @Binding var selectedStation: StationInfo
  @Binding var directionStationID: String

  @State private var realtime: [TrainInfo] = []
  @State private var isLoading: Bool = false
  @State private var refreshTimer = 10

  private let networkManager = NetworkManager()
  private let timer = Timer.publish(every: 1 , on: .main, in: .common).autoconnect()

  var body: some View {
    VStack {
      if let stationName = realtime.first?.stationName {
        HStack {
          Text("🚇 \(stationName)역 도착 정보")
            .font(.title)
            .fontWeight(.thin)
          Spacer()
        }
      } else {
        HStack {
          Text("🚇 실시간 도착 정보 (이전 역에서~)")
            .font(.title)
            .fontWeight(.thin)
          Spacer()
        }
      }

      ForEach(realtime) { trainInfo in
        GroupBox {
          VStack(alignment: .leading) {
            Text("ID: \(trainInfo.id)")
            Text("방향: \(trainInfo.trainDestination)")
            Text("ETA: \(trainInfo.eta)초 후")
            Text("메시지1: \(trainInfo.firstMessage)")
            Text("메시지2: \(trainInfo.secondMessage)")
            Text("도착코드: \(trainInfo.arrivalState.rawValue) - \(arrivalStateMessage(trainInfo))")
            Text("막차 여부: \(trainInfo.trainDestination.contains("막차") ? "⚠️ 막차!" : "false")")
          }
          .font(.footnote)
          .padding(.horizontal, 50)
        }
      }

      if let directionStationID {
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
    }
    .padding(.horizontal)
  }

  private func fetch(target: StationInfo?) {
    Task {
      guard let target else { return }
      isLoading = true
      defer {
        isLoading = false
        refreshTimer = 10
      }
      realtime = await networkManager.fetchFar(targetStation: target, directionStationID: directionStationID)
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

struct SimplifiedArrivalView_Previews: PreviewProvider {
  static var previews: some View {
    SimplifiedArrivalView(
      selectedStation: .constant(
        .init(
          subwayLineID: "1002",
          stationID: "1002000228",
          stationName: "서울대입구",
          lowerStationID_1: "1002000229",
          lowerStationETA_1: 60,
          lowerStationID_2: "",
          lowerStationETA_2: "",
          upperStationID_1: "1002000227",
          upperStationETA_1: 120,
          upperStationID_2: "",
          upperStationETA_2: "")),
      directionStationID: .constant("1002000227"))
  }
}
