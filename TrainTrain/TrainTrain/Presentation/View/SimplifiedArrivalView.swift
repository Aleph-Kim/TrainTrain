import SwiftUI

struct SimplifiedArrivalView: View {

  @Binding var selectedStation: StationInfo?
  @Binding var selectedDirection: String? // "OO방면"
  
  @State private var realtime: [TrainInfo] = []
  @State private var isLoading: Bool = false

  private let networkManager = NetworkManager()

  var body: some View {
    VStack {
      if let stationName = realtime.first?.stationName {
        HStack {
          Text("🚉 \(stationName)역 도착 정보")
            .font(.title)
            .fontWeight(.thin)
          Spacer()
        }
      } else {
        HStack {
          Text("🚇 실시간 도착 정보 검색")
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

      Button {
        fetch(target: selectedStation, next: selectedDirection)
      } label: {
        if isLoading {
          ProgressView()
        } else {
          Text("♻️ 리프레시")
        }
      }
      .buttonStyle(.bordered)
      .tint(.green)
      .disabled(isLoading)
      .onChange(of: selectedDirection) { newValue in
        guard newValue != nil else { return }
        fetch(target: selectedStation, next: selectedDirection)
      }
    }
    .padding(.horizontal)
  }

  private func fetch(target: StationInfo?, next: String?) {
    Task {
      guard let target = selectedStation?.stationName,
            let next = selectedDirection?.replacingOccurrences(of: "방면", with: "") else { return }

      isLoading = true
      realtime = await networkManager.fetch(targetStationName: target, nextStationName: next)
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        isLoading = false
      }
    }
  }
}

struct SimplifiedArrivalView_Previews: PreviewProvider {
  static var previews: some View {
    SimplifiedArrivalView(
      selectedStation: .constant(.init(subwayLineID: "1002", stationID: "1002000222", stationName: "강남")),
      selectedDirection: .constant("역삼방면"))
  }
}
