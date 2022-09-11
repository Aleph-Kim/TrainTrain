import SwiftUI

struct TestingView: View {

  @State private var realtime: [ArrivalInfo] = []
  @State private var target: String = ""
  @State private var next: String = ""

  private let networkManager = NetworkManager()

  var body: some View {
    ScrollView {
      VStack {
        if let stationName = realtime.first?.stationName {
          HStack {
            Text("\(stationName)역 도착 정보")
              .font(.largeTitle)
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
      }

      TextField("검색할 지하철 역의 이름", text: $target)
        .textFieldStyle(.roundedBorder)
      TextField("그 다음 역의 이름", text: $next)
        .textFieldStyle(.roundedBorder)

      Button("불러오기") {
        Task {
          realtime = await networkManager.fetch(targetStationName: target, nextStationName: next) ?? []
        }
      }
      .buttonStyle(.borderedProminent)
      .keyboardShortcut(.defaultAction)
    }
    .padding()
  }
}

struct TestingView_Previews: PreviewProvider {
  static var previews: some View {
    TestingView()
  }
}
