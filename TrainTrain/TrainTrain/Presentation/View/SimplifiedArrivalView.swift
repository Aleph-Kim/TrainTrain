import SwiftUI

struct SimplifiedArrivalView: View {

  @Binding var selectedStation: StationInfo?
  
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

      ForEach(realtime) { arrivalInfo in
        GroupBox {
          VStack(alignment: .leading) {
            Text("방향: \(arrivalInfo.trainDestination)")
            Text("ETA: \(arrivalInfo.eta)초 후")
            Text("메시지1: \(arrivalInfo.firstMessage)")
            Text("메시지2: \(arrivalInfo.secondMessage)")
            Text("막차 여부: \(arrivalInfo.trainDestination.contains("막차") ? "⚠️ 막차!" : "false")")
          }
          .font(.footnote)
          .padding(.horizontal, 50)
        }
      }

      if let selectedStation {
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
        .onChange(of: selectedStation) { _ in
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
      realtime = await networkManager.fetchFar(targetStation: target)
      print("🚟🚟🚟 다가오는 최대 2개의 열차 -> \(realtime)")
      isLoading = false
      refreshTimer = 10
    }
  }
}

// MARK: SwiftUI previews

struct SimplifiedArrivalView_Previews: PreviewProvider {
  static var previews: some View {
    SimplifiedArrivalView(
      selectedStation: .constant(
        .init(subwayLineID: "1002",
              stationID: "1002000228",
              stationName: "서울대입구",
              nextStationName: "낙성대",
              previousStationName: "봉천")))
  }
}
