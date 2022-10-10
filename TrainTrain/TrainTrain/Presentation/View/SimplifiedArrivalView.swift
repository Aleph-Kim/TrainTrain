import SwiftUI

struct SimplifiedArrivalView: View {

  @Binding var selectedStation: StationInfo?
  @Binding var selectedDirection: String? // "OO방면"
  
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
          Text("🚇 실시간 도착 정보")
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

      if selectedDirection != nil {
        Button {
          fetch(target: selectedStation, next: selectedDirection) {
            isLoading = false
            refreshTimer = 10
          }
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
          refreshTimer -= 1

          if refreshTimer == .zero {
            fetch(target: selectedStation, next: selectedDirection) {
              isLoading = false
              refreshTimer = 10
            }
          }
        }
        .onChange(of: selectedDirection) { newValue in
          guard newValue != nil else { return }
          fetch(target: selectedStation, next: selectedDirection) {
            isLoading = false
            refreshTimer = 10
          }
        }
      }
    }
    .padding(.horizontal)
  }

  private func fetch(target: StationInfo?, next: String?, completion: @escaping () -> Void) {
    Task {
      guard let target = selectedStation?.stationName,
            let next = selectedDirection?.replacingOccurrences(of: "방면", with: "") else { return }

      isLoading = true
      realtime = await networkManager.fetch(targetStationName: target, nextStationName: next)
      completion()
    }
  }
}

struct SimplifiedArrivalView_Previews: PreviewProvider {
  static var previews: some View {
    SimplifiedArrivalView(
      selectedStation: .constant(
        .init(subwayLineID: "1002",
              stationID: "1002000222",
              stationName: "강남")),
      selectedDirection: .constant("역삼방면"))
  }
}
